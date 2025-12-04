import SwiftUI
import os



public enum Tone: Int, CaseIterable, Identifiable, Comparable, Codable {

	case BLACK
	case GRAY
	case WHITE
	
	case BROWN
	case MERLOT
	case RED
	
	case ORANGE
	case OCHRE
	case YELLOW
	
	case OLIVE
	case MOSS
	case GREEN
	case MINT
	case TEAL
	
	case CYAN
	case MARINE
	case BLUE
	case AZURE
	
	case PURPLE
	case VIOLET
	case MAGENTA

	case PINK
	case CORAL
	case PASTEL
	case BEIGE

}




public extension Tone {

	init(name: String) throws {
		
		let word = name
			.uppercased()
			.applyingTransform(.stripDiacritics, reverse: false) ?? ""

		self = switch word {
				
			case "K", "black": .BLACK
			case "A", "gray": .GRAY
			case "W", "white": .WHITE
			case "N", "brown": .BROWN
			case "E", "merlot": .MERLOT
			case "R", "red": .RED
			case "O", "orange": .ORANGE
			case "H", "ochre": .OCHRE
			case "Y", "yellow": .YELLOW
			case "L", "olive": .OLIVE
			case "Q", "moss": .MOSS
			case "G", "green": .GREEN
			case "I", "mint": .MINT
			case "T", "teal": .TEAL
			case "C", "cyan": .CYAN
			case "F", "deep": .MARINE
			case "B", "blue": .BLUE
			case "Z", "azure": .AZURE
			case "U", "purple": .PURPLE
			case "V", "violet": .VIOLET
			case "M", "magenta": .MAGENTA
			case "P", "pink": .PINK
			case "X", "coral": .CORAL
			case "S", "pastel": .PASTEL
			case "D", "beige": .BEIGE
				
			default:
				throw POSIXError(.EINVAL)
		}
	}
	
	var chr: Character {
		switch self {
			case .BLACK: "K"
			case .GRAY: "A"
			case .WHITE: "W"
			case .BROWN: "N"
			case .MERLOT: "E"
			case .RED: "R"
			case .ORANGE: "O"
			case .OCHRE: "H"
			case .YELLOW: "Y"
			case .OLIVE: "L"
			case .MOSS: "Q"
			case .GREEN: "G"
			case .MINT: "I"
			case .TEAL: "T"
			case .CYAN: "C"
			case .MARINE: "F"
			case .BLUE: "B"
			case .AZURE: "Z"
			case .PURPLE: "U"
			case .VIOLET: "V"
			case .MAGENTA: "M"
			case .PINK: "P"
			case .CORAL: "X"
			case .PASTEL: "S"
			case .BEIGE: "D"
		}
	}

	func toSRGB() -> sRGB {
		switch self {
			case .BLACK: .BLACK
			case .GRAY: .GRAY
			case .WHITE: .WHITE
			case .BROWN: .BROWN
			case .BEIGE: .BEIGE
			case .MERLOT: .MERLOT
			case .RED: .RED
			case .ORANGE: .ORANGE
			case .OCHRE: .OCHRE
			case .YELLOW: .YELLOW
			case .OLIVE: .OLIVE
			case .GREEN: .GREEN
			case .MOSS: .MOSS
			case .MINT: .MINT
			case .TEAL: .TEAL
			case .CYAN: .CYAN
			case .MARINE: .MARINE
			case .BLUE: .BLUE
			case .AZURE: .AZURE
			case .PURPLE: .PURPLE
			case .VIOLET: .VIOLET
			case .MAGENTA: .MAGENTA
			case .PINK: .PINK
			case .CORAL: .CORAL
			case .PASTEL: .PASTEL
		}
	}
}
	

	




public extension Tone {

	typealias ToneSet = Set<sRGB>
	typealias Container = Array<ToneSet>
	typealias ToneDict = Dictionary<UInt32, Tone>

	static func makeContainer() -> Container {
		var container: Container = .init(repeating: ToneSet(), count: Tone.allCases.count)

		for i in container.indices {
			let tone = Tone.init(rawValue: i)!
			container[i].formUnion(tone.staticSet())
		}

		return container
	}


