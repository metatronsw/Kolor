import Foundation

/// CIE 1976 L*a*b* color space using D65 as reference white.
///
public struct LAB: Kolor {

	public var ch: Channels

	/// `Lightness` component [0...1] (0, 100)
	public var L: Double { get { ch.0 } set { ch.0 = newValue } }
	/// `A` (Green-Red) component [-1...1] (-125, 125)
	public var a: Double { get { ch.1 } set { ch.1 = newValue } }
	/// `B` (Blue-Yellow) component [-1...1] (-125, 125)
	public var b: Double { get { ch.2 } set { ch.2 = newValue } }

	public var ranges: CompRanges { (0...1, -1...1, -1...1) }

	public init(ch: Channels) { self.ch = (ch.0, (ch.1 - 0.5) * 2, (ch.2 - 0.5) * 2) }

	/// Raw Init
	public init(L: Double = 0, a: Double = 0, b: Double = 0) { self.ch = (L, a, b) }

	public init(x: Double, y: Double, z: Double, WhiteRef w: XYZ = .D65) {
		func lab_f(_ t: Double) -> Double {
			if t > 6.0 / 29.0 * 6.0 / 29.0 * 6.0 / 29.0 { return cbrt(t) }
			return t / 3.0 * 29.0 / 6.0 * 29.0 / 6.0 + 4.0 / 29.0
		}

		let fy = lab_f(y / w.y)
		let l = 1.16 * fy - 0.16
		let a = 5.0 * (lab_f(x / w.x) - fy)
		let b = 2.0 * (fy - lab_f(z / w.z))

		self.ch = (l, a, b)
	}

	public init(r: Double, g: Double, b: Double) {
		let xyz = XYZ(r: r, g: g, b: b)
		self.init(x: xyz.x, y: xyz.y, z: xyz.z, WhiteRef: .D65)
	}

	
	/* /// Alternative
	 public init(X x: Double, Y y: Double, Z z: Double, WhiteRef w: XYZ = .D65) {
	 func f(_ t: Double) -> Double {
	 let delta = 6.0 / 29.0
	 let delta3 = delta * delta * delta
	 
	 if t > delta3 {
	 return pow(t, 1.0 / 3.0)
	 } else {
	 return t / (3.0 * delta * delta) + 4.0 / 29.0
	 }
	 }
	 
	 // Normalizált értékek
	 let xr = (x * 100) / (w.x * 100)
	 let yr = (y * 100) / (w.y * 100)
	 let zr = (z * 100) / (w.z * 100)
	 
	 // f(t) függvény alkalmazása
	 let fx = f(xr)
	 let fy = f(yr)
	 let fz = f(zr)
	 
	 // LAB koordináták számítása
	 let L = 116.0 * fy - 16.0
	 let a = 500.0 * (fx - fy)
	 let b = 200.0 * (fy - fz)
	 
	 self.ch = (L, a, b)
	 }
	 */
	
}

public extension LAB {

	func toXYZ(WhiteRef w: XYZ = .D65) -> XYZ {
		func lab_finv(_ t: Double) -> Double {
			if t > 6.0 / 29.0 { return t * t * t }
			return 3.0 * 6.0 / 29.0 * 6.0 / 29.0 * (t - 4.0 / 29.0)
		}

		let l2 = (L + 0.16) / 1.16
		let x = w.x * lab_finv(l2 + a / 5.0)
		let y = w.y * lab_finv(l2)
		let z = w.z * lab_finv(l2 - b / 2.0)

		return XYZ(x: x, y: y, z: z)
	}

	func toHCL() -> HCL { HCL(l: L, a: a, b: b) }

	func toDIN99() -> DIN99 { DIN99(L: L, a: a, b: b) }

	func toRGB() -> RGB { self.toXYZ().toRGB() }

}


extension LAB: DeltaE {
	
	/// CIE ΔE*76
	public func distance(from c: LAB) -> Double {
		return sqrt(sq(L - c.L) + sq(a - c.a) + sq(b - c.b))
	}
	
