import Foundation

/// CIE DIN99o color space using D65 as reference white, in Cartesian form.
///
public struct DIN99: Kolor {

	public static var ranges: CompRanges { (0...1, -1...1, -1...1) }

	public var ch: Channels

	/// `Lightness` component [0...1]
	public var L99o: Double { get { ch.0 } set { ch.0 = newValue } }
	/// `A` (Green-Red) component [-1...1] ~(-40.09, 45.501)
	public var a99o: Double { get { ch.1 } set { ch.1 = newValue } }
	/// `B` (Blue-Yellow) component [-1...1] ~(-40.469, 44.344)
	public var b99o: Double { get { ch.2 } set { ch.2 = newValue } }

	public init(ch: Channels) { self.ch = ch }

	/// Raw Init
	public init(L99o: Double = 0, a99o: Double = 0, b99o: Double = 0) { self.ch = (L99o, a99o, b99o) }

	/// CIE LAB
	public init(L: Double, a: Double, b: Double) {
		let kE = 1.0
		let kCH = 1.0

		let L99o = 303.67 / kE * log(1.0 + 0.0039 * L)
		let e = a * cos(26.0 * .pi / 180.0) + b * sin(26.0 * .pi / 180.0)
		let f = 0.83 * (b * cos(26.0 * .pi / 180.0) - a * sin(26.0 * .pi / 180.0))
		let G = sqrt(e * e + f * f)

		let C99o = (23.0 * log(1.0 + 0.075 * G)) / (kCH * kE)
		let h99o = atan2(f, e) + 26.0 * .pi / 180.0
		let a99o = C99o * cos(h99o)
		let b99o = C99o * sin(h99o)

		self.ch = (L99o, a99o, b99o)
	}

	public init(r: Double, g: Double, b: Double) {
		//		let lab = LAB(r: r, g: g, b: b)
		//		self.init(CIELabL: L, a: a, b: b)
		fatalError()
	}

	public init(normX: Double, normY: Double, normZ: Double) { self.ch = (normX * 360, normY, normZ) }

	public func normalized() -> Channels { (ch.0, (ch.1 / 2) + 0.5, (ch.2 / 2) + 0.5) }

}

public extension DIN99 {

	func toLAB() -> LAB {
		let kE = 1.0
		let kCH = 1.0

		// 1. L99o-ból L* visszafejtése
		let L = (exp((L99o * kE) / 303.67) - 1.0) / 0.0039

		// 2. Cartesian-ból polár koordinátákba
		let c99o = sqrt(a99o * a99o + b99o * b99o)
		let h99o = atan2(b99o, a99o)

		// 3. G visszafejtése
		let G = (exp(0.0435 * c99o * kCH * kE) - 1.0) / 0.075

		// 4. e és f visszafejtése (26° kompenzáció)
		let e = G * cos(h99o - 26.0 * .pi / 180.0)
		let f = G * sin(h99o - 26.0 * .pi / 180.0)

		// 5. a* és b* visszafejtése (inverz forgatás)
		let a = e * cos(26.0 * .pi / 180.0) - (f / 0.83) * sin(26.0 * .pi / 180.0)
		let b = e * sin(26.0 * .pi / 180.0) + (f / 0.83) * cos(26.0 * .pi / 180.0)

		return LAB(L: L, a: a, b: b)
		//		return LAB(L: L / 100, a: a / 100, b: b / 100)
	}

	func toRGB() -> RGB {
		self.toLAB().toRGB()
	}

}

extension DIN99: DeltaE {

	public func distance(from c: DIN99) -> Double {
		let deltaL = self.L99o - c.L99o
		let deltaa = self.a99o - c.a99o
		let deltab = self.b99o - c.b99o

		return sqrt(deltaL * deltaL + deltaa * deltaa + deltab * deltab)
	}

}
