import SwiftUI

public extension Color {

	init(_ rgb: sRGB) {
		self.init(red: Double(rgb.r) / 255, green: Double(rgb.g) / 255, blue: Double(rgb.b) / 255)
	}

	init(_ rgb: RGB) {
		self.init(red: rgb.r, green: rgb.g, blue: rgb.b)
	}

	init(p3: RGB) {
		self = Color(.displayP3, red: p3.r, green: p3.g, blue: p3.b)
	}

	init(_ col: some Kolor) {
		let rgb = col.toRGB()
		self.init(red: rgb.r, green: rgb.g, blue: rgb.b)
	}

}

public extension Image {

	init(cgImage: CGImage) {
		self.init(decorative: cgImage, scale: 1)
	}

	init?(data: Data) {
		#if os(macOS)
			guard let nsImage = NSImage(data: data) else { return nil }

			self.init(nsImage: nsImage)
		#else
			guard let uiImage = UIImage(data: data) else { return nil }

			self.init(uiImage: uiImage)
		#endif
	}

	init?(named name: String) {
		#if os(macOS)
			guard let nsImage = NSImage(named: name) else { return nil }

			self.init(nsImage: nsImage)
		#else
			guard let uiImage = UIImage(named: name) else { return nil }

			self.init(uiImage: uiImage)
		#endif
	}

}

