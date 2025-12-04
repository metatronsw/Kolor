import AppKit
import Kolor

testPerformane_Histogram(levels: 32)

func withTimer(msg: String, div: Int = 1, _ action: () -> ()) {
	let start = mach_absolute_time()

	action()

	let runTime = mach_absolute_time() - start
	print(msg, (runTime / UInt64(div)).formatted(), "ns")
}

func testPerformane_Convert() {
	let num: Int = 100_000
	var rnd: UInt8 { UInt8.random(in: 0..<255) }

	var array = [RGB]()
	array.reserveCapacity(num + 1)

	for _ in 0...num {
		let rgb = sRGB(rnd, rnd, rnd).toRGB()
		array.append(rgb)
	}

	withTimer(msg: "Run TIME:", div: num) {
		for rgb in array {
			let xyz = rgb.toXYZ()
			_ = xyz.to_XYZ(fromWhiteRef: .D65, toWhiteRef: .D50)
		}
	}

	/// xyz d50:
	/// 	Run TIME: 3815 - array mul
	/// 	Run TIME: 4057 - simd mul
	/// 	Run TIME: 333  - tuple matrix

	/// DisplayP3:
	///	Run TIME: 4385 4537 - simd mul
	///   Run TIME: 963, 955 - tuple matrix
}

func testPerformane_Histogram(levels: Int = 4) {
	
	let image = NSImage(data: try! Data.init(contentsOf: URL.desktopDirectory.appending(component: "prog.png")))!.toCGImage()!
	let image2 = NSImage(data: try! Data.init(contentsOf: URL.desktopDirectory.appending(component: "p.jpg")))!.toCGImage()!

	let srgb = image.toSRGB()
	let srgb2 = image2.toSRGB()

	let counts = srgb.makeQuantizedCounts(levels: levels)
	let counts2 = srgb2.makeQuantizedCounts(levels: levels)

	let hist = Histogram(from: counts, levels: levels, totalPixels: srgb.count)
	let hist2 = Histogram(from: counts2, levels: levels, totalPixels: srgb2.count)

	var (a, b) = (0, 0)

	print("Level: \(levels)")

	withTimer(msg: "Basic TIME:") {
		a = hist.distance(to: hist2)
	}
	withTimer(msg: "Simd  TIME:") {
		b = hist.distance_Simd(to: hist2)
	}

	precondition(a == b)


//Level: 8 debug
//	Basic TIME: 5 634 217 ns
//	Simd  TIME: 521 095 ns
	
//Level: 8 release
//	Basic TIME: 451 294 ns
//	Simd  TIME: 502 064 ns
	
}
