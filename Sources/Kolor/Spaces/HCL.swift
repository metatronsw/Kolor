import Foundation

/// CIE L*a*b* HCL polar coordinate form
///
public struct HCL: Kolor {

	public var ch: Channels

	/// `Hue` component [0...360]
	public var h: Double { get { ch.0 } set { ch.0 = newValue } }
	/// `Colorfulness` component [0...1]
	public var c: Double { get { ch.1 } set { ch.1 = newValue } }
	/// `Luminance` component [0...1]
	public var l: Double { get { ch.2 } set { ch.2 = newValue } }

	public var ranges: CompRanges { (0...360, 0...1, 0...1) }

	public init(ch: Channels) { self.ch = (ch.0, ch.1, ch.2) }

	/// Raw Init
	public init(h: Double = 0, c: Double = 0, l: Double = 0) { self.ch = (h, c, l) }

	public init(l: Double, a: Double, b: Double) {
		let h: Double

		if abs(b - a) > 1e-4, abs(a) > 1e-4 {
			h = (57.29577951308232087721 * atan2(b, a) + 360.0).truncatingRemainder(dividingBy: 360.0) // Rad2Deg
		} else {
			h = 0.0
		}

		let c = sqrt(sq(a) + sq(b))

		self.ch = (h, c, l)
	}

	public init(r: Double, g: Double, b: Double) {
		let lab = XYZ(r: r, g: g, b: b).toLAB()
		self.init(l: lab.L, a: lab.a, b: lab.b)
	}

	public func normalized() -> Channels { (ch.0 / 360.0, ch.1, ch.2) }

}

public extension HCL {

	func formatted(decimals d: Int = 3) -> String {
		String(format: "%.\(d)f ", ch.0) +
			String(format: "%.\(d)f ", ch.1 * 100) +
			String(format: "%.\(d)f", ch.2 * 100)
	}

	func toLAB() -> LAB {
		let H = 0.01745329251994329576 * h // Deg2Rad
		let a = c * cos(H)
		let b = c * sin(H)

		return LAB(L: l, a: a, b: b)
	}

	func toRGB() -> RGB {
		self.toLAB().toXYZ().toRGB().toClamped()
	}

	func blend(col: HCL, t: Double) -> HCL {
		var h1 = self.h
		var h2 = col.h

		if c <= 0.00015, col.c >= 0.00015 { h1 = h2 }
		else if col.c <= 0.00015, c >= 0.00015 { h2 = h1 }

		let H = HSV.lerp360(degA: h1, degB: h2, t: t)
		let C = c + t * (col.c - c)
		let L = l + t * (col.l - l)

		return HCL(h: H, c: C, l: L)
	}

}

extension HCL: Cylindrical {
	
	public var s: Double { get { ch.1 } set { ch.1 = newValue } }
	public var v: Double { get { ch.0 } set { ch.0 = newValue } }
	
	public init(h: Double, s: Double, v: Double) {
		self.ch = (h, s, v)
	}

}
