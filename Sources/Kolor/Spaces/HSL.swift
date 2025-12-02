import Foundation

public struct HSL: Kolor {

	public var ch: Channels

	/// `Hue` component [0...360]
	public var h: Double { get { ch.0 } set { ch.0 = newValue } }
	/// `Saturation` component [0...1]
	public var s: Double { get { ch.1 } set { ch.1 = newValue } }
	/// `Lightness` component [0...1]
	public var l: Double { get { ch.2 } set { ch.2 = newValue } }

	public var ranges: CompRanges { (0...360, 0...1, 0...1) }

	public init(ch: Channels) { self.ch = (ch.0 * 360, ch.1, ch.2) }

	/// Raw Init
	public init(h: Double = 0, s: Double = 0, l: Double = 0) { self.ch = (h, s, l) }

	public init(r: Double, g: Double, b: Double) {
		let min = min(min(r, g), b)
		let max = max(max(r, g), b)

		let l = (max + min) / 2

		let s: Double
		var h: Double

		if min == max { s = 0; h = 0 }
		else {
			if l < 0.5 { s = (max - min) / (max + min) }
			else { s = (max - min) / (2.0 - max - min) }

			if max == r { h = (g - b) / (max - min) }
			else if max == g { h = 2.0 + (b - r) / (max - min) }
			else { h = 4.0 + (r - g) / (max - min) }

			h *= 60

			if h < 0 { h += 360 }
		}

		self.ch = (h, s, l)
	}

	public func normalized() -> Channels { (ch.0 / 360.0, ch.1, ch.2) }

}

public extension HSL {

	func formatted() -> (x: String, y: String, z: String) {
		(x: String(format: "%.1f%%", ch.0),
		 y: String(format: "%.1f%%", ch.1 * 100),
		 z: String(format: "%.1f%%", ch.2 * 100))
	}

	func toHSV() -> HSV {
		var s = self.s
		var l = self.l

		var smin = s
		let lmin = max(l, 0.01)

		l *= 2
		s *= (l <= 1) ? l : 2 - l
		smin *= (lmin <= 1) ? lmin : 2 - lmin
		let v = (l + s) / 2
		let sv = (l == 0.0) ? ((2 * smin) / (lmin + smin)) : ((2 * s) / (l + s))

		return HSV(h: h, s: sv, v: v)
	}

	func toRGB() -> RGB {
		guard s != 0 else { return RGB(r: l, g: l, b: l) }

		var r, g, b: Double
		var t1, t2, tr, tg, tb: Double

		if l < 0.5 { t1 = l * (1.0 + s) }
		else { t1 = l + s - l * s }

		t2 = 2 * l - t1
		let h = h / 360
		tr = h + 1.0 / 3.0
		tg = h
		tb = h - 1.0 / 3.0

		if tr < 0 { tr += 1 }
		if tr > 1 { tr -= 1 }
		if tg < 0 { tg += 1 }
		if tg > 1 { tg -= 1 }
		if tb < 0 { tb += 1 }
		if tb > 1 { tb -= 1 }

		if 6 * tr < 1 { r = t2 + (t1 - t2) * 6 * tr }
		else if 2 * tr < 1 { r = t1 }
		else if 3 * tr < 2 { r = t2 + (t1 - t2) * (2.0 / 3.0 - tr) * 6 }
		else { r = t2 }

		if 6 * tg < 1 { g = t2 + (t1 - t2) * 6 * tg }
		else if 2 * tg < 1 { g = t1 }
		else if 3 * tg < 2 { g = t2 + (t1 - t2) * (2.0 / 3.0 - tg) * 6 }
		else { g = t2 }

		if 6 * tb < 1 { b = t2 + (t1 - t2) * 6 * tb }
		else if 2 * tb < 1 { b = t1 }
		else if 3 * tb < 2 { b = t2 + (t1 - t2) * (2.0 / 3.0 - tb) * 6 }
		else { b = t2 }

		return RGB(r: r, g: g, b: b)
	}

}

extension HSL: Cylindrical {
	
	public var v: Double { get { ch.0 } set { ch.0 = newValue } }
	
	public init(h: Double, s: Double, v: Double) {
		self.ch = (h, s, v)
	}
	
}

	
//
//	static func paletteGen(div: Int, saturation: Double = 0.5, lightness: Double = 0.5) -> [HSL] {
//		let spectrum = 359.0 / Double(div)
//		var palette = [HSL]()
//		var h = 0.0
//
//		while h <= 360.0 {
//			palette.append(HSL(h: h, s: saturation, l: lightness))
//			h += spectrum
//		}
//
//		return palette
//	}
//
