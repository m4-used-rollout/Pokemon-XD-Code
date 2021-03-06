//
//  CMTrainer.swift
//  Colosseum Tool
//
//  Created by The Steez on 04/06/2018.
//

import Foundation

//let kFirstTrainerOffset				= 0x92ED0
let kFirstTrainerOffset				= 0x15bac // japanese
let kSizeOfTrainerData				= 0x34
let kNumberOfTrainerPokemon			= 0x06
let kNumberOfTrainerEntries			= CommonIndexes.NumberOfTrainers.value // 820

let kTrainerGenderOffset			= 0x00
let kTrainerClassOffset				= 0x03
let kTrainerFirstPokemonOffset		= 0x04
let kTrainerAIOffset				= 0x06
let kTrainerNameIDOffset			= 0x08
let kTrainerBattleTransitionOffset	= 0x0C
let kTrainerClassModelOffset		= 0x13
let kTrainerPreBattleTextIDOffset	= 0x24
let kTrainerVictoryTextIDOffset		= 0x28
let kTrainerDefeatTextIDOffset		= 0x2C
let kFirstTrainerLoseText2Offset	= 0x32
let kTrainerFirstItemOffset			= 0x14

class XGTrainer: NSObject {
	
	var index				= 0x0
	
	@objc var AI				= 0
	@objc var cameraEffects		= 0 // xd only
	
	var nameID				= 0x0
	var preBattleTextID		= 0x0
	var victoryTextID		= 0x0
	var defeatTextID		= 0x0
	var shadowMask			= 0x0
	var pokemon				= [XGTrainerPokemon]()
	var trainerClass		= XGTrainerClasses.none
	var trainerModel		= XGTrainerModels.wes
	
	@objc var battleData : XGBattle? {
		return nil
	}
	
	var startOffset : Int {
		get {
			return CommonIndexes.Trainers.startOffset + (index * kSizeOfTrainerData)
		}
	}
	
	var name : XGString {
		get {
			return XGFiles.common_rel.stringTable.stringSafelyWithID(self.nameID)
		}
	}
	
	var isPlayer : Bool {
		return self.index == 1
	}
	
	var prizeMoney : Int {
		get {
			var maxLevel = 0
			
			for poke in self.pokemon {
				maxLevel = poke.level > maxLevel ? poke.level : maxLevel
			}
			
			return self.trainerClass.payout * 2 * maxLevel
		}
	}
	
	var hasShadow : Bool {
		get {
			for poke in self.pokemon {
				if poke.isShadow {
					return true
				}
			}
			return false
		}
	}
	
	init(index: Int) {
		super.init()
		
		self.index = index
		let start = startOffset
		
		let deck = XGFiles.common_rel.data!
		
		self.nameID =  deck.getWordAtOffset(start + kTrainerNameIDOffset).int
		self.preBattleTextID = deck.getWordAtOffset(start + kTrainerPreBattleTextIDOffset).int
		self.victoryTextID = deck.getWordAtOffset(start + kTrainerVictoryTextIDOffset).int
		self.defeatTextID = deck.getWordAtOffset(start + kTrainerDefeatTextIDOffset).int
		self.AI = deck.get2BytesAtOffset(start + kTrainerAIOffset)
		
		let tClass = deck.getByteAtOffset(start + kTrainerClassOffset)
		let tModel = deck.getByteAtOffset(start + kTrainerClassModelOffset)
		
		self.trainerClass = XGTrainerClasses(rawValue: tClass) ?? .none
		self.trainerModel = XGTrainerModels(rawValue: tModel)  ?? .wes
		
		let first = deck.get2BytesAtOffset(start + kTrainerFirstPokemonOffset)
		if first < CommonIndexes.NumberOfTrainerPokemonData.value {
			for i in 0 ..< kNumberOfTrainerPokemon {
				self.pokemon.append(XGTrainerPokemon(index: (first + i)))
			}
		}
		
	}
	
	func save() {
		
		let start = startOffset
		let deck = XGFiles.common_rel.data!
		
		deck.replaceWordAtOffset(start + kTrainerNameIDOffset, withBytes: UInt32(self.nameID))
		deck.replaceWordAtOffset(start + kTrainerPreBattleTextIDOffset, withBytes: UInt32(self.preBattleTextID))
		deck.replaceWordAtOffset(start + kTrainerVictoryTextIDOffset, withBytes: UInt32(self.victoryTextID))
		deck.replaceWordAtOffset(start + kTrainerDefeatTextIDOffset, withBytes: UInt32(self.defeatTextID))
		
		deck.replace2BytesAtOffset(start + kTrainerAIOffset, withBytes: self.AI)
		deck.replaceByteAtOffset(start + kTrainerClassOffset , withByte: self.trainerClass.rawValue)
		deck.replaceByteAtOffset(start + kTrainerClassModelOffset, withByte: self.trainerModel.rawValue)
		
		deck.save()
	}
	
	func purge(autoSave: Bool) {
		
		for poke in self.pokemon {
			poke.purge()
			if autoSave {
				poke.save()
			}
		}
		
	}
	
	var dictionaryRepresentation : [String : AnyObject] {
		get {
			var dictRep = [String : AnyObject]()
			dictRep["index"] = self.index as AnyObject?
			dictRep["nameID"] = self.nameID as AnyObject?
			dictRep["preBattleTextID"] = self.preBattleTextID as AnyObject?
			dictRep["victoryTextID"] = self.victoryTextID as AnyObject?
			dictRep["defeatTextID"] = self.defeatTextID as AnyObject?
			dictRep["shadowMask"] = self.shadowMask as AnyObject?
			dictRep["AI"] = self.AI as AnyObject?
			
			dictRep["trainerClass"] = self.trainerClass.dictionaryRepresentation as AnyObject?
			dictRep["trainerModel"] = self.trainerModel.dictionaryRepresentation as AnyObject?
			
			var pokemonArray = [ [String : AnyObject] ]()
			for a in pokemon {
				pokemonArray.append(a.dictionaryRepresentation)
			}
			dictRep["pokemon"] = pokemonArray as AnyObject?
			
			return dictRep
		}
	}
	
	var readableDictionaryRepresentation : [String : AnyObject] {
		get {
			
			var dictRep = [String : AnyObject]()
			dictRep["index"] = self.index as AnyObject?
			dictRep["preBattleText"] = getStringSafelyWithID(id: self.preBattleTextID).string as AnyObject
			dictRep["victoryText"] = getStringSafelyWithID(id: self.victoryTextID).string as AnyObject
			dictRep["defeatText"] = getStringSafelyWithID(id: self.defeatTextID).string as AnyObject
			dictRep["hasShadowPokemon"] = (self.shadowMask > 0) as AnyObject?
			dictRep["AI"] = self.AI as AnyObject?
			
			dictRep["trainerClass"] = self.trainerClass.name.string as AnyObject?
			dictRep["trainerModel"] = self.trainerModel.name as AnyObject?
			
			var pokemonArray = [AnyObject]()
			for a in pokemon {
				if a.isSet {
					pokemonArray.append(a.readableDictionaryRepresentation as AnyObject)
				}
			}
			dictRep["pokemon"] = pokemonArray as AnyObject?
			
			return [self.name.string : dictRep as AnyObject]
		}
	}
	
}

func allTrainers() -> [XGTrainer] {
	var trainers = [XGTrainer]()
	
	for i in 0 ..< kNumberOfTrainerEntries {
		trainers.append(XGTrainer(index: i))
	}
	
	return trainers
}
