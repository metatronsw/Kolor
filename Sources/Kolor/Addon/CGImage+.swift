#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif


#if canImport(AppKit)
public extension NSImage {
	
	func toCGImage() -> CGImage? {
		var rect = CGRect(origin: .zero, size: self.size)
		guard let cgImage = self.cgImage(forProposedRect: &rect, context: nil, hints: nil) else { return nil }
		
		return cgImage
	}
	
}
#elseif canImport(UIKit)
public extension UIImage {
	
	func toCGImage() -> CGImage? {
		var rect = CGRect(origin: .zero, size: self.size)
		guard let cgImage = self.cgImage(forProposedRect: &rect, context: nil, hints: nil) else { return nil }
		
		return cgImage
	}
	
}
#endif

public extension CGImage {
	
	static func initFrom(systemNamed name: String) -> CGImage? {
#if canImport(AppKit)
		guard let nsImage = NSImage(named: name) else { return nil }
		
		return nsImage.toCGImage()
#elseif canImport(UIKit)
		guard let uiImage = UIImage(named: name) else { return nil }
		
		return uiImage.toCGImage()
#endif
	}
	
	static func initFrom(kolor: [any Kolor], width: Int, height: Int) -> CGImage? {
		let srgb = kolor.map { $0.toSRGB() }
		return Self.initFrom(rgb: srgb, width: width, height: height)
	}
	
	static func initFrom(rgb: [sRGB], width: Int, height: Int) -> CGImage? {
		guard width > 0, height > 0 else { return nil }
		
		guard rgb.count == width * height else { return nil }
		
		let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
		let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
		let bitsPerComponent = 8
		let bitsPerPixel = 24
		
		var data = rgb
		guard let providerRef = CGDataProvider(data: NSData(bytes: &data, length: data.count * MemoryLayout<sRGB>.size))
		else { return nil }
		
		return CGImage(
			width: width,
			height: height,
			bitsPerComponent: bitsPerComponent,
			bitsPerPixel: bitsPerPixel,
			bytesPerRow: width * MemoryLayout<sRGB>.size,
			space: rgbColorSpace,
			bitmapInfo: bitmapInfo,
			provider: providerRef,
			decode: nil,
			shouldInterpolate: true,
			intent: .defaultIntent
		)
	}
	
	func toSRGBsafe() -> [sRGB] {
		guard self.bitsPerPixel == 32, self.bitsPerComponent == 8 else { return [] }
		
		guard let imageData = self.dataProvider?.data as Data? else { return [] }
		
		let size = self.width * self.height
		let buffer = UnsafeMutableBufferPointer<UInt32>.allocate(capacity: size)
		_ = imageData.copyBytes(to: buffer)
		
		var result = [sRGB]()
		result.reserveCapacity(size)
		
		if self.byteOrderInfo == .orderDefault || self.byteOrderInfo == .order32Big {
			for pixel in buffer {
				result.append(sRGB(bigEndian: pixel))
			}
		}
		
		else if self.byteOrderInfo == .order32Little {
			for pixel in buffer {
				result.append(sRGB(littleEndian: pixel))
			}
		}
		
		return result
	}
	
	func toSRGB() -> [sRGB] {
		guard self.bitsPerPixel == 32, self.bitsPerComponent == 8 else { return [] }
		
		let width = self.width
		let height = self.height
		let bytesPerPixel = 4
		let bytesPerRow = width * bytesPerPixel
		
		var data = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
		
		data.withUnsafeMutableBytes { ptr in
			let context = CGContext(
				data: ptr.baseAddress,
				width: width,
				height: height,
				bitsPerComponent: 8,
				bytesPerRow: bytesPerRow,
				space: CGColorSpaceCreateDeviceRGB(),
				bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
			)!
			
			context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
		}
		
		var srgb = [sRGB]()
		//		srgb.reserveCapacity(data.count)// * MemoryLayout<sRGB>.size)
		
		for i in stride(from: 0, to: data.count, by: 4) {
			let r = data[i]
			let g = data[i + 1]
			let b = data[i + 2]
			// let a = data[i+3]
			srgb.append(sRGB(r, g, b))
		}
		
		//		print("srgb.capacity", srgb.capacity, srgb.count)
		return srgb
	}
	
	/// Fast in place pointer method
	func rgbBytes(action: (sRGB) -> ()) {
		guard let cfData = self.dataProvider?.data else { fatalError() }
		
		let data = CFDataGetBytePtr(cfData)!
		let count = CFDataGetLength(cfData)
		
		for i in stride(from: 0, to: count, by: 4) {
			let r = data[i]
			let g = data[i + 1]
			let b = data[i + 2]
			//		let a = data[i+3]
			
			let color = sRGB(r, g, b)
			
			action(color)
		}
	}
	
}
