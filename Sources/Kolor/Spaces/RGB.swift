import Foundation
import simd

public struct RGB: Kolor, ExpressibleByArrayLiteral {

	public typealias ArrayLiteralElement = Double
	
	public var ch: Channels

	/// `Red` component [0...1]
	public var r: Double { get { ch.0 } set { ch.0 = newValue } }
	/// `Green` component [0...1]
	public var g: Double { get { ch.1 } set { ch.1 = newValue } }
	/// `Blue` component [0...1]
	public var b: Double { get { ch.2 } set { ch.2 = newValue } }

	public static var ranges: CompRanges { (0...1, 0...1, 0...1) }

	public init(ch: Channels) { self.ch = (ch.0, ch.1, ch.2) }

	/// Raw Init
	public init(_ r: Double = 0, _ g: Double = 0, _ b: Double = 0) { self.ch = (r, g, b) }

	/// Raw Init
	public init(r: Double = 0, g: Double = 0, b: Double = 0) { self.ch = (r, g, b) }

	public init(normX: Double, normY: Double, normZ: Double) {
		self.ch = (normX, normY, normZ)
	}
	
	public func normalized() -> Channels { self.ch }
	
	public init(_ srgb: sRGB) {
		self.ch = (Double(srgb.r) / 255, Double(srgb.g) / 255, Double(srgb.b) / 255)
	}
	
	public init(arrayLiteral elements: ArrayLiteralElement...) {
		assert(elements.count == 3)
		self.ch.0 = elements[0]
		self.ch.1 = elements[1]
		self.ch.2 = elements[2]
	}
	
	public init<T: BinaryInteger>(r: T = 0, g: T = 0, b: T = 0) {
		self.ch = (Double(r) / 255, Double(g) / 255, Double(b) / 255)
	}

	public init(bigEndian pixel: UInt32) {
		self.ch = (
			Double(pixel & 0xFF) / 255,
			Double((pixel >> 8) & 0xFF) / 255,
			Double((pixel >> 16) & 0xFF) / 255
		)
	}

	public init(littleEndian pixel: UInt32) {
		self.ch = (
			Double((pixel >> 16) & 0xFF) / 255,
			Double((pixel >> 8) & 0xFF) / 255,
			Double(pixel & 0xFF) / 255
		)
	}

	public init(hex: UInt32) {
		self.ch = (
			Double((hex & 0xFF0000) >> 16) / 255,
			Double((hex & 0x00FF00) >> 8) / 255,
			Double(hex & 0x0000FF) / 255
		)
	}

	public init?<S: StringProtocol>(_ hex: S) {
		guard hex.hasPrefix("#") else { return nil }

		let start = hex.index(hex.startIndex, offsetBy: 1)
		let hexColor = String(hex[start...])
		let scanner = Scanner(string: hexColor)
		var hexNumber: UInt64 = 0

		if hexColor.count == 6, scanner.scanHexInt64(&hexNumber) {
			self.ch = (
				Double((hexNumber & 0xFF0000) >> 16) / 255,
				Double((hexNumber & 0x00FF00) >> 8) / 255,
				Double((hexNumber & 0x0000FF) >> 0) / 255
			)
			return
		}

		else if hexColor.count == 3, scanner.scanHexInt64(&hexNumber) {
			self.ch = (
				Double((hexNumber & 0x000F00) >> 8) / 15,
				Double((hexNumber & 0x0000F0) >> 4) / 15,
				Double((hexNumber & 0x00000F) >> 0) / 15
			)
			return
		}

		return nil
	}

}

public extension RGB {

	var isValid: Bool {
		r >= 0.0 && r <= 1.0 &&
		g >= 0.0 && g <= 1.0 &&
		b >= 0.0 && b <= 1.0
	}

	var comp: (UInt32, UInt32, UInt32) {
		let r = UInt32(r * 65535 + 0.5)
		let g = UInt32(g * 65535 + 0.5)
		let b = UInt32(b * 65535 + 0.5)
		return (r, g, b)
	}

	func toClamped() -> RGB {
		RGB(r: r.clamped(), g: g.clamped(), b: b.clamped())
	}
	
	func toSRGB() -> sRGB {
		sRGB(r: UInt8(min(255, r.clamped() * 255 + 0.5)),
			  g: UInt8(min(255, g.clamped() * 255 + 0.5)),
			  b: UInt8(min(255, b.clamped() * 255 + 0.5)))
	}

	func toRGB() -> RGB { self }

	func toCMYK() -> CMYK { CMYK(r: r, g: g, b: b) }
	
	func toHCL() -> HCL { HCL(r: r, g: g, b: b) }
	
	func toHSL() -> HSL { HSL(r: r, g: g, b: b) }
	
	func toHSLuv() -> HSLuv { HSLuv(r: r, g: g, b: b) }
	
	func toHSV() -> HSV { HSV(r: r, g: g, b: b) }
	
	func toLAB() -> LAB { self.toXYZ().toLAB() }
	
	func toDIN99() -> DIN99 { self.toXYZ().toLAB().toDIN99() }
	
	func toLCh() -> LCh { self.toXYZ().toLUV().toLCh() }
	
	func toLUV() -> LUV { self.toXYZ().toLUV() }
	
	func toOKLAB() -> OKLAB { OKLAB(r: r, g: g, b: b) }
	
	func toOKLCh() -> OKLCh { OKLCh(r: r, g: g, b: b) }
	
