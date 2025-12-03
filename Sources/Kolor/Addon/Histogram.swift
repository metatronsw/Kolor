import Foundation
import Accelerate

public extension Array where Array.Element == sRGB {

	func makeQuantizedCounts(levels: Int = 4, gamma: Double? = nil) -> [Int] {
		guard !self.isEmpty, levels < 129 else { return [] }

		var counts = Array<Int>(repeating: 0, count: cub(levels))

		if let gamma {
			for col in self {
				let idx = col.toQuantizedExpIndex(levels: levels, gamma: gamma)
				counts[idx] += 1
			}
			return counts
		}

		switch levels {
			case 2, 4, 8, 16, 32, 64, 128:
				let shift = Int(log2(Double(levels)))
				for col in self {
					let idx = col.toQuantizedIndex(Pow2: shift)
					counts[idx] += 1
				}

			default:
				for col in self {
					let idx = col.toQuantizedIndex(by: levels)
					counts[idx] += 1
				}
		}

		return counts
	}

}

public extension [Double] {

	/// Distance from normalized Counts
	func distanceCosine(from b: [Double]) -> Double {
		var dot = 0.0
		var na = 0.0
		var nb = 0.0

		for i in 0..<self.count {
			dot += self[i] * b[i]
			na += self[i] * self[i]
			nb += b[i] * b[i]
		}

		let denom = (sqrt(na) * sqrt(nb))
		if denom == 0 { return 1.0 }

		let cosineSim = dot / denom
		return 1.0 - cosineSim
	}

}

public struct Histogram {

	public typealias Num = UInt16

	public var bins: [Num]

	public var centroid: (Num, Num, Num)

	public var count: Int { bins.count }

	public var indices: Range<Int> { 0..<bins.count }

	public init() {
		bins = []
		centroid = (0, 0, 0)
	}

	public init(from counts: [Int], levels: Int = 4, totalPixels: Int? = nil) {
		let total = totalPixels ?? counts.reduce(0, +)
		let dTotal = Double(total)
		let max = Double(Num.max)

		let normalized = counts.map {
			let weight = Double($0) / dTotal
			return Num.init(min(max, weight * max))
		}

		self.bins = normalized
		self.centroid = Self.centroid(from: counts, total: dTotal, levels: 4)
	}

	private static func centroid(from counts: [Int], total: Double, levels: Int) -> (Num, Num, Num) {
		var sumX = 0.0, sumY = 0.0, sumZ = 0.0

		for index in counts.indices {
			let weight = Double(counts[index]) / total

			let X = index / (levels * levels)
			let Y = (index / levels) % levels
			let Z = index % levels

			sumX += Double(X) * weight
			sumY += Double(Y) * weight
			sumZ += Double(Z) * weight
		}

		let max = Double(Num.max)

		return (Num.init(min(max, sumX / Double(levels - 1) * max)),
				  Num.init(min(max, sumY / Double(levels - 1) * max)),
				  Num.init(min(max, sumZ / Double(levels - 1) * max)))
	}

	public func toDouble(index: Int) -> Double {
		Double(bins[index]) / Double(Num.max)
	}

}


public extension Histogram {

	static func findSimilar(to query: Histogram, in database: [Histogram], topK: Int = 10, threshold: Int = 50) -> [Int] {
		let candidates = database.enumerated().filter {
			query.distanceCentroid(to: $0.element) < threshold
		}

		return candidates
			.map { ($0.offset, query.distance(to: $0.element)) }
			.sorted { $0.1 < $1.1 }
			.prefix(topK)
			.map { $0.0 }
	}

	func distanceCentroid(to other: Histogram) -> Int {
		abs(Int(centroid.0) - Int(other.centroid.0)) +
			abs(Int(centroid.1) - Int(other.centroid.1)) +
			abs(Int(centroid.2) - Int(other.centroid.2))
	}

	func distance(to other: Histogram) -> Int {
		
		var result = 0

		self.bins.withUnsafeBufferPointer { aPtr in
			other.bins.withUnsafeBufferPointer { bPtr in
				for i in 0..<self.count {
					let diff = Int(aPtr[i]) - Int(bPtr[i])
					result += abs(diff)
				}
			}
		}

		return result
	}

