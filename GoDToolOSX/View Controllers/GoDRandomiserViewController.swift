//
//  GoDRandomiserViewController.swift
//  GoD Tool
//
//  Created by The Steez on 15/09/2018.
//

import Cocoa

class GoDRandomiserViewController: GoDViewController {

	@IBOutlet var pspecies: NSButton!
	@IBOutlet var pmoves: NSButton!
	@IBOutlet var ptypes: NSButton!
	@IBOutlet var pabilities: NSButton!
	@IBOutlet var pstats: NSButton!
	@IBOutlet var pevolutions: NSButton!
	@IBOutlet var mtypes: NSButton!
	@IBOutlet var tmmoves: NSButton!
	@IBOutlet var bbingo: NSButton!
	@IBOutlet var removeTrades: NSButton!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		if game == .Colosseum {
			bbingo.isHidden = true
		}
    }
	
	@IBAction func randomise(_ sender: Any) {
		
		XGUtility.deleteSuperfluousFiles()
		increaseFileSizes = true
		
        XGRandomiser.clearLog()
        
		if pspecies.state == .on {
			XGRandomiser.randomisePokemon()
		}
		if pmoves.state == .on {
			XGRandomiser.randomiseMoves()
		}
		if ptypes.state == .on {
			XGRandomiser.randomiseTypes()
		}
		if pstats.state == .on {
			XGRandomiser.randomisePokemonStats()
		}
		if pevolutions.state == .on {
			XGRandomiser.randomiseEvolutions()
		}
        if pabilities.state == .on {
            XGRandomiser.randomiseAbilities()
        }
		if mtypes.state == .on {
			XGRandomiser.randomiseMoveTypes()
		}
		if tmmoves.state == .on {
			XGRandomiser.randomiseTMs()
		}
		if bbingo.state == .on {
			XGRandomiser.randomiseBattleBingo()
		}
		if removeTrades.state == .on {
			XGDolPatcher.removeTradeEvolutions()
		}
        
        let log = XGRandomiser.getLog()
        let logFile = XGFiles.randoLog(date)
        XGUtility.saveString(log, toFile: logFile)
        
		XGUtility.compileMainFiles()
        
        printg("Saved randomizer log to " + logFile.path)
        
	}
	
    
}