	/// CIE DELTA ΔE94
	public func distance(CIE94 c: LAB) -> Double {
		let (l1, a1, b1) = (L * 100, a * 100, b * 100)
		let (l2, a2, b2) = (c.L * 100, c.a * 100, c.b * 100)
		
		let kl = 1.0 // 2.0 for textiles
		let kc = 1.0
		let kh = 1.0
		let k1 = 0.045 // 0.048 for textiles
		let k2 = 0.015 // 0.014 for textiles.
		
		let deltaL = l1 - l2
		let c1 = sqrt(sq(a1) + sq(b1))
		let c2 = sqrt(sq(a2) + sq(b2))
		let deltaCab = c1 - c2
		
		let deltaHab2 = sq(a1 - a2) + sq(b1 - b2) - sq(deltaCab)
		let sl = 1.0
		let sc = 1.0 + k1 * c1
		let sh = 1.0 + k2 * c1
		
		let vL2 = sq(deltaL / (kl * sl))
		let vC2 = sq(deltaCab / (kc * sc))
		let vH2 = deltaHab2 / sq(kh * sh)
		
		return sqrt(vL2 + vC2 + vH2) * 0.01
	}
	
	/// CIE DELTA ΔE2000 / (ΔE00) - Weighted
	public func distance(CIEDE2000 c: LAB, kl: Double = 1, kc: Double = 1, kh: Double = 1) -> Double {
		/// Delta E (CIE 2000)
		/// http://www.brucelindbloom.com/index.html?ColorDifferenceCalc.html
		
		let (l1, a1, b1) = (L * 100, a * 100, b * 100)
		let (l2, a2, b2) = (c.L * 100, c.a * 100, c.b * 100)
		
		let cab1 = (sq(a1) + sq(b1)).squareRoot()
		let cab2 = (sq(a2) + sq(b2)).squareRoot()
		let cabmean = (cab1 + cab2) / 2
		
		let g = 0.5 * (1 - (pow(cabmean, 7) / (pow(cabmean, 7) + pow(25, 7))).squareRoot())
		let ap1 = (1 + g) * a1
		let ap2 = (1 + g) * a2
		let cp1 = (sq(ap1) + sq(b1)).squareRoot()
		let cp2 = (sq(ap2) + sq(b2)).squareRoot()
		
		var hp1 = 0.0
		if b1 != ap1 || ap1 != 0 {
			hp1 = atan2(b1, ap1)
			if hp1 < 0 {
				hp1 += Double.pi * 2
			}
			hp1 *= 180 / Double.pi
		}
		var hp2 = 0.0
		if b2 != ap2 || ap2 != 0 {
			hp2 = atan2(b2, ap2)
			if hp2 < 0 {
				hp2 += Double.pi * 2
			}
			hp2 *= 180 / Double.pi
		}
		
		let deltaLp = l2 - l1
		let deltaCp = cp2 - cp1
		var dhp = 0.0
		let cpProduct = cp1 * cp2
		if cpProduct != 0 {
			dhp = hp2 - hp1
			if dhp > 180 {
				dhp -= 360
			} else if dhp < -180 {
				dhp += 360
			}
		}
		let deltaHp = 2 * cpProduct.squareRoot() * sin(dhp / 2 * Double.pi / 180)
		
		let lpmean = (l1 + l2) / 2
		let cpmean = (cp1 + cp2) / 2
		var hpmean = hp1 + hp2
		if cpProduct != 0 {
			hpmean /= 2
			if abs(hp1 - hp2) > 180 {
				if hp1 + hp2 < 360 {
					hpmean += 180
				} else {
					hpmean -= 180
				}
			}
		}
		
		let t = 1 - 0.17 * cos((hpmean - 30) * Double.pi / 180) + 0.24 * cos(2 * hpmean * Double.pi / 180) + 0.32 * cos((3 * hpmean + 6) * Double.pi / 180) - 0.2 * cos((4 * hpmean - 63) * Double.pi / 180)
		let deltaTheta = 30 * exp(-sq((hpmean - 275) / 25))
		let rc = 2 * (pow(cpmean, 7) / (pow(cpmean, 7) + pow(25, 7))).squareRoot()
		let sl = 1 + (0.015 * sq(lpmean - 50)) / (20 + sq(lpmean - 50)).squareRoot()
		let sc = 1 + 0.045 * cpmean
		let sh = 1 + 0.015 * cpmean * t
		let rt = -sin(2 * deltaTheta * Double.pi / 180) * rc
		
		return (sq(deltaLp / (kl * sl)) + sq(deltaCp / (kc * sc)) + sq(deltaHp / (kh * sh)) + rt * (deltaCp / (kc * sc)) * (deltaHp / (kh * sh))).squareRoot() * 0.01
	}
	
}
	
	
public extension LAB {
		
	func blend(c: LAB, t: Double) -> LAB {
		LAB(L: L + t * (c.L - L), a: a + t * (c.a - a), b: b + t * (c.b - b))
	}

}

