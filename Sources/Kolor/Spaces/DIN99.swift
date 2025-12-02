import Foundation

/// CIE DIN99o color space using D65 as reference white, in Cartesian form.
///
public struct DIN99: Kolor {

	public var ch: Channels

	/// `Lightness` component [0...1]
	public var L99o: Double { get { ch.0 } set { ch.0 = newValue } }
	/// `A` (Green-Red) component [-1...1] (-40.09, 45.501)≈
	public var a99o: Double { get { ch.1 } set { ch.1 = newValue } }
	/// `B` (Blue-Yellow) component [-1...1] (-40.469, 44.344)≈
	public var b99o: Double { get { ch.2 } set { ch.2 = newValue } }

	public var ranges: CompRanges { (0...1, -1...1, -1...1) }

	public init(ch: Channels) { self.ch = ch }

	/// Raw Init
	public init(L99o: Double = 0, a99o: Double = 0, b99o: Double = 0) { self.ch = (L99o, a99o, b99o) }

	/// CIE LAB
	public init(L: Double, a: Double, b: Double) {
		// DIN99o (DIN99b) paraméterek D65 megvilágításhoz
		let kE = 1.0
		let kCH = 1.0

		// 1. L* transzformáció
		let L99o = 303.67 / kE * log(1.0 + 0.0039 * L)

		// 2. e és f számítása (26° forgatás)
		let e = a * cos(26.0 * .pi / 180.0) + b * sin(26.0 * .pi / 180.0)
		let f = 0.83 * (b * cos(26.0 * .pi / 180.0) - a * sin(26.0 * .pi / 180.0))

		// 3. G számítása
		let G = sqrt(e * e + f * f)

		// 4. C99o számítása
		let C99o = (23.0 * log(1.0 + 0.075 * G)) / (kCH * kE)

		// 5. h99o szöge (radián) + 26° kompenzáció
		let h99o = atan2(f, e) + 26.0 * .pi / 180.0

		// 6. a99o és b99o számítása
		let a99o = C99o * cos(h99o)
		let b99o = C99o * sin(h99o)

		self.ch = (L99o, a99o, b99o)
	}

	public init(r: Double, g: Double, b: Double) {
//		let lab = LAB(r: r, g: g, b: b)
//		self.init(CIELabL: L, a: a, b: b)
		fatalError()
	}

	public func toLAB() -> LAB {

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

	public func toRGB() -> RGB {
		self.toLAB().toRGB()
	}

}

public extension DIN99 {

	func distance(_ c: DIN99) -> Double {
		let deltaL = self.L99o - c.L99o
		let deltaa = self.a99o - c.a99o
		let deltab = self.b99o - c.b99o

		return sqrt(deltaL * deltaL + deltaa * deltaa + deltab * deltab)
	}

}
