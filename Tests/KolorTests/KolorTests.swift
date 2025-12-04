import XCTest
//@testable import Kolor
import Kolor

final class KolorTests: XCTestCase {

	func testConversion() throws {
				
		let srgb = sRGB(123, 223, 68)

		XCTAssertEqual(srgb, srgb.toCMYK().toSRGB(), "CMYK")
		
		XCTAssertEqual(srgb, srgb.toDIN99().toSRGB(), "DIN99")
		XCTAssertEqual(srgb, srgb.toHCL().toSRGB(), "HCL")
		XCTAssertEqual(srgb, srgb.toHSL().toSRGB(), "HSL")
		XCTAssertEqual(srgb, srgb.toHSLuv().toSRGB(), "HSLuv")
		XCTAssertEqual(srgb, srgb.toHSV().toSRGB(), "HSV")
		XCTAssertEqual(srgb, srgb.toLAB().toSRGB(), "LAB")
		XCTAssertEqual(srgb, srgb.toLCh().toSRGB(), "LCh")
		XCTAssertEqual(srgb, srgb.toLUV().toSRGB(), "LUV")
		XCTAssertEqual(srgb, srgb.toOKLAB().toSRGB(), "OKLAB")
		XCTAssertEqual(srgb, srgb.toOKLCh().toSRGB(), "OKLCh")
		XCTAssertEqual(srgb, srgb.toRGB().toSRGB(), "RGB")
		XCTAssertEqual(srgb, srgb.toXYZ().toSRGB(), "XYZ")
		XCTAssertEqual(srgb, srgb.toYUV().toSRGB(), "YUV")
		
		
		XCTAssertEqual(srgb, srgb.toRGB().toDisplayP3().displayP3_toRGB().toSRGB(), "DisplayP3")
		XCTAssertEqual(srgb, srgb.toRGB().toDisplayP3Linear().displayP3Linear_toRGB().toSRGB(), "DisplayP3Linear")

	}


	func testExactly() throws {
		
		let c1 = RGB(0.5, 0.2, 0.1)
		
		XCTAssertEqual(c1.toCMYK().description, "[0.000 0.600 0.800 0.500]", "CMYK") // 0 0.6 0.8 0.5
		
		// TODO: Din99(o) ???
		XCTAssertEqual(c1.toDIN99().description, "[0.376 0.554 0.502]", "DIN99") // din99o 35.489 24.877 22.515
		
		XCTAssertEqual(c1.toHCL().description, "[45.227 0.448 0.318]", "HCL")
		XCTAssertEqual(c1.toHSL().description, "[15.000 0.667 0.300]", "HSL") // 15 66.667 30
		XCTAssertEqual(c1.toHSLuv().description, "[21.154 0.840 0.318]", "HSLuv") // 21.154 83.995 31.787
		
		// TODO: HPLuv implement
		let lch = c1.toLCh()
		XCTAssertEqual(HSLuv(Pastel: lch.l, c: lch.c, h: lch.spectrum).description, "[21.149 1.000 0.318]", "HPLuv") // --hpluv 21.154 249.26 31.787  
		
		XCTAssertEqual(c1.toHSV().description, "[15.000 0.800 0.500]", "HSV") // 15 0.8 0.5
		XCTAssertEqual(c1.toLAB().description, "[0.318 0.316 0.318]", "LAB") // d65 31.787 31.563 31.816
		XCTAssertEqual(c1.toLCh().description, "[0.318 0.624 21.149]", "LCh") // 32.25 46.164 44.929 | d65 31.787 44.816 45.229
		XCTAssertEqual(c1.toLUV().description, "[0.318 0.582 0.225]", "LUV") // 31.787 58.232 22.532
		XCTAssertEqual(c1.toOKLAB().description, "[0.424 0.088 0.070]", "OKLAB") // 0.42389 0.08839 0.06993
		
		// TODO: is it oklRAB ??? 0.33479 0.08839 0.06993
		XCTAssertEqual(c1.toOKLCh().description, "[0.424 0.113 0.669]", "OKLCh") // 0.42389 0.11271 38.347 
		
		XCTAssertEqual(c1.toXYZ().to_xyY().description, "[0.538 0.369 0.070]", "xyY") // 0.53799 0.36905 0.06991
		XCTAssertEqual(c1.toXYZ().description, "[0.102 0.070 0.018]", "XYZ")
		XCTAssertEqual(c1.toXYZ().to_XYZ(fromWhiteRef: .D65, toWhiteRef: .D65).description, "[0.102 0.070 0.018]", "XYZ d65") // d65 0.10192 0.06991 0.01761
		XCTAssertEqual(c1.toXYZ().to_XYZ(fromWhiteRef: .D65, toWhiteRef: .D50).description, "[0.108 0.072 0.013]", "XYZ d50") // d50 0.10752 0.07196 0.01335
		XCTAssertEqual(c1.toYUV().description, "[16.239 127.912 128.139]", "YUV")
		
		
		let col = RGB(0.5, 0.1, 0.1)

		XCTAssertEqual(col.toHSLuv().description, "[12.177 0.795 0.277]", "HSLuv")
		XCTAssertEqual(col.toLCh().description, "[0.277 0.740 12.173]", "LCh")
		XCTAssertEqual(col.toLUV().description, "[0.277 0.723 0.156]", "LUV")
		XCTAssertEqual(col.toLAB().description, "[0.277 0.427 0.275]", "LAB")
		XCTAssertEqual(col.toXYZ().description, "[0.094 0.053 0.015]", "XYZ")
	
		XCTAssertEqual(col.toDisplayP3().description, "[0.459 0.137 0.121]", "P3")
		XCTAssertEqual(col.toDisplayP3Linear().description, "[0.178 0.017 0.014]", "P3Lin")
		
		
		let xyz = RGB(1, 0.5, 0.2).toXYZ()
		let adapt = xyz.to_XYZ(fromWhiteRef: .D65, toWhiteRef: .D50)
		
		XCTAssertEqual(xyz.description,   "[0.495 0.368 0.076]", "D65")
		XCTAssertEqual(adapt.description, "[0.523 0.378 0.058]", "D50")
	}

}


