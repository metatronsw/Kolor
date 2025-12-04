// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "Kolor",

	platforms: [
		.iOS(.v16),
		.macOS(.v13),
		.tvOS(.v15),
		.watchOS(.v8)
	],

	products: [
		.library(
			name: "Kolor",
			targets: ["Kolor"]
		),
	],

	targets: [
		.target(name: "Kolor"),
		
		.testTarget(name: "KolorTests", dependencies: ["Kolor"]),

		.executableTarget(
			name: "Benchmark",
			dependencies: ["Kolor"]
		)
	]
)
//	.testTarget(name: "KolorTests",
//					dependencies: ["Kolor"],
//					swiftSettings: [.unsafeFlags(["-O"], .when(configuration: .release))]),
