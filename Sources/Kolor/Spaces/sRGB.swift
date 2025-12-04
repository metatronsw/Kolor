import SwiftUI

public struct sRGB: Kolor, ExpressibleByArrayLiteral {

	public typealias ArrayLiteralElement = UInt8

	/// `Red` component [0...255]
	public var r: UInt8
	/// `Green` component [0...255]
	public var g: UInt8
	/// `Blue` component [0...255]
	public var b: UInt8

	public var ch: Channels {
		get {
			(Double(r), Double(g), Double(b))
		}
		set {
			r = UInt8(newValue.0)
			g = UInt8(newValue.1)
			b = UInt8(newValue.2)
		}
	}

	public static var ranges: CompRanges { (0...255, 0...255, 0...255) }

	public init(ch: Channels) {
		self.r = UInt8(ch.0)
		self.g = UInt8(ch.1)
		self.b = UInt8(ch.2)
	}

	public init(arrayLiteral elements: ArrayLiteralElement...) {
		assert(elements.count == 3)
		self.r = elements[0]
		self.g = elements[1]
		self.b = elements[2]
	}

	/// Raw Init
	public init(_ r: UInt8 = 0, _ g: UInt8 = 0, _ b: UInt8 = 0) {
		self.r = r
		self.g = g
		self.b = b
	}
	
	/// Raw Init
	public init(r: UInt8 = 0, g: UInt8 = 0, b: UInt8 = 0) {
		self.r = r
		self.g = g
		self.b = b
	}

	/// Raw Init
	public init(r: Int = 0, g: Int = 0, b: Int = 0) {
		self.r = UInt8(min(255, r))
		self.g = UInt8(min(255, g))
		self.b = UInt8(min(255, b))
	}

	public init(normX: Double, normY: Double, normZ: Double) {
		self.init(r: normX, g: normY, b: normZ)
	}
	
	public func normalized() -> Channels { (Double(r) / 255, Double(g) / 255, Double(b) / 255) }

	
	/// Raw Init
	public init(_ comp: (UInt8, UInt8, UInt8)) {
		self.r = comp.0
		self.g = comp.1
		self.b = comp.2
	}

	public init(_ comp: (Int, Int, Int)) {
		self.r = UInt8(min(255, comp.0))
		self.g = UInt8(min(255, comp.1))
		self.b = UInt8(min(255, comp.2))
	}

	/// From [0...1] floating format
	public init(r: Double, g: Double, b: Double) {
		self.r = UInt8(min(255, r * 255 + 0.5))
		self.g = UInt8(min(255, g * 255 + 0.5))
		self.b = UInt8(min(255, b * 255 + 0.5))
	}

	public init<T: BinaryInteger>(r: T, g: T, b: T) {
		self.r = UInt8(min(255, r))
		self.g = UInt8(min(255, g))
		self.b = UInt8(min(255, b))
	}

	public init(bigEndian pixel: UInt32) {
		self.r = UInt8(pixel & 255)
		self.g = UInt8((pixel >> 8) & 255)
		self.b = UInt8((pixel >> 16) & 255)
	}

	public init(littleEndian pixel: UInt32) {
		self.r = UInt8((pixel >> 16) & 255)
		self.g = UInt8((pixel >> 8) & 255)
		self.b = UInt8(pixel & 255)
	}

	public init(hex: UInt32) {
//		self.r = UInt8((hex & 0xFF0000) >> 16)
//		self.g = UInt8((hex & 0x00FF00) >> 8)
//		self.b = UInt8( hex & 0x0000FF)
		self.r = UInt8(hex >> 16)
		self.g = UInt8(hex >> 8)
		self.b = UInt8(hex)
	}

}

public extension sRGB {

	var comp: (UInt8, UInt8, UInt8) { (r, g, b) }

