/// Artist colour names
///
public enum Art {

	// • BLACK ––––––––––––––––––––––––––––––––––––– •
	static let Anthracite = sRGB(50, 50, 48)
	static let OxideBlack = sRGB(33, 33, 33)
	static let CarbonBlack = sRGB(30, 32, 29)

	// • GRAY –––––––––––––––––––––––––––––––––––––– •
	static let PaynesGray = sRGB(17, 17, 19)
	static let NaturalGray = sRGB(81, 86, 82)
	static let MiddleGray = sRGB(120, 129, 129)
	static let LightGray = sRGB(181, 179, 179)

	// • WHITE ––––––––––––––––––––––––––––––––––––– •
	static let TintWhite = sRGB(241, 241, 241)
	static let ShellWhite = sRGB(243, 243, 236)

	// • BROWN ––––––––––––––––––––––––––––––––––––– •
	static let Umber = sRGB(63, 61, 49)
	static let Burnt = sRGB(69, 54, 46)
	static let Oxide = sRGB(87, 59, 50)
	static let Siena = sRGB(135, 74, 37)
	static let Brown = sRGB(88, 56, 25)

	// • RED ––––––––––––––––––––––––––––––––––––––– •
	static let English = sRGB(119, 63, 50)
	static let Cinnabar = sRGB(227, 68, 42)
	static let Valencia = sRGB(214, 70, 54)
	static let DeepRed = sRGB(188, 63, 55)
	static let Carmine = sRGB(160, 53, 56)
	static let Bordeux = sRGB(114, 54, 65)

	// • ORANGE –––––––––––––––––––––––––––––––––––– •
	static let Flamingo = sRGB(233, 106, 46)
	static let Jaffa = sRGB(238, 150, 67)

	// • YELLOW –––––––––––––––––––––––––––––––––––– •
	static let Ochre = sRGB(154, 106, 41)
	static let Anzac = sRGB(224, 157, 68)
	static let NaplesYellow = sRGB(248, 236, 138)
	static let Lemon = sRGB(241, 226, 92)
	static let EnergyYellow = sRGB(247, 219, 90)
	static let Cadmium = sRGB(242, 146, 91)

	// • GREEN ––––––––––––––––––––––––––––––––––––– •
	static let Apple = sRGB(83, 176, 51)
	static let Chromium = sRGB(42, 96, 64)
	static let DeepEmerald = sRGB(49, 114, 105)
	static let Emerald = sRGB(59, 134, 104)
	static let Green = sRGB(77, 169, 107)
	static let Olive = sRGB(69, 96, 64)

	// • CYAN –––––––––––––––––––––––––––––––––––––– •

	// • BLUE –––––––––––––––––––––––––––––––––––––– •
	static let PrussianBlue = sRGB(75, 81, 98)
	static let Ultramarine = sRGB(17, 49, 157)
	static let Mariner = sRGB(42, 94, 198)
	static let LightBlue = sRGB(153, 186, 236)
	static let Cobalt = sRGB(30, 77, 143)
	static let Cerulean = sRGB(55, 120, 183)
	static let Turquoise = sRGB(70, 158, 174)
	static let LightTurquoise = sRGB(164, 222, 247)

	// • PURPLE –––––––––––––––––––––––––––––––––––– •
	static let Indigo = sRGB(50, 53, 60)
	static let Purple = sRGB(108, 60, 97)
	static let Violet = sRGB(86, 67, 128)

	// • MAGENTA ––––––––––––––––––––––––––––––––––– •
	static let Magenta = sRGB(189, 68, 120)
	static let DeepMagenta = sRGB(172, 62, 90)

	// • PASTEL –––––––––––––––––––––––––––––––––––– •
	static let Bone = sRGB(223, 210, 189)
	static let NaplesOrange = sRGB(246, 209, 195)
	static let NaplesRose = sRGB(240, 222, 196)
	static let CobaltGreen = sRGB(170, 200, 205)

}

public extension Art {

	static let allCases = [BLACKS, GRAYS, WHITES, BROWNS, REDS, ORANGES, YELLOWS, GREENS, CYANS, BLUES, MAGENTAS, PURPLES].flatMap { $0 }

	static let BLACKS: [sRGB] = [
		Art.Anthracite,
		Art.OxideBlack,
		Art.CarbonBlack
	]

	static let GRAYS: [sRGB] = [
		Art.PaynesGray,
		Art.NaturalGray,
		Art.MiddleGray,
		Art.LightGray
	]

	static let WHITES: [sRGB] = [
		Art.TintWhite,
		Art.ShellWhite
	]

	static let BROWNS: [sRGB] = [
		Art.Umber,
		Art.Burnt,
		Art.Oxide,
		Art.Siena,
		Art.Brown
	]

	static let REDS: [sRGB] = [
		Art.English,
		Art.Cinnabar,
		Art.Valencia,
		Art.DeepRed,
		Art.Carmine,
		Art.Bordeux
	]

	static let ORANGES: [sRGB] = [
		Art.Flamingo,
		Art.Jaffa
	]

	static let YELLOWS: [sRGB] = [
		Art.Ochre,
		Art.Anzac,
		Art.NaplesYellow,
		Art.Lemon,
		Art.EnergyYellow,
		Art.Cadmium
	]
	static let GREENS: [sRGB] = [
		Art.Apple,
		Art.Chromium,
		Art.DeepEmerald,
		Art.Emerald,
		Art.Green,
		Art.Olive
	]

	static let CYANS: [sRGB] = []

	static let BLUES: [sRGB] = [
		Art.PrussianBlue,
		Art.Ultramarine,
		Art.Mariner,
		Art.LightBlue,
		Art.Cobalt,
		Art.Cerulean,
		Art.Turquoise,
		Art.LightTurquoise
	]

	static let MAGENTAS: [sRGB] = [
		Art.Magenta,
		Art.DeepMagenta
	]

	static let PURPLES: [sRGB] = [
		Art.Indigo,
		Art.Purple,
		Art.Violet
	]

}
