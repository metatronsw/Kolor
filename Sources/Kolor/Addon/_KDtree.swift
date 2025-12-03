/*

import Accelerate




func findClosestColorVDSP(target: [Float], colors: [[Float]]) -> Int {
	let colorCount = colors.count
	var distances = [Float](repeating: 0, count: colorCount)
	
	for i in 0..<colorCount {
		var diff = [Float](repeating: 0, count: 3)
		vDSP_vsub(colors[i], 1, target, 1, &diff, 1, 3)
		var sum: Float = 0
		vDSP_dotpr(diff, 1, diff, 1, &sum, 3)
		distances[i] = sum
	}
	
	return distances.enumerated().min(by: { $0.element < $1.element })!.offset
}

/// ------------
import simd

let target = simd_float3(0.3, 0.6, 0.2)
let colors: [simd_float3] = [
	simd_float3(1, 0, 0),
	simd_float3(0, 1, 0),
	simd_float3(0, 0, 1)
]

let closest = colors.min { a, b in
	simd_distance(a, target) < simd_distance(b, target)
}

print(closest!)


//
//let tree = buildKDTree(colors)
//var best = colors[0]
//var bestDist: Float = .greatestFiniteMagnitude
//
//nearest(tree, target, best: &best, bestDist: &bestDist)


final class KDNode {
	let point: simd_float3
	let axis: Int
	var left: KDNode?
	var right: KDNode?
	
	init(point: simd_float3, axis: Int) {
		self.point = point
		self.axis = axis
	}
}

func buildKDTree(_ points: [simd_float3], depth: Int = 0) -> KDNode? {
	guard !points.isEmpty else { return nil }
	
	let axis = depth % 3
	let sorted = points.sorted { $0[axis] < $1[axis] }
	let mid = sorted.count / 2
	let node = KDNode(point: sorted[mid], axis: axis)
	
	node.left = buildKDTree(Array(sorted[..<mid]), depth: depth + 1)
	node.right = buildKDTree(Array(sorted[(mid+1)...]), depth: depth + 1)
	
	return node
}

@inline(__always)
func dist2(_ a: simd_float3, _ b: simd_float3) -> Float {
	let d = a - b
	return simd_dot(d, d)
}

func nearest(_ node: KDNode?, _ target: simd_float3,
				 best: inout simd_float3, bestDist: inout Float) {
	guard let node else { return }
	
	let d = dist2(node.point, target)
	if d < bestDist {
		bestDist = d
		best = node.point
	}
	
	let axis = node.axis
	let diff = target[axis] - node.point[axis]
	
	let first = diff < 0 ? node.left : node.right
	let second = diff < 0 ? node.right : node.left
	
	nearest(first, target, best: &best, bestDist: &bestDist)
	
	if diff * diff < bestDist {
		nearest(second, target, best: &best, bestDist: &bestDist)
	}
}


*/
