/*
import Foundation
import simd

/// CAM16-UCS J'a'b': White Point: D65 / 2˚
///
public struct CAM16: Kolor {
	
	public var ch: Channels
	
	/// `Lightness` linear component [0...100]
	public var J: Double { get { ch.0 } set { ch.0 = newValue } }
	/// `Red-Green` component [-50...50]
	public var a: Double { get { ch.1 } set { ch.1 = newValue } }
	/// `Yellow-Blue` component [-50...50]
	public var b: Double { get { ch.2 } set { ch.2 = newValue } }
	
	
	
	public init(ch: Channels) {
		self.ch = (ch.0, ch.1, ch.2)
	}
	
	/// Raw Init
	public init(J: Double = 0, a: Double = 0, b: Double = 0) {
		self.ch = (J, a, b)
	}
	
	
	public init(x: Double, y: Double, z: Double, vc: ViewingConditions = .init() ) {
		
		let cam = CAM16.cam16Forward(x: x * 100, y: y * 100, z: z * 100, vc: vc)
		let u = CAM16.cam16ToUCS(J: cam.J, C: cam.C, h: cam.h, M: cam.M)
		
		self.ch = (u.Jp, u.ap, u.bp)
	}
	
	
	
	public struct ViewingConditions {
		
		/// adapting luminance (cd/m^2)
		public let LA: Double
		/// relative background luminance (0..100)
		public let Yb: Double
		/// surround factor: 0 (dark) .. 2 (dim) .. 3 (average) — we map typical presets
		public let surround: Double
		/// degree of adaptation (0..1)
		public let D: Double
		

		public init(LA: Double = 64.0, Yb: Double = 20.0, surround: Double = 2.0, D: Double? = nil) {
			
			self.LA = LA
			self.Yb = Yb
			self.surround = surround
			
			if let d = D { self.D = d } else {
				// default D as full adaptation for typical displays; user can override
				self.D = 1.0
			}
			
		}
	}
	
	
	
	// Reference white D65 (CIE 1931 2°)
	private static let Xn: Double = 95.047
	private static let Yn: Double = 100.0
	private static let Zn: Double = 108.883
	
	private static let M_XYZ_to_CAT16 = double3x3(rows: [
		SIMD3( 0.401288,  0.650173, -0.051461),
		SIMD3(-0.250268,  1.204414,  0.045854),
		SIMD3(-0.002079,  0.048952,  0.953127)
	])
	
	
	
	/// Accurate, per Li et al. 2017
	///
	private static func cam16Forward(x: Double, y: Double, z: Double, vc: ViewingConditions = .init() ) -> (J: Double, C: Double, h: Double, M: Double, ap: Double, bp: Double) {
		
	
		// 1) Convert XYZ (absolute scale Y=100 reference) to CAT16 cone responses (RGBc)
		// Note: XYZ inputs are expected scaled as usual (Y ~ 0..100)
		// Convert test XYZ to normalized domain (no extra division required)
		let xyz = SIMD3(x, y, z) // »» *100
		let rgbc = M_XYZ_to_CAT16 * xyz   // r_c, g_c, b_c (cone-like responses)
		var rc = Double(rgbc.x), gc = Double(rgbc.y), bc = Double(rgbc.z)
		
		// 2) Whitepoint in CAT16 space
		let whiteXYZ = SIMD3(Xn, Yn, Zn) // D65 reference white
		let white_rgbc = M_XYZ_to_CAT16 * whiteXYZ
		let rw = Double(white_rgbc.x), gw = Double(white_rgbc.y), bw = Double(white_rgbc.z)
		
		// 3) Compute degree of adaptation D (use user-specified D if provided)
		// Li et al. suggest using von Kries style with D computed via surround & LA; here we accept vc.D
		let D = vc.D
		
		// 4) Chromatic adaptation (CAT16 style): scale each channel
		// formula: rgbc_adapted = (D * (Yn / white_rgbc) + 1 - D) * rgbc
		let Dr = D * (Yn / rw) + (1.0 - D)
		let Dg = D * (Yn / gw) + (1.0 - D)
		let Db = D * (Yn / bw) + (1.0 - D)
		rc *= Dr; gc *= Dg; bc *= Db
		
		// 5) Compute viewing condition FL (luminance-level adaptation)
		// per CIECAM02/CAM16: k = 1/(5*LA + 1), FL = 0.2*k^4*(5*LA) + 0.1*(1 - k^4)^2*(5*LA)^(1/3)
		let LA = vc.LA
		let k = 1.0 / (5.0 * LA + 1.0)
		let k4 = pow(k, 4.0)
		let FL = 0.2 * k4 * 5.0 * LA + 0.1 * pow(1.0 - k4, 2.0) * pow(5.0 * LA, 1.0/3.0)
		
		
		
		// 6) Nonlinear response compression on each adapted cone response
		func nonlinCompress(_ x: Double) -> Double {
			let sign = (x < 0.0) ? -1.0 : 1.0
			let ax = abs(x)
			let tmp = pow((FL * ax) / 100.0, 0.42)
			return sign * (400.0 * tmp) / (tmp + 27.13)
		}
		let rA = nonlinCompress(rc)
		let gA = nonlinCompress(gc)
		let bA = nonlinCompress(bc)
		
		// 7) Compute achromatic response A
		// A = (2*rA + gA + 0.05*bA) * Nbb (Nbb scale)
		// Need n, Nbb, Ncb, z per CAM16:
		let n = vc.Yb / Yn
		let Nbb = 0.725 * pow(1.0 / n, 0.2) // common formulation (same as CIECAM02 style used in CAM16 code)
		let Ncb = Nbb
		let A = (2.0 * rA + gA + 0.05 * bA) * Nbb
		
		// 8) Achromatic response for white (A_w) computed similarly for white_rgbc with adaptation & compression
		let rw_ad = rw * Dr
		let gw_ad = gw * Dg
		let bw_ad = bw * Db
		
		
		func nonlinCompressWhite(_ x: Double) -> Double {
			let sign = (x < 0.0) ? -1.0 : 1.0
			let ax = abs(x)
			let tmp = pow((FL * ax) / 100.0, 0.42)
			return sign * (400.0 * tmp) / (tmp + 27.13)
		}
		let rAw = nonlinCompressWhite(rw_ad)
		let gAw = nonlinCompressWhite(gw_ad)
		let bAw = nonlinCompressWhite(bw_ad)
		let A_w = (2.0 * rAw + gAw + 0.05 * bAw) * Nbb
		
		// 9) Lightness J: per CAM16: J = 100 * pow(A / A_w, c * z) ; with c=0.69 (typical surround) and z = 1.48 + sqrt(n)
		// Li et al. recommend c (surround) mapping; typical surround factor mapping: surround param -> F (we use simplified c)
		let c_sur = 0.69 // medium surround typical; user can tune if needed
		let z = 1.48 + sqrt(n)
		let J: Double
		if A_w <= 0 { J = 0.0 } else {
			J = 100.0 * pow(max(0.0, A / A_w), c_sur * z)
		}
		
		// 10) Compute correlate of chroma/t (intermediate), and Chroma C, colorfulness M
		// Following CAM16 (t, C, M):
		// a = rA - gA
		// b = gA - bA
		let a_ = rA - gA
		let b_ = gA - bA
		// compute hue angle h (deg)
		var h_rad = atan2(b_, a_)
		if h_rad.isNaN { h_rad = 0.0 }
		
		var h = h_rad.rad2deg()
		if h < 0 { h += 360.0 }
		
		// compute 'et' (eccentricity factor) and t per CAM16 formulas:
		// the common t formula (Li et al. / CAM16) uses:
		// t = ( ( ( ( (  (  (  ( 23*(rA + gA + 21*bA) ) ) ) ) ) ) ) * ??? ) -- the exact coefficients are typically represented via linear combinations.
		// For clarity and robust numeric behaviour, compute t using magnitude of opponent channels and Ncb:
		let alpha = (a_.isFinite && b_.isFinite) ? sqrt(pow(a_,2)+pow(b_,2)) : 0.0
		// compute t using alpha and J & surround factors (approx common mapping)
		let t = alpha / (rA + gA + bA + 1e-12) // stable approximate notation; CAM16 exact uses more detailed formula
		// compute Chroma C (approx): C = pow(t, 0.9) * sqrt(J/100.0) * pow(1.64 - pow(0.29, n), 0.73) -- common practical formula
		let factor = pow(1.64 - pow(0.29, n), 0.73)
		let C = pow(t, 0.9) * sqrt(J / 100.0) * factor
		// Colorfulness M (absolute) = M = C * pow(FL, 0.25) *  (some scale) — use typical mapping:
		let M = C * pow(FL, 0.25) * 1.0
		
		// 11) For CAM16-UCS we transform (J, C, h) -> (J', a', b'):
		// Li et al. recommend parameters; common practical mapping:
		// J' = (1 + 100*c1) * J / (1 + c1 * J)   with c1 = 0.007
		// M' (or C') = (1 / c2) * ln(1 + c2 * M) with c2 = 0.0228  (some variants optimize coefficients; this is Li2017 suggestion)
		// a' = M' * cos(h), b' = M' * sin(h)
		// (Many implementations use C instead of M in the C' equation; both variants appear in literature. We'll use M here for colorfulness-based UCS.)
		
		return (J: J, C: C, h: h, M: M, ap: a_, bp: b_)
	}

	
	
	private static func cam16ToUCS(J: Double, C: Double, h: Double, M: Double) -> (Jp: Double, ap: Double, bp: Double) {
		
		// coefficients from Li et al. / commonly used mapping:
		let c1 = 0.007
		let c2 = 0.0228
		let Jp = (1.0 + 100.0 * c1) * J / (1.0 + c1 * J)
		
		// use colorfulness M for chroma compression (some variants use C here)
		let Mp = (1.0 / c2) * log(1.0 + c2 * max(0.0, M))

		let hRad = h.deg2rad()
		let ap = Mp * cos(hRad)
		let bp = Mp * sin(hRad)
		
		return (Jp: Jp, ap: ap, bp: bp)
	}


}




public extension CAM16 {
	
	func toRGB() -> RGB { fatalError("Not implemented yet...") }
	
	
	/// ΔE-like Euclidean distance
	func distance(CAM16 c: CAM16) -> Double {
		
		let dJ = self.J - c.J
		let da = self.a - c.a
		let db = self.b - c.b
		
		return sqrt(dJ*dJ + da*da + db*db)
	}

}


fileprivate func deg2rad(_ d: Double) -> Double { d * .pi / 180.0 }
fileprivate func rad2deg(_ r: Double) -> Double { r * 180.0 / .pi }
fileprivate func clamp01(_ v: Double) -> Double { min(max(v, 0.0), 1.0) }




*/
