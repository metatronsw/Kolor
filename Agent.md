# Kolor Agent

## Overview

Kolor is a Swift library for working with various color spaces and performing color operations. It allows easy conversion between color spaces, color distance calculations, palette generation, image processing, and color grouping. It includes a large collection of predefined colors useful for design and scientific tasks.

## Features

* **Color Spaces:** Supports sRGB, Display P3, Rec. 2020, ProPhoto RGB, linear RGB, HSV, HSL, HWB, HSI, Okhsv/Okhsl, OkLCh, HPLuv, HSLuv, XYZ, Lab-like, LCh-like, ACES, CMYK, and more.
* **Conversions:** Convert colors between different color spaces if possible.
* **Color Distance:** Use `distance(from:)` or deltaE functions for Uniform Color Spaces (UCS) and sRGB.
* **Palette Generation:** For cylindrical color spaces (Hue channel), generate palettes via `paletteGen(bySteps: Int, saturation: Double, value: Double)`.
* **Image Processing:** Convert, analyze, and group image colors quickly and easily.
* **Predefined Color Collections:** A large collection of artistic and scientific colors.

## Design Principles

* Simple and flexible logic for color manipulation.
* sRGB stores values per channel as `UInt8` (0…255), other color spaces use normalized `Double` (0…1), except cylindrical color spaces where Hue is 0…360.
* Built-in extensions for `CGImage` and `Image` classes to simplify image operations.

## Usage Examples

```swift
// Converting a color from sRGB to HSL
let hslColor = sRGBColor.red.toHSL()

// Generating a palette in HSV
let palette = hsvColor.paletteGen(bySteps: 12, saturation: 0.8, value: 0.9)

// Calculating distance between two colors
let distance = color1.distance(from: color2)

// Convert NSImage to array of pixels
let image = NSImage(named: "cat").toCGImage()
let pixels = image.toSRGB()

// Quantanize image	
let counts = pixels.makeQuantizedCounts(levels: 4)
let hist = Histogram(from: counts, levels: 4, totalPixels: pixels.count)

// Identifies the most significant colors	 
let colors = extractColorsWithRatio(from: image, maxDepth: 5)
	
// Posterize image
let quantized = pixels.map { $0.toQuantized(by: 4) }
let posterized = CGImage.initFrom(rgb: quantized, width: image.width, height: image.height)

```

## Notes

* Components and formulas are adapted from multiple sources and rewritten in Swift.
* Other components translated from C, C++, C#, Python, and JavaScript libraries.
* Library targets Swift 5.6+.
