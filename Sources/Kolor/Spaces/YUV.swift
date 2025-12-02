import Foundation

public struct YUV: Kolor {

	public var ch: Channels

	/// `Cyan` component [0...1]
	public var y: Double { get { ch.0 } set { ch.0 = newValue } }
	/// `Magenta` component [0...1]
	public var u: Double { get { ch.1 } set { ch.1 = newValue } }
	/// `Yellow` component [0...1]
	public var v: Double { get { ch.2 } set { ch.2 = newValue } }

	public var ranges: CompRanges { (0...1, 0...1, 0...1) }

	public init(ch: Channels) { self.ch = (ch.0, ch.1, ch.2) }

	/// Raw Init
	public init(y: Double = 0, u: Double = 0, v: Double = 0) { self.ch = (y, u, v) }

	public init(r: Double, g: Double, b: Double) {
		let y = 0.257 * r + 0.504 * g + 0.098 * b + 16
		let u = -0.148 * r - 0.291 * g + 0.439 * b + 128
		let v = 0.439 * r - 0.368 * g - 0.071 * b + 128

		self.ch = (y, u, v)
	}

	public func normalized() -> Channels { (ch.0, ch.1, ch.2) }

}

public extension YUV {

	func toRGB() -> RGB {
		let Y = self.y - 16
		let U = self.u - 128
		let V = self.v - 128

		let r = 1.164 * Y + 1.596 * V
		let g = 1.164 * Y - 0.392 * U - 0.813 * V
		let b = 1.164 * Y + 2.017 * U

		return RGB(r: r, g: g, b: b)
	}

}
