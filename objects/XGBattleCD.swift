//
//  XGBattleCD.swift
//  GoDToolCL
//
//  Created by The Steez on 26/05/2018.
//

import Foundation

let kSizeOfBattleCDData = 0x3c

let kBattleCDTurnLimitOffset = 0x00
let kBattleCDStyleOffset = 0x02
let kBattleCDFieldOffset = 0x04
let kBattleCDPlayer1DeckIDOffset = 0x08
let kBattleCDPlayer1TrainerIDOffset = 0x0a
let kBattleCDDeckIDOffset = 0x0c
let kBattleCDTrainerIDOffset = 0x0e
let kBattleCDDescriptionIDOffset = 0x10
let kBattleCDBoldConditionDescriptionIDOffset = 0x14
let kBattleCDConditionDescriptionIDOffset = 0x18


class XGBattleCD: NSObject {
	
	var battleStyle : XGBattleStyles!
	@objc var battleField : XGBattleField!
	
	var deck : XGDecks!
	@objc var trainerID = 0
	var p1Deck : XGDecks!
	@objc var p1TID = 0
	
	@objc var turnLimit = 0
	
	@objc var index = 0
	@objc var startOffset = 0
	
	@objc var descriptionID = 0
	@objc var cdDescription : XGString {
		return getStringSafelyWithID(id: descriptionID)
	}
	
	@objc var conditionsID = 0
	@objc var conditions : XGString {
		return getStringSafelyWithID(id: conditionsID)
	}
	
	@objc var conditionsBoldID = 0
	@objc var conditionsBold : XGString {
		return getStringSafelyWithID(id: conditionsBoldID)
	}
	
	@objc var trainer : XGTrainer? {
		if deck == nil {
			return nil
		}
		return XGTrainer(index: trainerID, deck: deck)
	}
	
	@objc var p1Trainer : XGTrainer? {
		if p1Deck == nil {
			return nil
		}
		return XGTrainer(index: p1TID, deck: p1Deck)
	}
	
	@objc var rawData : [Int] {
		return XGFiles.common_rel.data!.getByteStreamFromOffset(self.startOffset, length: kSizeOfBattleCDData)
	}
	
	@objc var title : String {
		let p1t = p1Trainer
		let p1 = p1t == nil ? (p1TID == 0x1388 ? "Player" : "Invalid") : p1t!.name.string
		
		let p2t = trainer
		let p2 = p2t == nil ? (trainerID == 0x1388 ? "Player" : "Invalid") : p2t!.name.string
		
		return p1 + " vs. " + p2
	}
	
	func getItem() -> XGItems {
		
		if index < 1 || index > 50 {
			printg("Battle CD \(index) has no item.")
			return .item(0)
		}
		
		return XGItems.item(index + 383)
	}
	
	override var description: String {
		
		let p1t = p1Trainer
		let p2t = trainer
		
		
		var desc = title + "\n"
		desc += "Location: \(p2t == nil ? "-" : p2t!.locationString)\n"
		if battleField.roomID > 0 {
			desc += "Battle Field: \(battleField.room!.name)\n"
		}
		var turns = turnLimit == 1 ? "1 turn." : "unlimited turns."
		if turnLimit > 1 {
			turns = "\(turnLimit) turns."
		}
		desc += "\(battleStyle.name) battle, \(turns)\n\n"
		
		if p1t != nil {
			desc += p1t!.fullDescription + "\n"
		}
		
		if p2t != nil {
			desc += p2t!.fullDescription + "\n"
		}
		
		return desc
	}
	
	@objc init(index: Int) {
		super.init()
		
		self.index = index
		self.startOffset = CommonIndexes.BattleCDs.startOffset + (index * kSizeOfBattleCDData)
		
		let data = XGFiles.common_rel.data!
		
		self.turnLimit = data.getByteAtOffset(startOffset + kBattleCDTurnLimitOffset)
		
		let style = data.getByteAtOffset(startOffset + kBattleCDStyleOffset)
		self.battleStyle = XGBattleStyles(rawValue: style) ?? .other
		
		let d = data.get2BytesAtOffset(startOffset + kBattleCDDeckIDOffset)
		self.deck = XGDecks.deckWithID(d)
		
		let b = data.get2BytesAtOffset(startOffset + kBattleCDFieldOffset)
		self.battleField = XGBattleField(index: b)
		
		self.trainerID = data.get2BytesAtOffset(startOffset + kBattleCDTrainerIDOffset)
		
		let p1d = data.get2BytesAtOffset(startOffset + kBattleCDPlayer1DeckIDOffset)
		self.p1Deck = XGDecks.deckWithID(p1d)
		
		self.p1TID = data.get2BytesAtOffset(startOffset + kBattleCDPlayer1TrainerIDOffset)
		
		self.descriptionID = data.getWordAtOffset(startOffset + kBattleCDDescriptionIDOffset).int
		self.conditionsID = data.getWordAtOffset(startOffset + kBattleCDConditionDescriptionIDOffset).int
		self.conditionsBoldID = data.getWordAtOffset(startOffset + kBattleCDBoldConditionDescriptionIDOffset).int
		
		
	}
	
	@objc func save() {
		
		let data = XGFiles.common_rel.data!
		
		data.replaceByteAtOffset(startOffset + kBattleCDTurnLimitOffset, withByte: self.turnLimit)
		data.replaceByteAtOffset(startOffset + kBattleStyleOffset, withByte: self.battleStyle.rawValue)
		data.replace2BytesAtOffset(startOffset + kBattleFieldOffset, withBytes: self.battleField.index)
		data.replace2BytesAtOffset(startOffset + kBattlePlayer2DeckIDOffset, withBytes: self.deck.id)
		data.replace2BytesAtOffset(startOffset + kBattlePlayer2TrainerIDOffset, withBytes: self.trainerID)
		data.replace2BytesAtOffset(startOffset + kBattlePlayer1DeckIDOffset, withBytes: (self.p1Deck ?? .DeckDarkPokemon).id)
		data.replace2BytesAtOffset(startOffset + kBattlePlayer1TrainerIDOffset, withBytes: self.p1TID)
		data.replaceWordAtOffset(startOffset + kBattleCDDescriptionIDOffset, withBytes: UInt32(self.descriptionID))
		data.replaceWordAtOffset(startOffset + kBattleCDConditionDescriptionIDOffset, withBytes: UInt32(self.conditionsID))
		data.replaceWordAtOffset(startOffset + kBattleCDBoldConditionDescriptionIDOffset, withBytes: UInt32(self.conditionsBoldID))
		
		data.save()
	}
	
	
	
}
