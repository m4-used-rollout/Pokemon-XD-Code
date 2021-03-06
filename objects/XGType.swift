//
//  XGTypeData.swift
//  XG Tool
//
//  Created by StarsMmd on 19/05/2015.
//  Copyright (c) 2015 StarsMmd. All rights reserved.
//

import Foundation

//let kFirstTypeOffset = 0xA7C30
let kCategoryOffset = 0x0
let kTypeIconBigIDOffset = 0x02
let kTypeIconSmallIDOffset = 0x04
let kTypeNameIDOffset = 0x8
let kFirstEffectivenessOffset = 0xD
let kSizeOfTypeData = 0x30

let kNumberOfTypes = CommonIndexes.NumberOfTypes.value


class XGType: NSObject {
	
	@objc var index			 = 0
	@objc var nameID		 = 0
	var category			 = XGMoveCategories.none
	var effectivenessTable	 = [XGEffectivenessValues]()
	
	var iconBigID   = 0
	var iconSmallID = 0
	
	@objc var name : XGString {
		get {
			return XGFiles.common_rel.stringTable.stringSafelyWithID(self.nameID)
		}
	}
	
	@objc var startOffset = 0
	
	@objc var dictionaryRepresentation : [String : AnyObject] {
		get {
			var dictRep = [String : AnyObject]()
			dictRep["name"] = self.name
			
			dictRep["category"] = self.category.dictionaryRepresentation as AnyObject?
			
			var effectivenessTableArray = [ [String : AnyObject] ]()
			for a in effectivenessTable {
				effectivenessTableArray.append(a.dictionaryRepresentation)
			}
			dictRep["effectivenessTable"] = effectivenessTableArray as AnyObject?
			
			return dictRep
		}
	}
	
	@objc var readableDictionaryRepresentation : [String : AnyObject] {
		get {
			var dictRep = [String : AnyObject]()
			
			dictRep["category"] = self.category.string as AnyObject?
			
			var effectivenessTableArray = [AnyObject]()
			for a in effectivenessTable {
				effectivenessTableArray.append(a.string as AnyObject)
			}
			dictRep["effectivenessTable"] = effectivenessTableArray as AnyObject?
			
			return ["\(self.index) " + self.name.string : dictRep as AnyObject]
		}
	}
	
	@objc init(index: Int) {
		super.init()
		
		let rel			= XGFiles.common_rel.data!
		self.index		= index
		startOffset		= CommonIndexes.Types.startOffset + (index * kSizeOfTypeData)
		
		self.nameID		= rel.getWordAtOffset(startOffset + kTypeNameIDOffset).int
		self.category	= XGMoveCategories(rawValue: rel.getByteAtOffset(startOffset + kCategoryOffset))!
		
		self.iconBigID   = rel.get2BytesAtOffset(startOffset + kTypeIconBigIDOffset)
		self.iconSmallID = rel.get2BytesAtOffset(startOffset + kTypeIconSmallIDOffset)
		
		var offset = startOffset + kFirstEffectivenessOffset
		
		for _ in 0 ..< kNumberOfTypes {
			
			let value = rel.getByteAtOffset(offset)
			let effectiveness = XGEffectivenessValues(rawValue: value)!
			effectivenessTable.append(effectiveness)
			
			offset += 2
			
		}
		
	}
	
	@objc func save() {
		
		let rel = XGFiles.common_rel.data!
		
		rel.replaceByteAtOffset(startOffset + kCategoryOffset, withByte: self.category.rawValue)
		rel.replaceWordAtOffset(startOffset + kTypeNameIDOffset, withBytes: UInt32(self.nameID))
		rel.replace2BytesAtOffset(startOffset + kTypeIconBigIDOffset, withBytes: self.iconBigID)
		rel.replace2BytesAtOffset(startOffset + kTypeIconSmallIDOffset, withBytes: self.iconSmallID)
		
		for i in 0 ..< self.effectivenessTable.count {
			
			let value = effectivenessTable[i].rawValue
			rel.replaceByteAtOffset(startOffset + kFirstEffectivenessOffset + (i * 2), withByte: value)
			// i*2 because each value is 2 bytes apart
			
		}
		
		rel.save()
	}
	
	
}











