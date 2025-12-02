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
			case 2,4,8,16,32,64,128:
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





public struct Histogram<Num: UnsignedInteger & FixedWidthInteger> {

	public var bins: [Num]
	public var centroid: (Num,Num,Num)
	
	public init() {
		bins = []
		centroid = (0,0,0)
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
	
	
	private static func centroid(from counts: [Int], total: Double, levels: Int) -> (Num,Num,Num) {
		
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
		
		return ( Num.init(min(max,sumX / Double(levels - 1) * max)),
					Num.init(min(max,sumY / Double(levels - 1) * max)),
					Num.init(min(max,sumZ / Double(levels - 1) * max)))
	}
	
	public var count: Int { bins.count }
	
	public var indices: Range<Int> { 0..<bins.count }
	
	public func toDouble(index: Int) -> Double {

		Double(bins[index]) / Double(Num.max)
	}
	
	
	
//	func makeHistogramUInt16Log(levels: Int = 4) -> [UInt16] {
//		guard !self.isEmpty else { return [] }
//		let hist = makeHistogram(levels: levels)
//		
//		let total = Double(self.count)
//		let maxLog = log(Double(total) + 1)
//		
//		return hist.map { count -> UInt16 in
//			guard count > 0 else { return 0 }
//			return UInt16(log(Double(count) + 1) / maxLog * 65535)
//		}
//	}
	
}
		



public extension Histogram {
	
	
	func distanceL1(to other: Histogram) -> Int {
		var sum = 0
		for i in bins.indices {
			sum &+= abs(Int(bins[i]) &- Int(other.bins[i]))
		}
		return sum
	}
	
	
	func distanceL1_ptr(to other: Histogram) -> Int {
		
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
	
	/*
	func distanceL1_Acel(to other: Histogram) -> Int {
		
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
	
	
	func distanceL1_Simd(to other: Histogram) -> Int {
		
		var sum: Int32 = 0
		let count = bins.count
		
		bins.withUnsafeBufferPointer { aPtr in
			other.bins.withUnsafeBufferPointer { bPtr in
				var i = 0
				
				// 8-asával feldolgozás
				while i + 8 <= count {
					let a = SIMD8<Int32>(
						Int32(aPtr[i]), Int32(aPtr[i+1]), Int32(aPtr[i+2]), Int32(aPtr[i+3]),
						Int32(aPtr[i+4]), Int32(aPtr[i+5]), Int32(aPtr[i+6]), Int32(aPtr[i+7])
					)
					let b = SIMD8<Int32>(
						Int32(bPtr[i]), Int32(bPtr[i+1]), Int32(bPtr[i+2]), Int32(bPtr[i+3]),
						Int32(bPtr[i+4]), Int32(bPtr[i+5]), Int32(bPtr[i+6]), Int32(bPtr[i+7])
					)
					sum += abs(a &- b).wrappedSum()
					i += 8
				}
				
				// Maradék
				while i < count {
					sum += abs(Int32(aPtr[i]) - Int32(bPtr[i]))
					i += 1
				}
			}
		}
		return Int(sum)
	}
	*/
	
	func quickDistance(to other: Histogram) -> Int {
		abs(Int(centroid.0) - Int(other.centroid.0)) +
		abs(Int(centroid.1) - Int(other.centroid.1)) +
		abs(Int(centroid.2) - Int(other.centroid.2))
	}
	
	
	static func findSimilar(to query: Histogram, in database: [Histogram], topK: Int = 10, threshold: Int = 50) -> [Int] {
		// 1. lépés: gyors szűrés súlyponttal
		let candidates = database.enumerated().filter {
			query.quickDistance(to: $0.element) < threshold
		}
		
		// 2. lépés: pontos összehasonlítás csak a jelöltekre
		return candidates
			.map { ($0.offset, query.distanceL1(to: $0.element)) }
			.sorted { $0.1 < $1.1 }
			.prefix(topK)
			.map { $0.0 }
	}
}

/*
 
 extension Histogram {
	
	struct LSHIndex {
		// Több hash tábla, mindegyik más random projekcióval
		private var tables: [[Int: [Int]]]  // [hash: [imageIndices]]
		private let numTables: Int
		private let numBits: Int
		private var projections: [[[Float]]]  // random hyperplane-ek
		
		init(numTables: Int = 8, numBits: Int = 8) {
			self.numTables = numTables
			self.numBits = numBits
			self.tables = Array(repeating: [:], count: numTables)
			self.projections = (0..<numTables).map { _ in
				(0..<numBits).map { _ in
					(0..<64).map { _ in Float.random(in: -1...1) }  // 64 bin
				}
			}
		}
		
		// Histogram -> hash érték egy táblához
		private func hash(_ histogram: [UInt8], tableIndex: Int) -> Int {
			var result = 0
			for bit in 0..<numBits {
				var dot: Float = 0
				for i in 0..<histogram.count {
					dot += Float(histogram[i]) * projections[tableIndex][bit][i]
				}
				if dot > 0 {
					result |= (1 << bit)
				}
			}
			return result
		}
		
		// Kép hozzáadása az indexhez
		mutating func insert(_ histogram: [UInt8], imageIndex: Int) {
			for t in 0..<numTables {
				let h = hash(histogram, tableIndex: t)
				tables[t][h, default: []].append(imageIndex)
			}
		}
		
		// Hasonló képek keresése
		func query(_ histogram: [UInt8]) -> Set<Int> {
			var candidates = Set<Int>()
			for t in 0..<numTables {
				let h = hash(histogram, tableIndex: t)
				if let bucket = tables[t][h] {
					candidates.formUnion(bucket)
				}
			}
			return candidates
		}
	}
	
	static func se() {
		
		// Építés
		var lsh = LSHIndex(numTables: 8, numBits: 8)
		for (i, histogram) in allHistograms.enumerated() {
			lsh.insert(histogram.bins, imageIndex: i)
		}
		
		
		// Keresés
		func findSimilar(to query: Histogram, allHistograms: [Histogram], topK: Int) -> [Int] { // 1. LSH: gyors jelölt szűrés
			let candidates = lsh.query(query.bins)
			
			// 2. Pontos összehasonlítás csak jelöltekre
			return candidates
				.map { ($0, query.fullDistance(to: allHistograms[$0])) }
				.sorted { $0.1 < $1.1 }
				.prefix(topK)
				.map { $0.0 }
		}
	}
}
 
 // MARK: - PCA osztály színhisztogramokhoz
 
 
 class HistogramPCA {
 
 private var meanVector: [Double] = []
 private var principalComponents: [[Double]] = []
 private var dimensions: Int = 0
 private var outputDimensions: Int = 0
 
 /// Kimeneti dimenziók száma (pl. 16 vagy 32)
 func fit(histograms: [[Int]], outputDims: Int = 16) {
 guard !histograms.isEmpty else { return }
 
 dimensions = histograms[0].count
 outputDimensions = min(outputDims, dimensions)
 let n = histograms.count
 
 // 1. Konvertálás Double-ra és normalizálás
 var data: [[Double]] = histograms.map { hist in
 let sum = Double(hist.reduce(0, +))
 return hist.map { sum > 0 ? Double($0) / sum : 0.0 }
 }
 
 // 2. Átlag kiszámítása
 meanVector = [Double](repeating: 0.0, count: dimensions)
 for hist in data {
 for i in 0..<dimensions {
 meanVector[i] += hist[i]
 }
 }
 meanVector = meanVector.map { $0 / Double(n) }
 
 // 3. Centrálás (átlag kivonása)
 for i in 0..<n {
 for j in 0..<dimensions {
 data[i][j] -= meanVector[j]
 }
 }
 
 // 4. Kovariancia mátrix számítása
 var covariance = [[Double]](repeating: [Double](repeating: 0.0, count: dimensions), count: dimensions)
 for i in 0..<dimensions {
 for j in i..<dimensions {
 var sum = 0.0
 for k in 0..<n {
 sum += data[k][i] * data[k][j]
 }
 covariance[i][j] = sum / Double(n - 1)
 covariance[j][i] = covariance[i][j]
 }
 }
 
 // 5. Sajátérték dekompozíció (Power iteration módszer)
 principalComponents = computeEigenvectors(matrix: covariance, count: outputDimensions)
 }
 
 func transform(histogram: [Int], totalPixels: Int? = nil) -> [Double] {
 guard !principalComponents.isEmpty else { return [] }
 
 let total = totalPixels ?? histogram.reduce(0, +)
 let sum = Double(total)
 
 var normalized = histogram.map { Double($0) / sum }
 
 // Centrálás
 for i in 0..<dimensions {
 normalized[i] -= meanVector[i]
 }
 
 // Projekció a főkomponensekre
 var result = [Double](repeating: 0.0, count: outputDimensions)
 for i in 0..<outputDimensions {
 for j in 0..<dimensions {
 result[i] += normalized[j] * principalComponents[i][j]
 }
 }
 
 return result
 }
 
 /// Több hisztogram transzformálása egyszerre
 func transformBatch(histograms: [[Int]]) -> [[Double]] {
 return histograms.map { transform(histogram: $0) }
 }
 
 // MARK: - Modell mentése/betöltése
 
 func save() -> [String: Any] {
 return [
 "mean": meanVector,
 "components": principalComponents,
 "dims": dimensions,
 "outputDims": outputDimensions
 ]
 }
 
 func load(from dict: [String: Any]) {
 meanVector = dict["mean"] as? [Double] ?? []
 principalComponents = dict["components"] as? [[Double]] ?? []
 dimensions = dict["dims"] as? Int ?? 0
 outputDimensions = dict["outputDims"] as? Int ?? 0
 }
 
 // MARK: - Sajátvektor számítás (Power Iteration)
 
 private func computeEigenvectors(matrix: [[Double]], count: Int) -> [[Double]] {
 var eigenvectors: [[Double]] = []
 var workMatrix = matrix
 let n = matrix.count
 
 for _ in 0..<count {
 // Random kezdő vektor
 var vector = (0..<n).map { _ in Double.random(in: -1...1) }
 
 // Power iteration (50 iteráció általában elég)
 for _ in 0..<50 {
 // Mátrix-vektor szorzás
 var newVector = [Double](repeating: 0.0, count: n)
 for i in 0..<n {
 for j in 0..<n {
 newVector[i] += workMatrix[i][j] * vector[j]
 }
 }
 
 // Normalizálás
 let norm = sqrt(newVector.reduce(0) { $0 + $1 * $1 })
 if norm > 1e-10 {
 vector = newVector.map { $0 / norm }
 }
 }
 
 eigenvectors.append(vector)
 
 // Defláció: eltávolítjuk az aktuális sajátvektort
 let eigenvalue = dotProduct(matrixVectorMultiply(workMatrix, vector), vector)
 for i in 0..<n {
 for j in 0..<n {
 workMatrix[i][j] -= eigenvalue * vector[i] * vector[j]
 }
 }
 }
 
 return eigenvectors
 }
 
 private func dotProduct(_ a: [Double], _ b: [Double]) -> Double {
 zip(a, b).reduce(0) { $0 + $1.0 * $1.1 }
 }
 
 private func matrixVectorMultiply(_ matrix: [[Double]], _ vector: [Double]) -> [Double] {
 matrix.map { row in zip(row, vector).reduce(0) { $0 + $1.0 * $1.1 } }
 }
 
 }
 
 // MARK: - Euklideszi távolság PCA vektorok között
 
 func euclideanDistance(_ a: [Double], _ b: [Double]) -> Double {
 sqrt(zip(a, b).reduce(0) { $0 + pow($1.0 - $1.1, 2) })
 }


*/

// MARK: - Histogram

public extension [Double] {
	
	func cosineDistance(from b: [Double]) -> Double {
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


