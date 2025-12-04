import Foundation

/// HSLuv is a human-friendly alternative to HSL.
/// https://www.hsluv.org
///
public struct HSLuv: Kolor {

	public var ch: Channels

	/// `Hue` component [0...360]
	public var h: Double { get { ch.0 } set { ch.0 = newValue } }
	/// `Saturation` component [0...1]
	public var s: Double { get { ch.1 } set { ch.1 = newValue } }
	/// `Luminance` component [0...1]
	public var l: Double { get { ch.2 } set { ch.2 = newValue } }

	public static var ranges: CompRanges { (0...360, 0...1, 0...1) }

	public init(ch: Channels) { self.ch = (ch.0, ch.1, ch.2) }

	/// Raw Init
	public init(h: Double = 0, s: Double = 0, l: Double = 0) { self.ch = (h, s, l) }

	public init(l: Double, c: Double, h: Double) {
		
		let l: Double = l * 100
		let c: Double = c * 100

		var s, maxi: Double
		if l > 99.9999999 || l < 0.00000001 { s = 0 }
		else {
			maxi = Self.maxChromaForLH(l: l, h: h)
			s = c / maxi * 100
		}

		self.ch = (h, max(0, min((s / 100), 1)), max(0, min((l / 100), 1)))
	}

	/// Note that HPLuv can only represent pastel colors, and so the Saturation !> 1
	public init(Pastel l: Double, c: Double, h: Double) {
		let c: Double = c * 100
		let l: Double = l * 100

		var s, maxi: Double
		if l > 99.9999999 || l < 0.00000001 { s = 0 }
		else {
			maxi = Self.maxSafeChromaForL(l)
			s = c / maxi * 100
		}

		self.ch = (h, max(0, min((s / 100), 1)), max(0, min((l / 100), 1)))
	}

	/// RGB(Double) -> LinearRGB -> XYZ -> LUV -> LCh(uv) -> HSLuv
	public init(r: Double, g: Double, b: Double) {
		let LCh = XYZ(r: r, g: g, b: b).toLUV(WhiteRef: .hSLuvD65).toLCh()
		self.init(l: LCh.l, c: LCh.c, h: LCh.h)
	}

	public init(normX: Double, normY: Double, normZ: Double) { self.ch = (normX * 360, normY, normZ) }
	
	public func normalized() -> Channels { (ch.0 / 360.0, ch.1, ch.2) }

}

extension HSLuv {
	
	static let kappa = 903.2962962962963
	static let epsilon = 0.0088564516790356308
	
	static let m: [[Double]] = [
		[3.2409699419045214, -1.5373831775700935, -0.49861076029300328],
		[-0.96924363628087983, 1.8759675015077207, 0.041555057407175613],
		[0.055630079696993609, -0.20397695888897657, 1.0569715142428786],
	]
	
	static func lengthOfRayUntilIntersect(theta: Double, x: Double, y: Double) -> Double {
		y / (sin(theta) - x * cos(theta))
	}
	
	static func maxChromaForLH(l: Double, h: Double) -> Double {
		let hRad = h / 360.0 * Double.pi * 2.0
		var minLength = Double.greatestFiniteMagnitude
		
		for line in getBounds(l) {
			let length = lengthOfRayUntilIntersect(theta: hRad, x: line[0], y: line[1])
			if length > 0.0, length < minLength {
				minLength = length
			}
		}
		return minLength
	}
	
	static func maxSafeChromaForL(_ l: Double) -> Double {
		var minLength = Double.greatestFiniteMagnitude
		
		for line in getBounds(l) {
			let m1 = line[0]
			let b1 = line[1]
			let x = intersectLineLine(x1: m1, y1: b1, x2: -1.0 / m1, y2: 0.0)
			let dist = distanceFromPole(x: x, y: b1 + x * m1)
			if dist < minLength {
				minLength = dist
			}
		}
		return minLength
	}
	
	static func getBounds(_ l: Double) -> [[Double]] {
		var sub2: Double
		var ret = [[Double]](repeating: [Double](repeating: Double(), count: 2), count: 6)
		let sub1 = pow(l + 16.0, 3.0) / 1_560_896.0
		
		if sub1 > epsilon {
			sub2 = sub1
		} else {
			sub2 = l / kappa
		}
		
		for (i, _) in m.enumerated() {
			for k in 0..<2 {
				let top1: Double = (284_517.0 * m[i][0] - 94839.0 * m[i][2]) * sub2
				let top2: Double = (838_422.0 * m[i][2] + 769_860.0 * m[i][1] + 731_718.0 * m[i][0]) * l * sub2 - 769_860.0 * Double(k) * l
				let bottom: Double = (632_260.0 * m[i][2] - 126_452.0 * m[i][1]) * sub2 + 126_452.0 * Double(k)
				ret[i * 2 + k][0] = top1 / bottom
				ret[i * 2 + k][1] = top2 / bottom
			}
		}
		return ret
	}
	
	static func intersectLineLine(x1: Double, y1: Double, x2: Double, y2: Double) -> Double {
		(y1 - y2) / (x2 - x1)
	}
	
	static func distanceFromPole(x: Double, y: Double) -> Double {
		sqrt(pow(x, 2.0) + pow(y, 2.0))
	}
	
}

public extension HSLuv {
	
	func formatted() -> (x: String, y: String, z: String) {
		(x: String(format: "%.1f%%", ch.0),
		 y: String(format: "%.1f%%", ch.1 * 100),
		 z: String(format: "%.1f%%", ch.2 * 100))
	}
	
	func toRGB() -> RGB {
		self.toLCh().toLUV().toXYZ(WhiteRef: .hSLuvD65).toRGB()
	}
	
	func toLCh() -> LCh {
		let s = s * 100
		let l = l * 100
		
		var c, maxi: Double
		if l > 99.9999999 || l < 0.00000001 { c = 0 }
		else {
			maxi = HSLuv.maxChromaForLH(l: l, h: h)
			c = maxi / 100.0 * s
		}
		
		return LCh(l: max(0, min((l / 100), 1)), c: c / 100.0, h: h)
	}
}

extension HSLuv: Cylindrical {
	
	public var hue: Double { get { ch.0 } set { ch.0 = newValue } }
	public var sat: Double { get { ch.1 } set { ch.1 = newValue } }
	public var val: Double { get { ch.2 } set { ch.2 = newValue } }
	
	public init(hue: Double, sat: Double, val: Double) {
		self.ch = (hue, sat, val)
	}
	
}

extension HSLuv: DeltaE {
	
	public func distance(from c: HSLuv) -> Double {
		sqrt(sq((h - c.h) / 100.0) + sq(s - c.s) + sq(l - c.l))
	}
	
}
