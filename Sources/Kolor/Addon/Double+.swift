#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif


public extension Double {
	
	func clamped() -> Self {
		guard self.isFinite else { return self > 0 ? 1 : 0 }
		return max(0, min(1, self))
	}
	
	func deg2rad() -> Double { self * .pi / 180.0 }
	
	func rad2deg() -> Double { self * 180.0 / .pi }
	
}



public extension Double {
	
	func normalize(in rng: ClosedRange<Double>) -> Double {
		let t = (self - rng.lowerBound) / (rng.upperBound - rng.lowerBound)
		guard t.isFinite else { return 0.0 }
		if t < 0 { return 0.0 }
		if t > 1 { return 1.0 }
		return t
	}
	
//	// Logaritmikus skála - jobban megőrzi a kis értékeket
//	func toUInt16Log() -> UInt16 {
//		guard self > 0 else { return 0 }
//		let log = log10(self * 1_000_000 + 1) / 6.0  // 0...1 tartományba
//		return UInt16(min(65535, log * 65535))
//	}
//	
//	init(fromUInt16Log value: UInt16) {
//		let log = Double(value) / 65535.0 * 6.0
//		return (pow(10, log) - 1) / 1_000_000
//	}
	
	
	func linearize() -> Double {
		//		if self <= 0.04045 { return self / 12.92 }
		//		return pow((self + 0.055) / 1.055, 2.4)
		
		return self <= 0.04045
		? self / 12.92
		: pow((self + 0.055) / 1.055, 2.4)
	}
	
	
	
	func linearizeFast() -> Double {
		let v1 = self - 0.5
		let v2 = v1 * v1
		
		let v3 = v2 * v1
		let v4 = v2 * v2
		
		return -0.248750514614486 + 0.925583310193438 * self + 1.16740237321695 * v2 + 0.280457026598666 * v3 - 0.0757991963780179 * v4
	}
	
	
	
	func delinearize() -> Double {
		if self <= 0.0031308 { return 12.92 * self }
		return 1.055 * pow(self, 1.0 / 2.4) - 0.055
	}
	
	
	
	func delinearizeFast() -> Double {
		var v1, v2, v3, v4, v5: Double
		
		if self > 0.2 {
			v1 = self - 0.6
			v2 = v1 * v1
			v3 = v2 * v1
			v4 = v2 * v2
			v5 = v3 * v2
			
			return 0.442430344268235 + 0.592178981271708 * self - 0.287864782562636 * v2 + 0.253214392068985 * v3 - 0.272557158129811 * v4 + 0.325554383321718 * v5
		}
		
		else if self > 0.03 {
			v1 = self - 0.115
			v2 = v1 * v1
			v3 = v2 * v1
			v4 = v2 * v2
			v5 = v3 * v2
			
			return 0.194915592891669 + 1.55227076330229 * self - 3.93691860257828 * v2 + 18.0679839248761 * v3 - 101.468750302746 * v4 + 632.341487393927 * v5
		}
		
		else {
			v1 = self - 0.015
			v2 = v1 * v1
			v3 = v2 * v1
			v4 = v2 * v2
			v5 = v3 * v2
			
			return 0.0519565234928877 + 5.09316778537561 * self - 99.0338180489702 * v2 + 3484.52322764895 * v3 - 150_028.083412663 * v4 + 7_168_008.42971613 * v5
		}
	}
	
	
}


// MARK: Helper functions ––––––––––––––––––––––––––––––––––––––––––––––––––––– •

public typealias DPack = (Double,Double,Double)
public typealias DMatrix = (DPack,DPack,DPack)

@inlinable
@inline(__always)
public func matrixMul(_ mat: DMatrix, _ ch: DPack ) -> DPack {
	return (
		mat.0.0 * ch.0 + mat.0.1 * ch.1 + mat.0.2 * ch.2,
		mat.1.0 * ch.0 + mat.1.1 * ch.1 + mat.1.2 * ch.2,
		mat.2.0 * ch.0 + mat.2.1 * ch.1 + mat.2.2 * ch.2
	)
}

@inlinable
@inline(__always)
public func sq<T: Numeric>(_ v: T) -> T { v * v }

@inlinable
@inline(__always)
public func cub<T: Numeric>(_ v: T) -> T { v * v * v }

