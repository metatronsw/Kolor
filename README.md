# Kolor

A library for color spaces and conversions in Swift 5.6+ 

With this library, image conversion, analysis, color similarity, quantization, indexing, and grouping by tones can be implemented easily and quickly.

In addition, the library includes a large collection of colors. These artistic and scientific values can be useful for design work or tasks involving color groups.

The sRGB color space naturally stores color values per channel as UInt8 (0…255), while the other color spaces store normalized values as Double (0…1), except for those cylindrical color spaces, where the Hue is stored in the (0…360) range. 

With simple and easily variable logic, different color spaces can be converted to another if possible. 

sRGB › RGB
RGB › XYZ, HSV, HSL, OKLAB, OKLCH, YUV, CMYK
XYZ › xyY, UV, LAB, LUV, CAM16
LUV › LCh › HSLuv / HPLuv


In color spaces that are Uniform Color Spaces (UCS) and sRGB, the *distance(from:)* method or special deltaE functions can be applied.

In color spaces that include a cylindrical (Hue) channel, palette generation can be done with *paletteGen(bySteps: Int, saturation: Double, value: Double)*.

There are excellent and useful extensions for the CGImage and Image classes.


Supported:
=========

## RGB Color Spaces
- **sRGB**
- **Display P3**
- A98 RGB
- Rec. 2020
- Rec. 2020 (OETF)
- ProPhoto RGB
- Rec. 709
- Rec. 709 (OETF)
- Rec. 2100 PQ
- Rec. 2100 HLG
- **Linear sRGB**
- **Linear Display P3**
- Linear A98 RGB
- Linear Rec. 2020
- Linear Rec. 2100
- Linear ProPhoto RGB

## Cylindrical sRGB Spaces
- **HSV**
- **HSL**
- HWB
- HSI
- Okhsv
- Okhsl
- **OkLCh**
- **HSLuv**
- **HPLuv**
- Cubehelix

## XYZ Spaces
- **XYZ D65**
- **XYZ D50**

## Lab Like Spaces
- **Lab D50**
- **Lab D65**
- **Oklab**
- Oklrab
- **Luv**
- **DIN99o**
- Jzazbz
- Hunter Lab
- RLAB
- IPT
- ICtCp
- IgPgTg
- CAM02 UCS
- CAM02 SCD
- CAM02 LCD
- CAM16 UCS *in progress...*
- CAM16 SCD
- CAM16 LCD
- XYB

## LCh Like Spaces
- **LCh D50**
- **LCh D65**
- OkLCh
- OkLrCh
- LCh(uv)
- DIN99 LCh
- JzCzhz
- CAM02 JMh
- CAM16 JMh
- Hellwig JMh
- HCT
- ZCAM JMh

## ACES Spaces
- ACES 2065-1
- ACEScg
- ACEScc
- ACEScct

## Miscellaneous Spaces
- **xyY**
- CIE 1960 UCS
- RYB
- CMY
- **CMYK**
- oRGB
- Prismatic


The various components and formulas were gathered from multiple sources and rewritten from: 

    1 Copyright (c) Lucas Beyer - https://github.com/lucasb-eyer/go-colorful
    2 Copyright (c) Artur Torun (a.k.a. Mojzesh) - https://github.com/mojzesh/swift-colorful
    3 Copyright (c) HSLuv Project - https://github.com/hsluv/hsluv-swift

The other components are translated from C, C++, C#, Python, and JavaScript libraries. The add-ons and helper functions were written directly into the library, with many useful and well-known functions adapted to the project.


