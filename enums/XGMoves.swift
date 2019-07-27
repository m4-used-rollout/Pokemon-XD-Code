//
//  XGMoves.swift
//  XG Tool
//
//  Created by StarsMmd on 01/06/2015.
//  Copyright (c) 2015 StarsMmd. All rights reserved.
//

import Foundation

let kFirstShadowMoveIndex	= game == .XD ? 0x164 : 0x164
let kLastShadowMoveIndex	= game == .XD ? 0x176 : 0x164

let shadowMovesUseHMFlag	= XGMove(index: kFirstShadowMoveIndex).HMFlag

enum XGMoves : CustomStringConvertible, XGDictionaryRepresentable {
	
	case move(Int)
	
	var index : Int {
		get {
			switch self {
				case .move(let i):
					if i > CommonIndexes.NumberOfMoves.value || i < 0 {
						return 0
					}
					return i
			}
		}
	}
	
	var hex : String {
		get {
			return String(format: "0x%x",self.index)
		}
	}
	
	var startOffset : Int {
		get {
			return CommonIndexes.Moves.startOffset + (index * kSizeOfMoveData)
		}
	}
	
	var nameID : Int {
		get {
			return Int(XGFiles.common_rel.data!.getWordAtOffset(startOffset + kMoveNameIDOffset))
		}
	}
	
	var name : XGString {
		get {
			return XGFiles.common_rel.stringTable.stringSafelyWithID(nameID)
		}
	}
	
	var descriptionID : Int {
		get {
			return Int(XGFiles.common_rel.data!.getWordAtOffset(startOffset + kMoveDescriptionIDOffset))
		}
	}
	
	var description : String {
		get {
			return self.name.string
		}
	}
	
	var mdescription : XGString {
		get {
			return XGFiles.dol.stringTable.stringSafelyWithID(descriptionID)
		}
	}
	
	var type : XGMoveTypes {
		get {
			let index = XGFiles.common_rel.data!.getByteAtOffset(startOffset + kMoveTypeOffset)
			return XGMoveTypes(rawValue: index) ?? .normal
		}
	}
	
	var category : XGMoveCategories {
		get {
			let index = XGFiles.common_rel.data!.getByteAtOffset(startOffset + kMoveCategoryOffset)
			return XGMoveCategories(rawValue: index) ?? .none
		}
	}
	
	var isShadowMove : Bool {
		get {
			return shadowMovesUseHMFlag ? self.data.HMFlag : (self.index >= kFirstShadowMoveIndex) && (self.index <= kLastShadowMoveIndex)
		}
	}
    
    var isAttack : Bool {
        get {
            return self.data.basePower > 0
        }
    }
	
	var data : XGMove {
		get {
			return XGMove(index: self.index)
		}
	}
	
	var dictionaryRepresentation: [String : AnyObject] {
		get {
			return ["Value" : self.index as AnyObject]
		}
	}
	
	var readableDictionaryRepresentation: [String : AnyObject] {
		get {
			return ["Value" : self.name.string as AnyObject]
		}
	}
    
	
	static func allMoves() -> [XGMoves] {
		var moves = [XGMoves]()
		for i in 0 ..< kNumberOfMoves {
			moves.append(.move(i))
		}
		return moves
	}
	
    static func random(baseMove:XGMoves, stabType1: XGMoveTypes? = nil, stabType2: XGMoveTypes? = nil) -> XGMoves {
        var randMove:XGMoves
        var stabTries = (stabType1 != nil &&
            stabType2 != nil &&
            baseMove.isAttack &&
        arc4random_uniform(UInt32(100)) < 35) ? 1000 : 0
		repeat {
            stabTries -= 1
			randMove = XGMoves.move(Int(arc4random_uniform(UInt32(kNumberOfMoves - 1))) + 1)
		} while
            (stabTries > 0 && randMove.type != stabType1 && randMove.type != stabType2) || //35% chance to force STAB
            (randMove.isShadowMove != baseMove.isShadowMove) || //only replace shadow moves with other shadow moves
                (randMove.isAttack != baseMove.isAttack) || //only replace attacks with attacks, status with status
                (randMove.name.string == "-") || //don't use move 0 or 355
                (randMove.name.string == "????") || //don't use move 357 (Col)
                (randMove.descriptionID == 0)
		return randMove
	}
	
    static func randomMoveset(sourceMoves: [XGMoves], stabType1: XGMoveTypes? = nil, stabType2: XGMoveTypes? = nil) -> [XGMoves] {
		var newMoves = [XGMoves]()
        for move in sourceMoves {
            if move.index == 0 {
                continue
            }
            var newMove: XGMoves
            repeat {
                newMove = XGMoves.random(baseMove: move, stabType1: stabType1, stabType2: stabType2)
            } while newMoves.contains(newMove)
            newMoves.append(newMove)
        }
		while newMoves.count < 4 {
			newMoves.append(XGMoves.move(0))
		}
        return newMoves
	}
}

enum XGOriginalMoves {
	
	case move(Int)
	
	var index : Int {
		get {
			switch self {
			case .move(let i): return i
			}
		}
	}
	
	var startOffset : Int {
		get {
			return XGMoves.move(index).startOffset
		}
	}
	
	var nameID : Int {
		get {
			return XGFiles.original(.common_rel).data!.get2BytesAtOffset(startOffset + kMoveNameIDOffset)
		}
	}
	
	var descriptionID : Int {
		get {
			return XGFiles.original(.common_rel).data!.get2BytesAtOffset(startOffset + kMoveDescriptionIDOffset)
		}
	}
	
	var name : XGString {
		get {
			let table = XGFiles.original(.common_rel).stringTable
			return table.stringSafelyWithID(nameID)
		}
	}
	
	var type : XGMoveTypes {
		get {
			let index = XGFiles.original(.common_rel).data!.getByteAtOffset(startOffset + kMoveTypeOffset)
			return XGMoveTypes(rawValue: index) ?? .normal
		}
	}
	
	var animation : Int {
		get {
			return XGFiles.original(.common_rel).data!.get2BytesAtOffset(startOffset + kAnimationIndexOffset)
		}
	}
	
	var isShadowMove : Bool {
		get {
			return (self.index >= kFirstShadowMoveIndex) && (self.index <= kLastShadowMoveIndex)
		}
	}
	
	static func allMoves() -> [XGOriginalMoves] {
		var moves = [XGOriginalMoves]()
		for i in 0 ..< kNumberOfMoves {
			moves.append(.move(i))
		}
		return moves
	}
	
}

func allMoves() -> [String : XGMoves] {
	
	var dic = [String : XGMoves]()
	
	for i in 0 ..< kNumberOfMoves {
		
		let a = XGMoves.move(i)
		
		dic[a.name.string.simplified] = a
		
	}
	
	return dic
}

let moves = allMoves()

func move(_ name: String) -> XGMoves {
	if moves[name.simplified] == nil { printg("couldn't find: " + name) }
	return moves[name.simplified] ?? .move(0)
}


func allMovesArray() -> [XGMoves] {
	var moves: [XGMoves] = []
	for i in 0 ..< kNumberOfMoves {
		moves.append(XGMoves.move(i))
	}
	return moves
}

func allOriginalMovesArray() -> [XGOriginalMoves] {
	
	var moves: [XGOriginalMoves] = []
	for i in 0 ..< kNumberOfMoves {
		moves.append(XGOriginalMoves.move(i))
	}
	return moves
	
}

extension XGMoves: Equatable {
    static func == (a: XGMoves, b: XGMoves) -> Bool {
        return a.index == b.index
    }
}






























