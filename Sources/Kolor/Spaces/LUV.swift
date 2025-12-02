import Foundation

/// CIELUV: CIE 1976 L*, u*, v* color space
/// Cartesian (Luv) and cylindrical (LCh) forms, using the D50 standard illuminant.
///
public struct LUV: Kolor {

	public var ch: Channels

	/// `Lightness` component [0...1] (0, 100)
	public var l: Double { get { ch.0 } set { ch.0 = newValue } }
	/// `U` (Green-Red) component [0...1] (-84.936, 175.042)≈
	public var u: Double { get { ch.1 } set { ch.1 = newValue } }
	/// `V` (Blue-Yellow) component [0...1] (-125.882, 87.243)≈
	public var v: Double { get { ch.2 } set { ch.2 = newValue } }

	public var ranges: CompRanges { (0...1, 0...1, 0...1) }

	public init(ch: Channels) { self.ch = (ch.0, ch.1, ch.2) }

	/// Raw Init
	public init(l: Double = 0, u: Double = 0, v: Double = 0) {
		self.ch = (l, u, v)
	}

	public init(x: Double, y: Double, z: Double, WhiteRef w: XYZ = .D65) {
		let l, u, v: Double

		if y / w.y <= 6.0 / 29.0 * 6.0 / 29.0 * 6.0 / 29.0 {
			l = y / w.y * (29.0 / 3.0 * 29.0 / 3.0 * 29.0 / 3.0) / 100.0
		} else {
			l = 1.16 * cbrt(y / w.y) - 0.16
		}

		let (ubis, vbis) = XYZ(x: x, y: y, z: z).to_UV()
		let (un, vn) = w.to_UV()

		u = 13.0 * l * (ubis - un)
		v = 13.0 * l * (vbis - vn)

		self.ch = (l, u, v)
	}

	public init(r: Double, g: Double, b: Double) {
		let xyz = XYZ(r: r, g: g, b: b)
		self.init(x: xyz.x, y: xyz.y, z: xyz.z, WhiteRef: .D65)
	}

	public func normalized() -> Channels { (ch.0, ch.1, ch.2) }

}

public extension LUV {

	func toXYZ(WhiteRef w: XYZ = .D65) -> XYZ {
		var x, y, z: Double

		if l <= 0.08 {
			y = w.y * l * 100.0 * 3.0 / 29.0 * 3.0 / 29.0 * 3.0 / 29.0
		} else {
			y = w.y * cub((l + 0.16) / 1.16)
		}

		let (un, vn) = w.to_UV()

		if l != 0.0 {
			let ubis = u / (13.0 * l) + un
			let vbis = v / (13.0 * l) + vn
			x = y * 9.0 * ubis / (4.0 * vbis)
			z = y * (12.0 - 3.0 * ubis - 20.0 * vbis) / (4.0 * vbis)
		} else {
			(x, y, z) = (0.0, 0.0, 0.0)
		}

		return XYZ(x: x, y: y, z: z)
	}

	func toLCh() -> LCh { LCh(l: l, u: u, v: v) }

	func toRGB() -> RGB { self.toXYZ().toRGB() }

}

public extension LUV {
	func blend(c: LUV, t: Double) -> LUV {
		LUV(l: l + t * (c.l - l), u: u + t * (c.u - u), v: v + t * (c.v - v))
	}
}

extension LUV: DeltaE {

	public func distance(from c: LUV) -> Double {
		sqrt(sq(l - c.l) + sq(u - c.u) + sq(v - c.v))
	}

}
