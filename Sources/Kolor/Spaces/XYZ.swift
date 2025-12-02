import Foundation
import simd

/// CIE 1931 XYZ
///
public struct XYZ: Kolor {

	/// `X` (Green-Red) component [0...1] 
	public var x: Double { get { ch.0 } set { ch.0 = newValue } }
	/// `Lightness` component [0...1]
	public var y: Double { get { ch.1 } set { ch.1 = newValue } }
	/// `Z` (Blue-Yellow) component [0...1]
	public var z: Double { get { ch.2 } set { ch.2 = newValue } }

	public var ch: Channels

	public var ranges: CompRanges { (0...1, 0...1, 0...1) }

	public init(ch: Channels) { self.ch = (ch.0, ch.1, ch.2) }

	/// Raw Init
	public init(x: Double = 0, y: Double = 0, z: Double = 0) {
		self.ch = (x, y, z)
	}

	public init(r: Double, g: Double, b: Double) {
		let ch: Channels = (x: r.linearize(),
								  y: g.linearize(),
								  z: b.linearize())

		self.init(LinearRGB: ch)
	}

	/// Init with default D65/2°
	public init(LinearRGB ch: Channels) {
		let x = (ch.0 * 0.41239079926595948) + (ch.1 * 0.35758433938387796) + (ch.2 * 0.18048078840183429)
		let y = (ch.0 * 0.21263900587151036) + (ch.1 * 0.71516867876775593) + (ch.2 * 0.07219231536073371)
		let z = (ch.0 * 0.01933081871559185) + (ch.1 * 0.11919477979462599) + (ch.2 * 0.95053215224966058)

		self.ch = (x, y, z)
	}

	public func normalized() -> Channels { (ch.0, ch.1, ch.2) }

}

public extension XYZ {

	/// Default reference white point.
	static let D65 = XYZ(x: 0.95047, y: 1.00000, z: 1.08883)

	static let D50 = XYZ(x: 0.96422, y: 1.00000, z: 0.82521)

	static let hSLuvD65 = XYZ(x: 0.95045592705167, y: 1.0, z: 1.089057750759878)

	static func adapt(xyz: XYZ, from source: XYZ = .D65, to target: XYZ) -> XYZ {
	
		let M: DMatrix = (
			(0.8951, 0.2664, -0.1614),
			(-0.7502, 1.7135, 0.0367),
			(0.0389, -0.0685, 1.0296)
		)

		let M_inv: DMatrix = (
			(0.9869929, -0.1470543, 0.1599627),
			(0.4323053, 0.5183603, 0.0492912),
			(-0.0085287, 0.0400428, 0.9684867)
		)

		let sourceCone = matrixMul(M, source.ch)
		let targetCone = matrixMul(M, target.ch)

		let scale = (
			targetCone.0 / sourceCone.0,
			targetCone.1 / sourceCone.1,
			targetCone.2 / sourceCone.2
		)

		let xyzCone = matrixMul(M, xyz.ch)
		let adaptedCone = (
			xyzCone.0 * scale.0,
			xyzCone.1 * scale.1,
			xyzCone.2 * scale.2
		)

		let adaptedXYZ = matrixMul(M_inv, adaptedCone)

		return XYZ(x: adaptedXYZ.0, y: adaptedXYZ.1, z: adaptedXYZ.2)
	}

}

public extension XYZ {

	func to_XYZ(fromWhiteRef frW: XYZ, toWhiteRef toW: XYZ) -> XYZ {
		return XYZ.adapt(xyz: self, from: frW, to: toW)
	}

	func to_xyY(WhiteRef w: XYZ = .D65) -> XYZ {
		let N = self.x + self.y + self.z

		var x, y: Double
		if abs(N) < 1e-14 {
			x = w.x / (w.x + w.y + w.z)
			y = w.y / (w.x + w.y + w.z)
		} else {
			x = self.x / N
			y = self.y / N
		}

		return XYZ(x: x, y: y, z: self.y)
	}

	func to_UV() -> (u: Double, v: Double) {
		var u, v: Double

		let denom = x + 15.0 * y + 3.0 * z

		if denom == 0.0 {
			(u, v) = (0.0, 0.0)
		} else {
			u = 4.0 * x / denom
			v = 9.0 * y / denom
		}

		return (u, v)
	}

	func toRGB() -> RGB { self.toLinearRGB().toDelinearized() }

	func toLinearRGB() -> RGB {
		let r = 3.240969941904521400 * x - 1.53738317757009350 * y - 0.498610760293003280 * z
		let g = -0.969243636280879830 * x + 1.87596750150772070 * y + 0.041555057407175613 * z
		let b = 0.055630079696993609 * x - 0.20397695888897657 * y + 1.056971514242878600 * z

		return RGB(r: r, g: g, b: b)
	}

	func toLAB(WhiteRef w: XYZ = .D65) -> LAB { LAB(x: x, y: y, z: z, WhiteRef: w) }

	func toLUV(WhiteRef w: XYZ = .D65) -> LUV { LUV(x: x, y: y, z: z, WhiteRef: w) }

	//	func toCAM16() -> CAM16 { CAM16(x: x , y: y , z: z) }

}
