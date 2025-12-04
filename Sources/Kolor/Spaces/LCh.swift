import Foundation

/// CIE L*C*h(uv) LUV Color Space polar coordinate form
/// using the D50 standard illuminant.
///
public struct LCh: Kolor {

	public var ch: Channels

	/// `Lightness` component [0...1]
	public var l: Double { get { ch.0 } set { ch.0 = newValue } }
	/// `Chroma` component [0...1]
	public var c: Double { get { ch.1 } set { ch.1 = newValue } }
	/// `Hue` component [0...360]
	public var h: Double { get { ch.2 } set { ch.2 = newValue } }

	public static var ranges: CompRanges { (0...1, 0...1, 0...360) }

	public init(ch: Channels) { self.ch = (ch.0, ch.1, ch.2) }

	/// Raw Init
	public init(l: Double = 0, c: Double = 0, h: Double = 0) { self.ch = (l, c, h) }

	public init(l: Double, u: Double, v: Double) {
		let c, h: Double

		if abs(v - u) > 1e-4, abs(u) > 1e-4 {
			h = (57.29577951308232087721 * atan2(v, u) + 360.0).truncatingRemainder(dividingBy: 360.0) // Rad2Deg
		} else {
			h = 0.0
		}

		c = sqrt(sq(u) + sq(v))

		self.ch = (l, c, h)
	}

	public init(r: Double, g: Double, b: Double) {
		let luv = XYZ(r: r, g: g, b: b).toLUV()
		self.init(l: luv.l, u: luv.u, v: luv.v)
	}

	public init(normX: Double, normY: Double, normZ: Double) { self.ch = (normX, normY, normZ) }

	public func normalized() -> Channels { (ch.0, ch.1, ch.2 / 360) }

}

public extension LCh {

	func toRGB() -> RGB { self.toLUV().toXYZ().toRGB() }

	func toLUV() -> LUV {
		let H = 0.01745329251994329576 * h // Deg2Rad
		let u = c * cos(H)
		let v = c * sin(H)

		return LUV(l: l, u: u, v: v)
	}

	func toHSLuv() -> HSLuv { HSLuv(l: l, c: c, h: h) }

	func toHSLuvPastel() -> HSLuv { HSLuv(Pastel: l, c: c, h: h) }

	func blend(c: LCh, t: Double) -> LCh {
		LCh(l: l + t * (c.l - l),
			 c: self.c + t * (self.c - c.c),
			 h: HSV.lerp360(degA: h, degB: c.h, t: t))
	}

}

extension LCh: Cylindrical {

	public var val: Double { get { ch.0 } set { ch.0 = newValue } }
	public var sat: Double { get { ch.1 } set { ch.1 = newValue } }
	public var hue: Double { get { ch.2 } set { ch.2 = newValue } }
	
	public init(hue: Double, sat: Double, val: Double) {
		self.ch = (val, sat, hue)
	}

}
