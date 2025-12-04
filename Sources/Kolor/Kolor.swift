public protocol Kolor: Hashable, Comparable, Equatable, CustomStringConvertible {

	typealias Channels = (Double, Double, Double)
	typealias CompRanges = (ClosedRange<Double>, ClosedRange<Double>, ClosedRange<Double>)

	/// Init from Raw floating numbers
	init(ch: Channels)

	/// Init from Red Green Blue (0...1)
	init(r: Double, g: Double, b: Double)

	/// Init from normalized floating point number (0...1)
	init(normX: Double, normY: Double, normZ: Double)

	/// Set-Get raw channel values
	var ch: Channels { get set }

	/// Get color space channels value ranges
	static var ranges: CompRanges { get }

	/// Get normalized channel values (0...1)
	func normalized() -> Channels

	func toRGB() -> RGB

	func toSRGB() -> sRGB

	func formatted(decimals d: Int) -> String

	func toHexCode(prefix: String) -> String

	func index(bits: Int) -> Int

}

// TODO: Codable
// extension Kolor: Codable { }

public extension Kolor {

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

	func toHexCode(prefix: String = "#") -> String { self.toSRGB().toHexCode(prefix: prefix) }

	func index(bits: Int = 16) -> Int {
//		let maxVal = Double((1 << bits) - 1)
		let (x, y, z) = self.normalized()
		return Int(morton3DIndex(x: x, y: y, z: z, bits: bits))
	}

}

/// Perceptually uniform colorspace with ΔE distance.
///
public protocol DeltaE: Kolor {

	func distance(from c: Self) -> Double

}

/// Cylindrical hue–saturation-lightness based color models.
/// Hue range is [0...360], Sauration (Chroma) & Lightness (Value) are normalized values [0...1]
///
public protocol Cylindrical: Kolor {

	init(hue: Double, sat: Double, val: Double)

	var hue: Double { get set }
	var sat: Double { get set }
	var val: Double { get set }

}

public extension Cylindrical {

	static func paletteGen(bySteps: Int, saturation: Double, value: Double) -> [Self] {
		
		let segmentation = 360 / Double(bySteps)

		var hue = 0.0
		var palette = [Self]()

		while hue < 360 {
			let new = Self.init(
				hue: min(360, hue),
				sat: saturation,
				val: value
			)

			palette.append(new)
			hue += segmentation
		}

		return palette
	}

}

public enum KolorModes: Int, CaseIterable {

//	case cam16
	case din99, hcl, hsl, hsluv, hsv, lab, lch, luv, oklab, oklch, rgb, srgb, xyz, yuv

	public enum Categoryes {
		case redGreenBlue, cylindrical, xyzLab
	}

	public var name: String {
		String(describing: self)
	}

	public var thisType: any Kolor.Type {
		switch self {
			case .din99: DIN99.self
			case .hcl: HCL.self
			case .hsl: HSL.self
			case .hsluv: HSLuv.self
			case .hsv: HSV.self
			case .lab: LAB.self
			case .lch: LCh.self
			case .luv: LUV.self
			case .oklab: OKLab.self
			case .oklch: OKLCh.self
			case .rgb: RGB.self
			case .srgb: sRGB.self
			case .xyz: XYZ.self
			case .yuv: YUV.self
		}
	}

	public var category: Categoryes {
		switch self {
			case .din99: .xyzLab
			case .hcl: .cylindrical
			case .hsl: .cylindrical
			case .hsluv: .cylindrical
			case .hsv: .cylindrical
			case .lab: .xyzLab
			case .lch: .xyzLab
			case .luv: .xyzLab
			case .oklab: .xyzLab
			case .oklch: .cylindrical
			case .rgb: .redGreenBlue
			case .srgb: .redGreenBlue
			case .xyz: .xyzLab
			case .yuv: .redGreenBlue
		}
	}

}
