import Foundation


// MARK: - Indexing 3D color space

func morton3DIndex(x: Double, y: Double, z: Double, bits: Int = 21) -> UInt64 {
	precondition(0.0...1.0 ~= x && 0.0...1.0 ~= y && 0.0...1.0 ~= z)
	precondition(bits > 0 && bits <= 21, "bits must be 1...21 for safe 64-bit result")

	let maxVal = (1 << bits) - 1
	let xi = UInt64(round(x * Double(maxVal)))
	let yi = UInt64(round(y * Double(maxVal)))
	let zi = UInt64(round(z * Double(maxVal)))

	func interleave3(_ x: UInt64, _ y: UInt64, _ z: UInt64, bits: Int) -> UInt64 {
		var answer: UInt64 = 0
		for i in 0..<bits {
			let shift = UInt64(i)
			let bx = (x >> shift) & 1
			let by = (y >> shift) & 1
			let bz = (z >> shift) & 1
			answer |= (bx << (3 * shift))
			answer |= (by << (3 * shift + 1))
			answer |= (bz << (3 * shift + 2))
		}
		return answer
	}

	return interleave3(xi, yi, zi, bits: bits)
}

func morton3Dto(index: UInt64, bits: Int = 21) -> Kolor.Channels {
	precondition(bits > 0 && bits <= 21)

	var xi: UInt64 = 0
	var yi: UInt64 = 0
	var zi: UInt64 = 0

	for i in 0..<bits {
		let base = UInt64(3 * i)
		xi |= ((index >> base) & 1) << UInt64(i)
		yi |= ((index >> (base + 1)) & 1) << UInt64(i)
		zi |= ((index >> (base + 2)) & 1) << UInt64(i)
	}
	let maxVal = Double((1 << bits) - 1)

	return (x: Double(xi) / maxVal, y: Double(yi) / maxVal, z: Double(zi) / maxVal)
}