	static func makeContainerDict() -> ToneDict {
		
		var dict: ToneDict = [:]
		
		for tone in Tone.allCases {
			for rgb in tone.staticSet() {
				dict[rgb.hex] = tone
//				print(rgb, rgb.hex, rgb.hashValue, tone.name)
			}
		}
//		print(dict.count)
		return dict
	}



	init?(by rgb: sRGB, in container: Container) {
		
		if let index = Tone.isContainParallel(by: rgb, in: container),
			let tone = Tone.init(rawValue: index) {
			self = tone
			return
		}

		return nil
	}



	static func isContain(by rgb: sRGB, in dict: ToneDict) -> Int? {
//		let start = mach_absolute_time()
//		defer { print(rgb, "isDict:", elapsed(start) / 100) }

		return dict[rgb.hex]?.rawValue
	}



	static func isContainParallel(by rgb: sRGB, in container: Container) -> Int? {
//		let start = mach_absolute_time()
//		defer { print(rgb, "isContain:", elapsed(start) / 100) }

		guard !container.isEmpty else { return nil }

		let lock = OSAllocatedUnfairLock()
		var foundIndex: Int? = nil

		DispatchQueue.concurrentPerform(iterations: container.count) { i in
			guard foundIndex == nil else { return }

			if container[i].contains(rgb) {
				if foundIndex == nil {
					lock.lock()
					foundIndex = i
					lock.unlock()
					return
				}
			}
		}

		return foundIndex
	}



	func staticSet() -> ToneSet {
		switch self {
			case .BLACK: .BLACKs
			case .GRAY: .GRAYs
			case .WHITE: .WHITEs
			case .BROWN: .BROWNs
			case .BEIGE: .BEIGEs
			case .MERLOT: .MERLOTs
			case .RED: .REDs
			case .ORANGE: .ORANGEs
			case .OCHRE: .OCHREs
			case .YELLOW: .YELLOWs
			case .OLIVE: .OLIVEs
			case .MOSS: .MOSSs
			case .GREEN: .GREENs
			case .MINT: .MINTs
			case .TEAL: .TEALs
			case .CYAN: .CYANs
			case .MARINE: .MARINEs
			case .BLUE: .BLUEs
			case .AZURE: .AZUREs
			case .PURPLE: .PURPLEs
			case .VIOLET: .VIOLETs
			case .MAGENTA: .MAGENTAs
			case .PINK: .PINKs
			case .CORAL: .CORALs
			case .PASTEL: .PASTELs
		}
	}


	init(HSL hsl: HSL) {
		if hsl.l < 0.025 { self = .BLACK; return }
		if hsl.l > 0.95 { self = .WHITE; return }


		if hsl.s < 0.05 { self = .GRAY; return }
		if hsl.s < 0.05 { self = .WHITE; return }


		if hsl.s < 0.05 { self = .GRAY; return }

		self = switch hsl.h {
			case 0 ..< 5: .RED
			case 5 ..< 30: .ORANGE
			case 30 ..< 64: .YELLOW
			case 64 ..< 150: .GREEN
			case 150 ..< 180: .CYAN
			case 180 ..< 260: .BLUE
			case 265 ..< 275: .PURPLE
			case 275 ..< 328: .MAGENTA
			case 328 ..< 360: .RED
			default: .BLACK
		}
	}

	
	static func < (lhs: Self, rhs: Self) -> Bool {
		lhs.rawValue < rhs.rawValue
	}
	
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(String(self.chr))
	}
	
	
	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let chr = try container.decode(String.self)
		try self.init(name: chr)
	}
	
	
	
	var id: Int { self.rawValue }
	
	
	var name: String {
		String(describing: self)
	}

	
}



public extension Set {

	//	func sortedColorNames() -> String {
	//		return self
	//			.sorted { $0.rawValue > $1.rawValue }
	//			.compactMap { $0.name }
	//			.joined(separator: ", ")
	//	}

	mutating func toggle(_ elem: Element) {
		if self.contains(elem) { self.remove(elem) }
		else { self.insert(elem) }
	}

}


func elapsed(_ start: UInt64) -> UInt64 {
	// let start = mach_absolute_time()
	let end = mach_absolute_time()

	//	var timebase = mach_timebase_info_data_t()
	//	mach_timebase_info(&timebase) // numer/denom a skálázáshoz

	//	let elapsed = (end - start) * timebase.numer / Double(timebase.denom) // nanosec
	let elapsed = (end - start)
	return elapsed
}


