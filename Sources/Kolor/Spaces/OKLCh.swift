import Foundation

/// OKLAB-LCH color space, in cylindrical forms.
/// https://oklch.com
///
public struct OKLCh: Kolor {

	public var ch: Channels

	/// `Lightness` component [0...1]
	public var L: Double { get { ch.0 } set { ch.0 = newValue } }
	/// `Chroma` component [0...0.37]
	public var C: Double { get { ch.1 } set { ch.1 = newValue } }
	/// `Hue` component [0...2π] ≈ 6.283185307179586
	public var h: Double { get { ch.2 } set { ch.2 = newValue } }

	public static var ranges: CompRanges { (0...1, 0...0.37, 0...1) }

	public init(ch: Channels) { self.ch = (ch.0, ch.1, ch.2) }

	/// Raw Init
	public init(L: Double = 0, C: Double = 0, h: Double = 0) { self.ch = (L, C, h) }

	public init(r: Double, g: Double, b: Double) {
		let oklab = OKLAB(r: r, g: g, b: b)
		let C = sqrt( sq(oklab.a) + sq(oklab.b) )
		let h = atan2(oklab.b, oklab.a)
		self.ch = (oklab.L, C, h)
	}

	public init(normX: Double, normY: Double, normZ: Double) { self.ch = (normX, normY * 0.37, normZ * 6.283185307179586) }
	
	public func normalized() -> Channels {
		print(h,  h * 180 / Double.pi)
		return (ch.0, ch.1 / 0.37, ch.2 / 6.283185307179) }

}

public extension OKLCh {

	func toOKLAB() -> OKLAB {
		let a = self.C * cos(self.h)
		let b = self.C * sin(self.h)

		return OKLAB(L: self.L, a: a, b: b)
	}

	func toRGB() -> RGB {
		self.toOKLAB().toRGB()
	}

}

extension OKLCh: Cylindrical {
	
	// TODO: Normalize ?
	public var val: Double { get { ch.0 } set { ch.0 = newValue } }
	public var sat: Double { get { ch.1 / 0.37 } set { ch.1 = newValue * 0.37 } }
	public var hue: Double { get { ch.2 * Double.pi / 180 } set { ch.2 = newValue * 180 / Double.pi } }
	
	public init(hue: Double, sat: Double, val: Double) {
		self.ch = (val, sat * 0.37, hue * 180 / Double.pi)
	}
}


extension OKLCh: DeltaE {
	
	public func distance(from c: OKLCh) -> Double {

		let h1Rad = self.h * Double.pi / 180.0
		let h2Rad = c.h * Double.pi / 180.0
		
		// OKLCh -> OKLab
		let a1 = self.C * cos(h1Rad)
		let a2 = c.C * cos(h2Rad)
		let b1 = self.C * sin(h1Rad)
		let b2 = c.C * sin(h2Rad)
		
		let deltaL = self.L - c.L
		let deltaA = a1 - a2
		let deltaB = b1 - b2
		
		return sqrt( sq(deltaL) + sq(deltaA) + sq(deltaB) )
	}
}
