import AppKit

/// From RGBA CGImage
public func extractColorsWithRatio<K: Kolor>(from cgImage: CGImage, maxDepth: Int = 6) -> OcTree<K>.Colors {

	let octree = OcTree<K>(maxDepth: maxDepth)
	
	
	cgImage.rgbBytes { srgb in
		
		let col = srgb.toRGB().toOKLAB()
		octree.insert(color: col as! K)
	}
	
	return octree.getPalette()
}





public final class OcTree<K: Kolor> {
	
	public typealias Colors = [(color: K, ratio: Double)]
	
	private let maxDepth: Int
	private var root = Node()
	private var totalPixels = 0.0
	
	init(maxDepth: Int = 8) {
		self.maxDepth = maxDepth
	}
	
	private final class Node {
		var children: [Node?] = Array(repeating: nil, count: 8)
		var pixelCount = 0.0
		var sumCH1 = 0.0
		var sumCH2 = 0.0
		var sumCH3 = 0.0
		var isLeaf = false
	}
	
	
	func insert(color: K) {
		
		var node = root
		let c = color.normalized()
		
		for depth in 0..<maxDepth {
			
			let bit = 7 - depth
			
			let Lb = Int(c.0 * 255) >> bit & 1
			let ab = Int(c.1 * 255) >> bit & 1
			let bb = Int(c.2 * 255) >> bit & 1
			
			let idx = (Lb << 2) | (ab << 1) | bb
			
			if node.children[idx] == nil {
				node.children[idx] = Node()
			}
			node = node.children[idx]!
		}
		
		node.isLeaf = true
		node.sumCH1 += color.ch.0
		node.sumCH2 += color.ch.1
		node.sumCH3 += color.ch.2
		node.pixelCount += 1

		totalPixels += 1
	}
	
	func getPalette() -> Colors {
		var result: Colors = []
		dfs(node: root, out: &result)
		return result
	}
	
	
	
	private func dfs(node: Node, out: inout Colors) {
		
		if node.isLeaf, node.pixelCount > 0 {
			
			let channels = ( (node.sumCH1 / node.pixelCount), 
								  (node.sumCH2 / node.pixelCount),
								  (node.sumCH3 / node.pixelCount) )
			
			let color = K(ch: channels)
			let ratio = node.pixelCount / totalPixels
			
			return out.append( (color, ratio) )
		}
		
		for child in node.children {
			if let c = child {
				dfs(node: c, out: &out)
			}
		}
	}
	
}