	func distance_Simd(to other: Histogram) -> Int {
		assert(self.bins.count == other.bins.count)
//		assert(self.bins.count % 16 == 0)
		
		var sum = 0
		
		self.bins.withUnsafeBytes { rawBufferA in
			other.bins.withUnsafeBytes { rawBufferB in
				let ptrA = rawBufferA.bindMemory(to: SIMD16<Num>.self)
				let ptrB = rawBufferB.bindMemory(to: SIMD16<Num>.self)
				
				for i in 0..<ptrA.count {
					
					/// L1 Manhattan
					let diff = (ptrA[i] &- ptrB[i]).replacing(with: ptrB[i] &- ptrA[i], where: ptrA[i] .< ptrB[i])
					sum += Int(diff.wrappedSum())
					
					/// L2 Euclidean squared
					// sum += Int((diff &* diff).wrappedSum())
				}
			}
		}
		
		if self.bins.count % 16 == 0 { return sum }
		
		let end = (self.bins.count / 16) * 16
//		if end != self.bins.count {
			for i in end..<self.bins.count {
				let diff = Int(self.bins[i]) &- Int(other.bins[i])
				sum += abs(diff)
			}
//		}
		
		return sum
	}

	func distance_Acel(to other: Histogram) -> Int {
		var result = 0
		
		self.bins.withUnsafeBufferPointer { aPtr in
			other.bins.withUnsafeBufferPointer { bPtr in
				var aFloat = [Float](repeating: 0, count: bins.count)
				var bFloat = [Float](repeating: 0, count: bins.count)
				
				vDSP_vfltu16(aPtr.baseAddress!, 1, &aFloat, 1, vDSP_Length(bins.count))
				vDSP_vfltu16(bPtr.baseAddress!, 1, &bFloat, 1, vDSP_Length(bins.count))
				
				// a - b
				var diff = [Float](repeating: 0, count: bins.count)
				vDSP_vsub(bFloat, 1, aFloat, 1, &diff, 1, vDSP_Length(bins.count))
				
				// abs
				vDSP_vabs(diff, 1, &diff, 1, vDSP_Length(bins.count))
				
				// sum
				var sum: Float = 0
				vDSP_sve(diff, 1, &sum, vDSP_Length(bins.count))
				
				result = Int(sum)
			}
		}
		
		return result
	}
	
	func distance_ChiSquare(to other: Histogram) -> Double {
		var result = 0.0

		self.bins.withUnsafeBufferPointer { ptrA in
			other.bins.withUnsafeBufferPointer { ptrB in
				for i in 0..<self.count {
					let a = Double(ptrA[i])
					let b = Double(ptrB[i])

					let sum = a + b
					if sum > 0 {
						let dif = a - b
						result += dif * dif / sum
					}
				}
			}
		}

		return result
	}

	func intersection_Simd(to other: Histogram) -> Double {
		assert(self.bins.count == other.bins.count)
		assert(self.bins.count % 16 == 0)

		var intersection = 0.0
		var sum1 = 0.0
		var sum2 = 0.0

		self.bins.withUnsafeBufferPointer { buf1 in
			other.bins.withUnsafeBufferPointer { buf2 in
				for i in stride(from: 0, to: buf1.count, by: 16) {
					let v1 = SIMD16<Num>(buf1[i..<min(i + 16, buf1.count)])
					let v2 = SIMD16<Num>(buf2[i..<min(i + 16, buf2.count)])

					let minVals = pointwiseMin(v1, v2)
					intersection += Double(minVals.wrappedSum())

					sum1 += Double(v1.wrappedSum())
					sum2 += Double(v2.wrappedSum())
				}
			}
		}

		let minSum = min(sum1, sum2)
		return minSum > 0 ? intersection / minSum : 0
	}

}




// TODO: - LSHIndex
// TODO: - PCA class színhisztogramokhoz
