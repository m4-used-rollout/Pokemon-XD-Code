//
//  XGPokeSpots.swift
//  XG Tool
//
//  Created by StarsMmd on 08/06/2015.
//  Copyright (c) 2015 StarsMmd. All rights reserved.
//

import Foundation

enum XGPokeSpots : Int, XGDictionaryRepresentable {
	
	case rock		= 0x00
	case oasis		= 0x01
	case cave		= 0x02
	case all		= 0x03
	
	var string : String {
		get {
			switch self {
				case .rock	: return "Rock"
				case .oasis	: return "Oasis"
				case .cave	: return "Cave"
				case .all	: return "All"
			}
		}
	}
	
	var dictionaryRepresentation: [String : AnyObject] {
		get {
			return ["Value" : self.rawValue as AnyObject]
		}
	}
	
	var readableDictionaryRepresentation: [String : AnyObject] {
		get {
			return ["Value" : self.string as AnyObject]
		}
	}
	
	var numberOfEntries : Int {
		let rel = XGFiles.common_rel.data!
		return rel.get4BytesAtOffset(self.commonRelEntriesIndex.startOffset)
	}
	
	func setEntries(entries: Int) {
		let rel = XGFiles.common_rel.data!
		rel.replace4BytesAtOffset(self.commonRelEntriesIndex.startOffset, withBytes: entries)
		rel.save()
	}
	
	var commonRelIndex : CommonIndexes {
		get {
			switch self {
			case .rock:
				return .PokespotRock
			case .oasis:
				return .PokespotOasis
			case .cave:
				return .PokespotCave
			case .all:
				return .PokespotAll
			}
		}
	}
	
	var commonRelEntriesIndex : CommonIndexes {
		get {
			switch self {
			case .rock:
				return .PokespotRockEntries
			case .oasis:
				return .PokespotOasisEntries
			case .cave:
				return .PokespotCaveEntries
			case .all:
				return .PokespotAllEntries
			}
		}
	}
	
	
	func relocatePokespotData(toOffset offset: Int) {
		
		common.replacePointer(index: self.commonRelIndex.rawValue, newAbsoluteOffset: offset)
		
	}
}





















