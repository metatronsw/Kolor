import Foundation

/// OKLAB color space, in Cartesian. It uses the D65 standard illuminant.
///
public struct OKLAB: Kolor, Comparable {

	public var ch: Channels

	/// `Lightness` component [0...1]
	public var L: Double { get { ch.0 } set { ch.0 = newValue } }
	/// `A (Green-Red)` component [-0.4...0.4]
	public var a: Double { get { ch.1 } set { ch.1 = newValue } }
	/// `B (Blue-Yellow)` component [-0.4...0.4]
	public var b: Double { get { ch.2 } set { ch.2 = newValue } }

	public static var ranges: CompRanges { (0...1, -0.4...0.4, -0.4...0.4) }

	public init(ch: Channels) { self.ch = (ch.0, ch.1, ch.2) }

	/// Raw Init
	public init(L: Double = 0, a: Double = 0, b: Double = 0) { self.ch = (L, a, b) }

	public init(r: Double, g: Double, b: Double) {
		let rL = r.linearize()
		let gL = g.linearize()
		let bL = b.linearize()

		let l = cbrt(0.4122214708 * rL + 0.5363325363 * gL + 0.0514459929 * bL)
		let m = cbrt(0.2119034982 * rL + 0.6806995451 * gL + 0.1073969566 * bL)
		let s = cbrt(0.0883024619 * rL + 0.2817188376 * gL + 0.6299787005 * bL)

		self.ch = Channels(
			0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
			1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
			0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s
		)
	}

	/// From D65
	public init(x: Double, y: Double, z: Double) {
		let l = cbrt(0.8189330101 * x + 0.3618667424 * y - 0.1288597137 * z)
		let m = cbrt(0.0329845436 * x + 0.9293118715 * y + 0.0361456387 * z)
		let s = cbrt(0.0482003018 * x + 0.2643662691 * y + 0.6338517070 * z)

		self.ch = Channels(
			0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
			1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
			0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s
		)
	}

	public init(normX: Double, normY: Double, normZ: Double) { self.ch = (normX, normY * 0.8 - 0.4, normZ * 0.8 - 0.4) }
	
	public func normalized() -> Channels { (ch.0, (ch.1 + 0.4) / 0.8, (ch.2 + 0.4) / 0.8) }

}

public extension OKLAB {

	func toXYZ() -> XYZ {
		let l = cub(self.L + 0.3963377774 * self.a + 0.2158037573 * self.b)
		let m = cub(self.L - 0.1055613458 * self.a - 0.0638541728 * self.b)
		let s = cub(self.L - 0.0894841775 * self.a - 1.2914855480 * self.b)

		let X = +1.2270138511 * l - 0.5577999807 * m + 0.2812561489 * s
		let Y = -0.0405801784 * l + 1.1122568696 * m - 0.0716766787 * s
		let Z = -0.0763812845 * l - 0.4214819784 * m + 1.5861632204 * s

		return XYZ(x: X, y: Y, z: Z)
	}

	func toLinearRGB() -> RGB {
		let l = cub(self.L + 0.3963377774 * self.a + 0.2158037573 * self.b)
		let m = cub(self.L - 0.1055613458 * self.a - 0.0638541728 * self.b)
		let s = cub(self.L - 0.0894841775 * self.a - 1.2914855480 * self.b)

		let r = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s
		let g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s
		let b = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s

		return RGB(r, g, b)
	}

	func toRGB() -> RGB {
		self.toLinearRGB().toDelinearized()
	}

	func toOKLCH() -> OKLCh {
		let C = sqrt(self.a * self.a + self.b * self.b)
		let h = atan2(self.b, self.a)

		return OKLCh(L: self.L, C: C, h: h)
	}

}

public extension OKLAB {

	var hue: Double { atan2(a, b) }

	var chroma: Double { sqrt(a * a + b * b) }

	/// by Hue
	static func < (lhs: Self, rhs: Self) -> Bool {
		let h1 = atan2(lhs.a, lhs.b)
		let h2 = atan2(rhs.a, rhs.b)
		if abs(h1 - h2) > 0.001 { return h1 < h2 }
		return lhs.L < rhs.L
	}

	/// by Chroma - from origo
//	static func < (lhs: Self, rhs: Self) -> Bool {
//		let chroma1 = lhs.chroma
//		let chroma2 = rhs.chroma
//		if abs(chroma1 - chroma2) > 0.01 { return chroma1 < chroma2 }
//		return lhs.L < rhs.L
//	}

	/// by Luminance
//	static func < (lhs: Self, rhs: Self) -> Bool {
//		if abs(lhs.L - rhs.L) > 0.01 { return lhs.L < rhs.L }
//		if abs(lhs.a - rhs.a) > 0.01 { return lhs.a < rhs.a }
//		return lhs.b < rhs.b
//	}

	/// 4×4×4 bin index (0...63)
	func toQuantized64() -> Int {
		let lBin = Int(L * 255) >> 6
		let aBin = Int((a + 0.4) * 319) >> 6
		let bBin = Int((b + 0.4) * 319) >> 6
		return (lBin << 4) | (aBin << 2) | bBin
	}

	func toQuantized(by levels: Int) -> Int {
		let lBin = min(levels - 1, max(0, Int(L * Double(levels))))
		let aBin = min(levels - 1, max(0, Int((a + 0.4) * Double(levels) / 0.8)))
		let bBin = min(levels - 1, max(0, Int((b + 0.4) * Double(levels) / 0.8)))

		return lBin * levels * levels + aBin * levels + bBin
	}

	/// 4->2, 8->3, 16->4
	func toQuantizedPow2(shift: Int, levels: Int) -> Int {
		// let shift = Int(log2(Double(levels)))
		let mask = levels - 1

		let lBin = min(mask, max(0, Int(L * Double(levels))))
		let aBin = min(mask, max(0, Int((a + 0.4) * Double(levels) / 0.8)))
		let bBin = min(mask, max(0, Int((b + 0.4) * Double(levels) / 0.8)))

		return (lBin << (shift * 2)) | (aBin << shift) | bBin
	}

	init(binIndex bin: Int, levels: Int) {
		let lBin = bin / (levels * levels)
		let aBin = (bin / levels) % levels
		let bBin = bin % levels

		let L = (Double(lBin) + 0.5) / Double(levels)
		let a = (Double(aBin) + 0.5) * 0.8 / Double(levels) - 0.4
		let b = (Double(bBin) + 0.5) * 0.8 / Double(levels) - 0.4

		self.ch = (L, a, b)
	}
}

extension OKLAB: DeltaE {

	public func distance(from c: OKLAB) -> Double {
		let deltaL = self.L - c.L
		let deltaA = self.a - c.a
		let deltaB = self.b - c.b

		return sqrt( sq(deltaL) + sq(deltaA) + sq(deltaB) )
	}

	public func distanceWeighted(from c: OKLAB, lightnes: Double = 1, power: Double = 1.5) -> Double {
		
		let deltaL = self.L - c.L
		let deltaA = self.a - c.a
		let deltaB = self.b - c.b

//		let sign = deltaL >= 0 ? 1.0 : -1.0
//		let weightedDL = sign * pow(abs(deltaL), power) * lightnes
		let weightedDL = pow(abs(deltaL), power) * lightnes
		
		return sqrt( sq(weightedDL) + sq(deltaA) + sq(deltaB) )
//		return ( sq(weightedDL) + sq(deltaA) + sq(deltaB) )
	}

}
