/// sRGB Centroids for ISCC-NBS Level 2 Categories
/// Inter-Society Color Council (ISCC) and the National Bureau of Standards (NBS, now NIST)
///
public enum ISCC_NBS {
	
	public static let Black          = sRGB(43, 41, 43)
	public static let White          = sRGB(231, 225, 233)
	public static let Gray           = sRGB(147, 142, 147)
	public static let Pink           = sRGB(230, 134, 151)
	public static let Red            = sRGB(185, 40, 66)
	public static let YellowishPink  = sRGB(234, 154, 144)
	public static let ReddishOrange  = sRGB(215, 71, 42)
	public static let ReddishBrown   = sRGB(122, 44, 38)
	public static let Orange         = sRGB(220, 125, 52)
	public static let Brown          = sRGB(127, 72, 41)
	public static let OrangeYellow   = sRGB(227, 160, 69)
	public static let YellowishBrown = sRGB(151, 107, 57)
	public static let Yellow         = sRGB(217, 180, 81)
	public static let OliveBrown     = sRGB(127, 97, 41)
	public static let GreenishYellow = sRGB(208, 196, 69)
	public static let Olive          = sRGB(114, 103, 44)
	public static let YellowYreen    = sRGB(160, 194, 69)
	public static let OliveGreen     = sRGB(62, 80, 31)
	public static let YellowishGreen = sRGB(74,195,77)
	public static let Green          = sRGB(79,191,154)
	public static let BluishGreen    = sRGB(67,189,184)
	public static let GreenishBlue   = sRGB(62,166,198)
	public static let Blue           = sRGB(59,116,192)
	public static let PurplishBlue   = sRGB(79,71,198)
	public static let Violet         = sRGB(120,66,197)
	public static let Purple         = sRGB(172,74,195)
	public static let ReddishPurple  = sRGB(187,48,164)
	public static let PurplishPink   = sRGB(229,137,191)
	public static let PurplishRed    = sRGB(186,43,119)
}

public extension ISCC_NBS {
		
	static let allCases: [sRGB] = [
		Self.Black,
		Self.White,
		Self.Gray,
		Self.Pink,
		Self.Red,
		Self.YellowishPink,
		Self.ReddishOrange,
		Self.ReddishBrown,
		Self.Orange,
		Self.Brown,
		Self.OrangeYellow,
		Self.YellowishBrown,
		Self.Yellow,
		Self.OliveBrown,
		Self.GreenishYellow,
		Self.Olive,
		Self.YellowYreen,
		Self.OliveGreen,
		Self.YellowishGreen,
		Self.Green,
		Self.BluishGreen,
		Self.GreenishBlue,
		Self.Blue,
		Self.PurplishBlue,
		Self.Violet,
		Self.Purple,
		Self.ReddishPurple,
		Self.PurplishPink,
		Self.PurplishRed
	]
	
}
