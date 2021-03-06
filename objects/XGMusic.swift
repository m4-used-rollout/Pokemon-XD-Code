//
//  XGMusic.swift
//  GoD Tool
//
//  Created by The Steez on 25/03/2019.
//

import Foundation

let kSizeOfMusicData = 0xc

class XGMusic {
	
	var index = 0
	var fsysID = 0
	var ishID : UInt32 = 0
	var isdID : UInt32 = 0
	
	var fsys : XGFsys? {
		return ISO.getFSYSDataWithGroupID(fsysID)
	}
	
	var fsysName : String? {
		return ISO.getFSYSNameWithGroupID(fsysID)
	}
	
	var name : String {
		if fsysID == 0 {
			return "Null"
		}
		if ishID != 0 {
			if let fsysData = self.fsys {
				let ishIndex = fsysData.indexForIdentifier(identifier: ishID.int)
				return fsysData.fileName.removeFileExtensions() + "_\(ishIndex)"
			} else {
				return "Unknown_\(fsysID)"
			}
		}
		return fsysName?.removeFileExtensions() ?? "Unknown_\(fsysID)"
	}
	
	init(index: Int) {
		
		self.index = index
		let rel = XGFiles.common_rel.data!
		
		let start = CommonIndexes.BGM.startOffset + (index * kSizeOfMusicData)
		self.fsysID = rel.get2BytesAtOffset(start + 2)
		self.ishID = rel.getWordAtOffset(start + 4)
		self.isdID = rel.getWordAtOffset(start + 8)
		
	}
	
}

class XGMusicMetaData {
	
	var index = 0
	var musicIndex = 0
	var sfxID = 0
	
	var music : XGMusic {
		return XGMusic(index: musicIndex)
	}
	
	var name : String {
		if musicIndex == 2 {
			return "Sound_\(sfxID)"
		}
		return music.name
	}
	
	init(index: Int) {
		
		self.index = index
		let rel = XGFiles.common_rel.data!
		
		let start = CommonIndexes.SoundsMetaData.startOffset + (index * kSizeOfMusicData)
		self.sfxID = rel.get2BytesAtOffset(start + 4)
		self.musicIndex = rel.get2BytesAtOffset(start + 6)
		
	}
	
}