	func toXYZ() -> XYZ { XYZ(r: r, g: g, b: b) }
	
	func toYUV() -> YUV { YUV(r: r, g: g, b: b) }

}

public extension RGB {

	/// Convert to Linear RGB
	func toLinearized() -> RGB {
		RGB(r: r.linearize(), g: g.linearize(), b: b.linearize())
	}

	/// Convert to sRGB
	func toDelinearized() -> RGB {
		RGB(r: r.delinearize(), g: g.delinearize(), b: b.delinearize())
	}

	
	/// Convert from Linear RGB
	func linear_toDisplayP3Linear() -> RGB {
		let sRGBtoXYZ = (
			(0.4124564, 0.3575761, 0.1804375),
			(0.2126729, 0.7151522, 0.0721750),
			(0.0193339, 0.1191920, 0.9503041)
		)

		let XYZtoP3 = (
			(2.493496911941425, -0.9313836179191239, -0.40271078445071684),
			(-0.8294889695615747, 1.7626640603183463, 0.023624685841943577),
			(0.03584583024378447, -0.07617238926804182, 0.9568845240076872)
		)

//		let rgbLinear = (r.linearize(), g.linearize(), b.linearize())
		let xyz = matrixMul(sRGBtoXYZ, self.ch)

		let p3Linear = matrixMul(XYZtoP3, xyz)

		return RGB(ch: p3Linear)
	}
	
	/// Convert to DisplayP3
	func toDisplayP3() -> RGB {
		let p3Linear = self.toLinearized().linear_toDisplayP3Linear()

		func gammaCorrect(_ c: Double) -> Double {
			let clamped = max(0.0, min(1.0, c))
			return (clamped <= 0.0031308) ? (12.92 * clamped) : (1.055 * pow(clamped, 1.0 / 2.4) - 0.055)
		}

		return RGB(gammaCorrect(p3Linear.r),
					  gammaCorrect(p3Linear.g),
					  gammaCorrect(p3Linear.b))
	}

	func displayP3_toRGB() -> RGB {
		
		func displayP3ToLinear(_ c: Double) -> Double {
			return (c <= 0.04045) ? (c / 12.92) : pow((c + 0.055) / 1.055, 2.4)
		}

		let linearP3 = RGB(displayP3ToLinear(r), displayP3ToLinear(g), displayP3ToLinear(b))
		return linearP3.displayP3Linear_toRGB()
	}

	func displayP3Linear_toRGB() -> RGB {
		func linearToSRGB(_ c: Double) -> Double {
			let clamped = max(0.0, min(1.0, c))
			return (clamped <= 0.0031308) ? (12.92 * clamped) : (1.055 * pow(clamped, 1.0 / 2.4) - 0.055)
		}

		let P3toXYZ = (
			(0.4865709486482162, 0.26566769316909306, 0.1982172852343625),
			(0.2289745640697488, 0.6917385218365064, 0.079286914093745),
			(0.0, 0.04511338185890264, 1.043944368900976)
		)

		let XYZtoSRGB = (
			(3.2404542, -1.5371385, -0.4985314),
			(-0.9692660, 1.8760108, 0.0415560),
			(0.0556434, -0.2040259, 1.0572252)
		)

		let xyz = matrixMul(P3toXYZ, self.ch)
		let linearSRGB = matrixMul(XYZtoSRGB, xyz)

		return RGB(linearToSRGB(linearSRGB.0),
					  linearToSRGB(linearSRGB.1),
					  linearToSRGB(linearSRGB.2))
	}

}

extension RGB: DeltaE {
	
	public func distance(from col: RGB) -> Double {
		sqrt(sq(r - col.r) + sq(g - col.g) + sq(b - col.b))
	}
	
	public func distanceLinear(_ col: RGB) -> Double {
		let a = self.toLinearized()
		let b = col.toLinearized()
		return sqrt((sq(a.r - b.r) + sq(a.g - b.g) + sq(a.b - b.b)))
	}
	
	public func distanceWeight(_ col: RGB) -> Double {
		let rmean = (self.r + col.r) / 2
		let rD = self.r - col.r
		let gD = self.g - col.g
		let bD = self.b - col.b
		let weightR = 2.0 + rmean / 256
		let weightG = 4.0
		let weightB = 2.0 + (255 - rmean) / 256
		return sqrt(weightR * sq(rD) + weightG * sq(gD) + weightB * sq(bD) )
	}
	
	public func almostEqual(_ c: RGB, Delta: Double = 0.00392156862745098039215686) -> Bool {
		abs(r - c.r) + abs(g - c.g) + abs(b - c.b) < (3.0 * Delta)
	}
}


public extension RGB {
	
	func blend(c: RGB, t: Double) -> RGB {
		RGB(r: r + t * (c.r - r), g: g + t * (c.g - g), b: b + t * (c.b - b))
	}
	
	func paletteGen(step: Int) -> [RGB] {
		let stp = 1.0 / Double(step)
		var (r, g, b) = (0.0, 0.0, 0.0)
		var palette = [RGB]()
		
		while b <= 1 {
			while g <= 1 {
				while r <= 1 {
					palette.append(RGB(r: min(r, 1), g: min(g, 1), b: min(b, 1)))
					r += stp
				}
				r = 0
				g += stp
			}
			g = 0
			b += stp
		}
		
		return palette
	}
	
}