	var hex: UInt32 {
		UInt32(r) << 16 | UInt32(g) << 8 | UInt32(b)
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(hex)
	}

	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.r == rhs.r &&
			lhs.g == rhs.g &&
			lhs.b == rhs.b
	}

	static func < (lhs: Self, rhs: Self) -> Bool {
		if lhs.r == rhs.r {
			if lhs.g == rhs.g { return lhs.b < rhs.b }
			else { return lhs.g < rhs.g }
		} else { return lhs.r < rhs.r }
	}

	var description: String { String(format: "[%.3d %.3d %.3d]", r, g, b) }

	func formatted() -> (x: String, y: String, z: String) {
		(x: r.description, y: g.description, z: b.description)
	}

	func toHexCode(prefix: String = "#") -> String {
		String(format: "\(prefix)%02X%02X%02X", r, g, b)
	}

	func toARGB32(A: UInt8 = 255) -> UInt32 { (UInt32(A) << 24) | (UInt32(r) << 16) | (UInt32(g) << 8) | UInt32(b) }

	func toRGBA32(A: UInt8 = 255) -> UInt32 { (UInt32(r) << 24) | (UInt32(g) << 16) | (UInt32(b) << 8) | UInt32(A) }

	func toRGB24() -> UInt32 { (UInt32(r) << 16) | (UInt32(g) << 8) | UInt32(b) }

	func tosRGB() -> sRGB { self }

	func toRGB() -> RGB { RGB(r: r, g: g, b: b) }

	func toCMYK() -> CMYK { self.toRGB().toCMYK() }

	func toHCL() -> HCL { self.toRGB().toHCL() }

	func toHSL() -> HSL { self.toRGB().toHSL() }

	func toHSLuv() -> HSLuv { self.toRGB().toHSLuv() }

	func toHSV() -> HSV { self.toRGB().toHSV() }

	func toLAB() -> LAB { self.toRGB().toLAB() }
	
	func toDIN99() -> DIN99 { self.toRGB().toLAB().toDIN99() }

	func toLCh() -> LCh { self.toRGB().toLCh() }

	func toLUV() -> LUV { self.toRGB().toLUV() }

	func toOKLAB() -> OKLab { self.toRGB().toOKLAB() }
	
	func toOKLCh() -> OKLCh { self.toRGB().toOKLCh() }

	func toXYZ() -> XYZ { self.toRGB().toXYZ() }

	func toYUV() -> YUV { self.toRGB().toYUV() }

}

public extension sRGB {

	func toQuantized(by levels: Int = 4) -> sRGB {
		let step = 256 / levels
		let r = min(Int(r) / step, levels - 1) * step
		let g = min(Int(g) / step, levels - 1) * step
		let b = min(Int(b) / step, levels - 1) * step
		return sRGB(r: r, g: g, b: b)
	}
	
	func toQuantized(Pow2 shift: UInt8 = 8) -> sRGB {
		let r = (r >> shift) * shift
		let g = (g >> shift) * shift
		let b = (b >> shift) * shift
		return sRGB(r, g, b)
	}
	
	
	func toQuantizedIndex64() -> Int {
		let binR = Int(r >> 6)
		let binG = Int(g >> 6)
		let binB = Int(b >> 6)
		return (binR << 4) | (binG << 2) | binB
	}
	
	func toQuantizedIndex(by levels: Int = 4) -> Int {
		let step = 256 / levels
		let r = min(Int(r) / step, levels - 1)
		let g = min(Int(g) / step, levels - 1)
		let b = min(Int(b) / step, levels - 1)
		return (r * levels * levels) + (g * levels) + b
	}

	func toQuantizedIndex(Pow2 shift: Int) -> Int {
		// let shift = Int(log2(Double(levels)))
		let binShift = 8 - shift // 256 = 2^8
		let rBin = Int(r) >> binShift
		let gBin = Int(g) >> binShift
		let bBin = Int(b) >> binShift
		return (rBin << (shift * 2)) | (gBin << shift) | bBin
	}

	
	init(binIndex64 bin: Int) {
		let binR = (bin >> 4) & 0b11
		let binG = (bin >> 2) & 0b11
		let binB = bin & 0b11
		
		self.r = UInt8(binR * 64 + 32)
		self.g = UInt8(binG * 64 + 32)
		self.b = UInt8(binB * 64 + 32)
	}
	
	init(binIndex bin: Int, levels: Int) {
		let step = 256 / levels
		
		let br = bin / (levels * levels)
		let bg = (bin / levels) % levels
		let bb = bin % levels
		
		self.r = UInt8(min(255, br * step + step / 2))
		self.g = UInt8(min(255, bg * step + step / 2))
		self.b = UInt8(min(255, bb * step + step / 2))
	}
	
