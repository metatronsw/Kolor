import Foundation

public struct HSV: Kolor {

	public var ch: Channels

	/// `Hue` component [0...360]
	public var h: Double { get { ch.0 } set { ch.0 = newValue } }
	/// `Saturation` component [0...1]
	public var s: Double { get { ch.1 } set { ch.1 = newValue } }
	/// `Value` or `Brightness` component [0...1]
	public var v: Double { get { ch.2 } set { ch.2 = newValue } }

	public static var ranges: CompRanges { (0...360, 0...1, 0...1) }

	public init(ch: Channels) { self.ch = (ch.0, ch.1, ch.2) }

	/// Raw Init
	public init(h: Double = 0, s: Double = 0, v: Double = 0) { self.ch = (h, s, v) }

	public init(r: Double, g: Double, b: Double) {
		let min = min(min(r, g), b)
		let v = max(max(r, g), b)
		let C = v - min

		let s = (v == 0) ? 0.0 : C / v
		var h = 0.0

		if min != v {
			if v == r { h = ((g - b) / C).truncatingRemainder(dividingBy: 6.0) }
			else if v == g { h = (b - r) / C + 2.0 }
			else if v == b { h = (r - g) / C + 4.0 }

			h *= 60
			if h < 0 { h += 360 }
		}

		self.ch = (h, s, v)
	}

	public init(normX: Double, normY: Double, normZ: Double) { self.ch = (normX * 360, normY, normZ) }

	public func normalized() -> Channels { (ch.0 / 360.0, ch.1, ch.2) }

}

public extension HSV {

	func formatted() -> (x: String, y: String, z: String) {
		(x: String(format: "%.1f%%", ch.0),
		 y: String(format: "%.1f%%", ch.1 * 100),
		 z: String(format: "%.1f%%", ch.2 * 100))
	}

	func toRGB() -> RGB {
		let Hp = h / 60
		let C = v * s
		let X = C * (1 - abs(Hp.truncatingRemainder(dividingBy: 2) - 1))

		let m = v - C
		var (r, g, b) = (0.0, 0.0, 0.0)

		if Hp >= 0, Hp < 1 {
			r = C
			g = X
		} else if Hp >= 1, Hp < 2 {
			r = X
			g = C
		} else if Hp >= 2, Hp < 3 {
			g = C
			b = X
		} else if Hp >= 3, Hp < 4 {
			g = X
			b = C
		} else if Hp >= 4, Hp < 5 {
			r = X
			b = C
		} else if Hp >= 5, Hp < 6 {
			r = C
			b = X
		}

		return RGB(r: m + r, g: m + g, b: m + b)
	}

	static func lerp360(degA: Double, degB: Double, t: Double) -> Double {
		let delta = ((degB - degA).truncatingRemainder(dividingBy: 360) + 540).truncatingRemainder(dividingBy: 360) - 180
		return (degA + t * delta + 360).truncatingRemainder(dividingBy: 360)
	}

	static func distance(degA: Double, degB: Double) -> Double {
		return 180 - abs(fmod(abs(degA - degB), 360) - 180)
	}

	func distance(_ col: HSV) -> Double {
		let dh = min(abs(h - col.h), 360 - abs(h - col.h)) / 180
		let ds = abs(s - col.s)
		let dv = abs(v - col.v) / 255

		return sqrt(dh * dh + ds * ds + dv * dv)
	}

	func blend(col: HSV, t: Double) -> HSV {
		var h1 = self.h
		var h2 = col.h

		if self.s == 0, col.s != 0 { h1 = col.h }
		else if col.s == 0, self.s != 0 { h2 = h1 }

		let hue = Self.lerp360(degA: h1, degB: h2, t: t)
		let sat = s + t * (col.s - s)
		let val = v + t * (col.v - v)

		return HSV(h: hue, s: sat, v: val)
	}

}

extension HSV: Cylindrical { 
	
	public var hue: Double { get { ch.0 } set { ch.0 = newValue } }
	public var sat: Double { get { ch.1 } set { ch.1 = newValue } }
	public var val: Double { get { ch.2 } set { ch.2 = newValue } }
	
	public init(hue: Double, sat: Double, val: Double) {
		self.ch = (hue, sat, val)
	}
	
}

public extension HSV {

	static func fastHappyPalette(count: Int) -> [HSV] {
		var colors = [HSV]()
		colors.reserveCapacity(count)

		let x = 360.0 / Double(count)

		for i in 0..<count {
			colors.append(
				HSV(h: Double(i) * x,
					 s: 0.8 + Double.random(in: 0...1) * 0.2,
					 v: 0.65 + Double.random(in: 0...1) * 0.2)
			)
		}

		return colors
	}

	static func fastWarmPalette(count: Int) -> [HSV] {
		var colors = [HSV]()
		colors.reserveCapacity(count)

		let x = 360.0 / Double(count)

		for i in 0..<count {
			colors.append(
				HSV(h: Double(i) * x,
					 s: 0.55 + Double.random(in: 0...1) * 0.2,
					 v: 0.35 + Double.random(in: 0...1) * 0.2)
			)
		}

		return colors
	}

}
