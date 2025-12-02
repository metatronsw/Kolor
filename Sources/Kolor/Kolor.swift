public protocol Kolor: Hashable, Comparable, Equatable, CustomStringConvertible  { // TODO: Codable
	
	typealias Channels = (Double, Double, Double)
	typealias CompRanges = (ClosedRange<Double>, ClosedRange<Double>, ClosedRange<Double>)
	
	
	init(ch: Channels)
	init(r: Double, g: Double, b: Double)
	
	var ch: Channels { get set }
	
	var ranges: CompRanges { get }
	
	func normalized() -> Channels
	
	func toRGB() -> RGB
	func toSRGB() -> sRGB
	
	func formatted(decimals d: Int) -> String
	func toHexCode() -> String
	func index(bits: Int) -> Int
	
//	var hue: Double { atan2(a, b) }
//	var chroma: Double { sqrt(a * a + b * b) }
	

}

/// Perceptually uniform colorspace with ΔE distance.
///
public protocol DeltaE: Kolor {
	
	func distance(from c: Self) -> Double
	
}


/// Cylindrical hue–saturation-lightness based color models.
/// Sauration (Chroma) and Lightness (Value) are normalized values [0...1]
///
public protocol Cylindrical: Kolor {
	
	init(h: Double, s: Double, v: Double)
	
	var h: Double { get set }
	var s: Double { get set }
	var v: Double { get set }
}

public extension Cylindrical {
	
	static func paletteGen(bySteps: Int, saturation: Double, value: Double) -> [Self] {
		
		let segmentation = 360 / Double(bySteps)
		
		var hue = 0.0
		var palette = [Self]()
		
		while hue < 360 {
			
			let new = Self.init(
				h: min(360, hue),
				s: saturation,
				v: value
			)
			
			palette.append(new)
			hue += segmentation
		}
		
		return palette
	}
}




public extension Kolor {
	
	func index(bits: Int = 16) -> Int {
		
		let maxVal = Double((1 << bits) - 1)
		let (x,y,z) = self.normalized()
		return Int(morton3DIndex(x: x, y: y, z: z, bits: bits))
	}
	
	
	func normalized() -> Channels {
		return (
			self.ch.0.normalize(in: self.ranges.0),
			self.ch.1.normalize(in: self.ranges.1),
			self.ch.2.normalize(in: self.ranges.2)
		)
	}
	
	
	func toHexCode() -> String {
		let rgb = self.toSRGB()
		return String(format: "#%02X%02X%02X", rgb.r, rgb.g, rgb.b)
	}
	
	
	var description: String {
		String(format: "[%.3f %.3f %.3f]", ch.0, ch.1, ch.2)
	}
	
	
	func formatted(decimals d: Int = 3) -> String {
		String(format: "%.\(d)f ", ch.0) +
		String(format: "%.\(d)f ", ch.1) +
		String(format: "%.\(d)f", ch.2)
	}
	

	func hash(into hasher: inout Hasher) {
		hasher.combine(ch.0)
		hasher.combine(ch.1)
		hasher.combine(ch.2)
	}
	
	
	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.ch == rhs.ch
	}
	
	
	static func < (lhs: Self, rhs: Self) -> Bool {
//		if lhs.ch.0 == rhs.ch.0 {
//			if lhs.ch.1 == rhs.ch.1 { return lhs.ch.2 < rhs.ch.2 }
//			else                    { return lhs.ch.1 < rhs.ch.1 }
//		}
//		else { return lhs.ch.0 < rhs.ch.0 }
		
		if abs(lhs.ch.0 - rhs.ch.0) > 0.01 { return lhs.ch.0 < rhs.ch.0 }
		if abs(lhs.ch.1 - rhs.ch.1) > 0.01 { return lhs.ch.1 < rhs.ch.1 }
		return lhs.ch.2 < rhs.ch.2
	}
	
	
	func toSRGB() -> sRGB { self.toRGB().toSRGB() }
	
}


public enum KolorModes: UInt8, CaseIterable {
	
	case srgb
	case rgb
	case hcl, hsl, hsluv, hsv
	case xyz, lab, oklab, luv, lch
	case yuv
	
	
	public var name: String {
		String(describing: self)
	}
	
	
	public var thisType: any Kolor.Type {
		switch self {
			case .srgb: sRGB.self
			case .rgb: RGB.self
			case .hsl: HSL.self
			case .hsv: HSV.self
			case .hsluv: HSLuv.self
			case .hcl: HCL.self
			case .xyz: XYZ.self
			case .lab: LAB.self
			case .oklab: OKLAB.self
			case .lch: LCh.self
			case .luv: LUV.self
			case .yuv: YUV.self
				
		}
	}
	
	
}


