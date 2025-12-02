import Foundation

/// Not part of KOLOR Protocol
///
public struct CMYK: Hashable, CustomStringConvertible {

	/// `Cyan` component [0...1]
	public let c: Double
	/// `Magenta` component [0...1]
	public let m: Double
	/// `Yellow` component [0...1]
	public let y: Double
	/// `Key` or `Black` component [0...1]
	public let k: Double

	/// Raw Init
	init(c: Double = 0, m: Double = 0, y: Double = 0, k: Double = 0) {
		self.c = c
		self.m = m
		self.y = y
		self.k = k
	}

}

public extension CMYK {

	init(r: Double = 0, g: Double = 0, b: Double = 0) {
		let k = 1 - max(r, b, g)

		if k == 1.0 {
			self.init(c: 0, m: 0, y: 0, k: 1)
			return
		}

		let c = (1 - r - k) / (1 - k)
		let m = (1 - g - k) / (1 - k)
		let y = (1 - b - k) / (1 - k)

		self.init(c: c, m: m, y: y, k: k)
	}

	var description: String {
		String(format: "[%.3f %.3f %.3f %.3f]", c, m, y, k)
	}

	func toRGB() -> RGB {
		let r = (1 - c) * (1 - k)
		let g = (1 - m) * (1 - k)
		let b = (1 - y) * (1 - k)

		return RGB(r: r, g: g, b: b)
	}

	func toSRGB() -> sRGB { self.toRGB().toSRGB() }

}
