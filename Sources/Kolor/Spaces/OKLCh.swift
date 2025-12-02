import Foundation

/// OKLAB-LCH color space, in cylindrical forms.
///
public struct OKLCh: Kolor {

	public var ch: Channels

	/// `Lightness` component [0...1]
	public var L: Double { get { ch.0 } set { ch.0 = newValue } }
	/// `Chroma` component [0...0.5] 
	public var C: Double { get { ch.1 } set { ch.1 = newValue } }
	/// `Hue` component [0...360]
	public var h: Double { get { ch.2 } set { ch.2 = newValue } }

	
	public var ranges: CompRanges { (0...1, 0...0.5, 0...360) }

	public init(ch: Channels) { self.ch = (ch.0, ch.1, ch.2) }

	/// Raw Init
	public init(L: Double = 0, C: Double = 0, h: Double = 0) { self.ch = (L, C, h) }

	public init(r: Double, g: Double, b: Double) {
		let oklab = OKLAB(r: r, g: g, b: b)
		let C = sqrt(oklab.a * oklab.a + oklab.b * oklab.b)
		let h = atan2(oklab.b, oklab.a)
		self.ch = (oklab.L, C, h)
	}

	public func normalized() -> Channels { (ch.0, ch.1 * 2, ch.2 / 360) }

}

extension OKLCh: Cylindrical {

	// TODO: Normalize ?
	public var s: Double { get { ch.1 * 2 } set { ch.1 = newValue * 0.5 } }
	public var v: Double { get { ch.0 } set { ch.0 = newValue } }
	
	public init(h: Double, s: Double, v: Double) {
		self.ch = (v, s*0.5, h)
	}
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
		
		return sqrt(deltaL * deltaL + deltaA * deltaA + deltaB * deltaB)
//		return deltaL * deltaL + deltaA * deltaA + deltaB * deltaB
	}
}