	init(binIndexPow2 bin: Int, levels: Int) {
		let shift = Int(log2(Double(levels)))
		let mask = levels - 1
		let binShift = 8 - shift

		let rBin = (bin >> (shift * 2)) & mask
		let gBin = (bin >> shift) & mask
		let bBin = bin & mask

		let half = 1 << (binShift - 1)

		self.r = UInt8((rBin << binShift) + half)
		self.g = UInt8((gBin << binShift) + half)
		self.b = UInt8((bBin << binShift) + half)
	}
		
	
	func toQuantizedExp(levels: Int, gamma: Double = 2.2) -> sRGB {
		let rNorm = pow(Double(r) / 255.0, gamma)
		let gNorm = pow(Double(g) / 255.0, gamma)
		let bNorm = pow(Double(b) / 255.0, gamma)
		
		return sRGB(r: rNorm, g: gNorm, b: bNorm)
	}
	
	func toQuantizedExpIndex(levels: Int, gamma: Double = 2.2) -> Int {
		let rNorm = pow(Double(r) / 255.0, gamma)
		let gNorm = pow(Double(g) / 255.0, gamma)
		let bNorm = pow(Double(b) / 255.0, gamma)
		
		// Kerekítés (round) a bin közepére
		let rBin = min(levels - 1, max(0, Int((rNorm * Double(levels)).rounded())))
		let gBin = min(levels - 1, max(0, Int((gNorm * Double(levels)).rounded())))
		let bBin = min(levels - 1, max(0, Int((bNorm * Double(levels)).rounded())))
		
		return rBin * levels * levels + gBin * levels + bBin
	}
	
	init(fromQuantizedExp index: Int, levels: Int, gamma: Double = 2.2) {
		let rBin = index / (levels * levels)
		let gBin = (index / levels) % levels
		let bBin = index % levels
		
		let rNorm = pow((Double(rBin) + 0.5) / Double(levels), 1.0 * gamma)
		let gNorm = pow((Double(gBin) + 0.5) / Double(levels), 1.0 * gamma)
		let bNorm = pow((Double(bBin) + 0.5) / Double(levels), 1.0 * gamma)
		
		self.r = UInt8(min(255,rNorm * 255))
		self.g = UInt8(min(255,gNorm * 255))
		self.b = UInt8(min(255,bNorm * 255))
	}
	
}

public extension sRGB {

	func distance(_ c: sRGB) -> Double {
		let deltaR = Double(sq(r - c.r))
		let deltaG = Double(sq(g - c.g))
		let deltaB = Double(sq(b - c.b))
		return sqrt(deltaR + deltaG + deltaB)
	}

	func distanceWeight(_ c: sRGB) -> Double {
		let rmean = (Int(r) + Int(c.r)) / 2
		let r = Int(r) - Int(c.r)
		let g = Int(g) - Int(c.g)
		let b = Int(b) - Int(c.b)
		return sqrt(Double((((512 + rmean) * r * r) >> 8) + 4 * g * g + (((767 - rmean) * b * b) >> 8)))
	}

	func isBlack(tolerance: Int = 12) -> Bool {
		if r >= tolerance { return false }
		if g >= tolerance { return false }
		if b >= tolerance { return false }

		return true
	}

	func isGray(tolerance: Int = 10) -> Bool {
		if abs(Int(r) - Int(g)) >= tolerance { return false }
		if abs(Int(g) - Int(b)) >= tolerance { return false }
		if abs(Int(b) - Int(r)) >= tolerance { return false }

		return true
	}

	func isWhite(tolerance: Int = 220) -> Bool {
		if r <= tolerance { return false }
		if g <= tolerance { return false }
		if b <= tolerance { return false }

		return true
	}

	func toInverted() -> sRGB {
		return sRGB(255 - self.r, 255 - self.g, 255 - self.b)
	}

	func toContrasted() -> sRGB {
		let rgb = self.toRGB()
		let brightness = (rgb.r * 0.21) + (rgb.g * 0.72) + (rgb.b * 0.07)

		return brightness > 0.5 ? .BLACK : .WHITE
	}

	func toComplementary() -> sRGB {
		return sRGB(max(0, 255 - self.r), max(0, 255 - self.g), max(0, 255 - self.b))
	}


	static func paletteGen(interval: Int) -> [sRGB] {
		return paletteGen(step: 256 / interval)
	}
	
	static func paletteGen(step: Int, fullWidht f: Bool = true) -> [sRGB] {
		
		var (r, g, b) = (0, 0, 0)
		var palette = [sRGB]()

		repeat {
			repeat {
				repeat {
					
					palette.append( sRGB(r: r, g: g, b: b) )
					r += step
					
				} while r < 255 + (f ? step : 1)
				
				r = 0
				g += step
				
			} while g < 255 + (f ? step : 1)
			
			g = 0
			b += step
			
		} while b < 255 + (f ? step : 1)

		return palette
	}

}
