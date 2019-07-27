//
//  CMRandomiser.swift
//  GoDToolCL
//
//  Created by The Steez on 16/09/2018.
//

import Foundation
import Darwin

class XGRandomiser : NSObject {
    
    private static var randoLog:[String] = []
    
    class func clearLog() {
        self.randoLog = []
    }
    
    class func getLog() -> String {
        return self.randoLog.reduce("", { (log, line) -> String in
            return log + "\n" + line
        })
    }
    
    private class func log(_ text: String, level: Int = 0, startBlock: Bool = false) {
        var line = startBlock ? "\n" : ""
        for _ in 0 ..< level {
            line += "\t"
        }
        line += text
        self.randoLog.append(line)
    }
    private class func logEndBlock(){
        self.randoLog.append("\n\n")
    }
    
    private class func fTrainer(_ trainer:XGTrainer) -> String {
        let classStr = trainer.trainerClass.name.string
        let trainerStr = trainer.name.string
        let trainerId = trainer.index.string
        return classStr + " " + trainerStr + " (" + trainerId + ")"
    }
    
    private class func fPokemon(_ mon:XGPokemon, level:Int? = nil) -> String {
        let levelStr = level != nil ? "Lv. " + (level?.string ?? "") + " " : ""
        return levelStr + mon.name.string + " (" + mon.index.string + ")"
    }
    
    private class func fMove(_ move:XGMoves) -> String {
        return move.name.string + " (" + move.index.string + ")"
    }
    
    private class func fAbility(_ ability:XGAbilities) -> String {
        return ability.name.string + " (" + ability.index.string + ")"
    }
	
	class func randomiseBattleBingo() {}
	
	class func randomisePokemon() {
		printg("randomising pokemon species...")
        log("Randomizing Pokemon Species")
        log("-Replacing each species with a completely random species")
        log("-Shadow Pokemon species are not duplicated")
        log("-Boosting Enemy Trainer Pokemon levels by 20% (Capped at Lv. 100)")
		var shadows = [Int : XGPokemon]()
        log("Trainer Pokemon Species", level: 1)
		for deck in TrainerDecksArray {
            for trainer in deck.allTrainers {
                log("Trainer " + fTrainer(trainer), level: 2, startBlock: true)
                for pokemon in trainer.pokemon {
                    
                    if pokemon.species.index == 0 {
                        continue
                    }
                    let originalSpecies = pokemon.species
                    let originalLevel = pokemon.level
                    
                    pokemon.level = min(100,Int(floor(Double(pokemon.level) * 1.2)))
                    
                    if pokemon.isShadow {
                        if let species = shadows[pokemon.shadowID] {
                            pokemon.species = species
                        } else {
                            var species = XGPokemon.random()
                            var dupe = true
                            
                            while dupe {
                                dupe = false
                                for (id, spec) in shadows {
                                    if id == pokemon.shadowID {
                                        continue
                                    }
                                    if species.index == spec.index {
                                        species = XGPokemon.random()
                                        dupe = true
                                    }
                                }
                            }
                            
                            pokemon.species = species
                            shadows[pokemon.shadowID] = species
                        }
                    } else {
                        pokemon.species = XGPokemon.random()
                    }
                    pokemon.shadowCatchRate = pokemon.species.catchRate
                    pokemon.moves = pokemon.species.movesForLevel(pokemon.level)
                    pokemon.happiness = 128
                    pokemon.save()
                    
                    log((pokemon.isShadow ? "Shadow " : "") + fPokemon(originalSpecies, level: originalLevel) + " -> " + (pokemon.isShadow ? "Shadow " : "") + fPokemon(pokemon.species, level: pokemon.level), level: 3)
                }
            }
		}
		
        log("Gift Pokemon Species", level: 1, startBlock: true)
        
		for gift in XGGiftPokemonManager.allGiftPokemon() {
			
			var pokemon = gift
            let originalSpecies = pokemon.species
			pokemon.species = XGPokemon.random()
			let moves = pokemon.species.movesForLevel(pokemon.level)
			pokemon.move1 = moves[0]
			pokemon.move2 = moves[1]
			pokemon.move3 = moves[2]
			pokemon.move4 = moves[3]
			
			pokemon.save()
            log(fPokemon(originalSpecies, level: pokemon.level) + " -> " + fPokemon(pokemon.species, level: pokemon.level), level: 2)
			
		}
        
        logEndBlock()
		printg("done!")
	}
	
	class func randomiseMoves() {
		printg("randomising pokemon moves...")
		log("Randomizing Pokemon Moves")
        log("-Damage moves will be replaced with damage moves, non-damage moves with non-damage moves")
        log("-Damage moves will have a 35% chance to be STAB")
        log("-Shadow moves will only be replaced with shadow moves and non-shadow moves with non-shadow moves")
        
		var shadows = [Int : [XGMoves]]()
        log("Trainer Pokemon Moves", level: 1)
		for deck in TrainerDecksArray {
            for trainer in deck.allTrainers {
                log("Trainer " + fTrainer(trainer), level: 2, startBlock: true)
                for pokemon in trainer.pokemon {
                    
                    if pokemon.species.index == 0 {
                        continue
                    }
                    
                    let originalMoves = [pokemon.moves[0], pokemon.moves[1], pokemon.moves[2], pokemon.moves[3]]
                    
                    if pokemon.isShadow {
                        if let moves = shadows[pokemon.shadowID] {
                            pokemon.moves = moves
                        } else {
                            let moves = XGMoves.randomMoveset(sourceMoves: originalMoves, stabType1: pokemon.species.type1, stabType2: pokemon.species.type2)
                            shadows[pokemon.shadowID] = moves
                            pokemon.moves = moves
                        }
                    } else {
                        pokemon.moves = XGMoves.randomMoveset(sourceMoves: originalMoves, stabType1: pokemon.species.type1, stabType2: pokemon.species.type2)
                    }
                    
                    pokemon.save()
                    
                    log(fPokemon(pokemon.species), level: 3)
                    for i in 0 ..< pokemon.moves.count {
                        log(fMove(originalMoves[i]) + " -> " + fMove(pokemon.moves[i]), level: 4)
                    }
                }
            }
		}
		
        log("Gift Pokemon Moves", level: 1, startBlock: true)
		for gift in XGGiftPokemonManager.allGiftPokemon() {
			
            let originalMoves = [gift.move1, gift.move2, gift.move3, gift.move4]
			var pokemon = gift
            let moves = XGMoves.randomMoveset(sourceMoves: originalMoves, stabType1: pokemon.species.type1, stabType2: pokemon.species.type2)
			pokemon.move1 = moves[0]
			pokemon.move2 = moves[1]
			pokemon.move3 = moves[2]
			pokemon.move4 = moves[3]
			
			pokemon.save()
            
            log(fPokemon(pokemon.species), level: 2, startBlock: true)
            for i in 0 ..< moves.count {
                log(fMove(originalMoves[i]) + " -> " + fMove(moves[i]), level: 3)
            }
			
		}
		
        log("Pokemon Movelearns (Does not apply to the movesets of Trainer and Gift Pokemon listed above)", level: 1, startBlock: true)
		for i in 1 ..< kNumberOfPokemon {
			
			if XGPokemon.pokemon(i).nameID == 0 {
				continue
			}
			
			let pokemon = XGPokemon.pokemon(i)
            
            log(fPokemon(pokemon), level: 2, startBlock: true)
            
			if pokemon.nameID > 0 {
				let p = XGPokemonStats(index: pokemon.index)
				
				for j in 0 ..< p.levelUpMoves.count {
					if p.levelUpMoves[j].level > 0 {
                        let originalMove = p.levelUpMoves[j].move
						p.levelUpMoves[j].move = XGMoves.random(baseMove: p.levelUpMoves[j].move)
						var dupe = true
						while dupe {
							dupe = false
							for k in 0 ..< j {
								if p.levelUpMoves[k].move.index == p.levelUpMoves[j].move.index {
                                    p.levelUpMoves[j].move = XGMoves.random(baseMove: p.levelUpMoves[j].move,  stabType1: pokemon.type1, stabType2: pokemon.type2)
									dupe = true
								}
							}
						}
                        log("Level " + p.levelUpMoves[j].level.string + ": " + fMove(originalMove) + " -> " + fMove(p.levelUpMoves[j].move), level: 3)
					}
				}
				
				p.save()
			}
		}
		printg("done!")
        logEndBlock()
	}
	
	
	class func randomiseAbilities() {
		printg("randomising pokemon abilities...")
        log("Randomizing Pokemon Abilities")
        log("-Replacing each species' abilities with completely random abilities")
        log("-Will not choose or replace Wonder Guard")
		for i in 1 ..< kNumberOfPokemon {
			
			if XGPokemon.pokemon(i).nameID == 0 {
				continue
			}
			
			let pokemon = XGPokemon.pokemon(i)
            
            log(fPokemon(pokemon), level: 1, startBlock: true)
            
			if pokemon.nameID > 0 {
				let p = XGPokemonStats(index: pokemon.index)
                if p.ability1.index != 25 { // Wonder Guard
                    let oldAbility = p.ability1
                    repeat {
                        p.ability1 = XGAbilities.random()
                    } while (p.ability1.index == 25) // Wonder Guard
                    log(fAbility(oldAbility) + " -> " + fAbility(p.ability1), level: 2)
                }
				if p.ability2.index > 0 && p.ability2.index != 25  { // Wonder Guard
                    let oldAbility = p.ability2
                    repeat {
                        p.ability2 = XGAbilities.random()
                    } while (p.ability2.index == 25) // Wonder Guard
                    log(fAbility(oldAbility) + " -> " + fAbility(p.ability2), level: 2)
				}
				
				p.save()
			}
		}
		printg("done!")
        logEndBlock()
	}
	
	class func randomiseTypes() {
		printg("randomising pokemon types...")
        log("Randomizing Pokemon Types")
        log("-Replacing each species' types with completely random types (including ???)")
		for i in 1 ..< kNumberOfPokemon {
			
			if XGPokemon.pokemon(i).nameID == 0 {
				continue
			}
			
			let pokemon = XGPokemon.pokemon(i)
            log(fPokemon(pokemon), level: 1, startBlock: true)
			if pokemon.nameID > 0 {
				let p = XGPokemonStats(index: pokemon.index)
				
                let oldType1 = p.type1
                let oldType2 = p.type2
                
				p.type1 = XGMoveTypes.random()
				p.type2 = XGMoveTypes.random()
				
				p.save()
                
                log(oldType1.name + " -> " + p.type1.name, level: 2)
                log(oldType2.name + " -> " + p.type2.name, level: 2)
			}
		}
		printg("done!")
        logEndBlock()
	}
	
	class func randomiseEvolutions() {
		printg("randomising pokemon evolutions...")
        log("Randomizing Pokemon Evolutions")
        log("-Pokemon must not already evolve into New target")
        log("-New target must share at least one of the types the source and original target have in common")
        log("-If source and original target don't share types, the new target must share at least one type with the original target")
        log("-New target must be the same distance from final evolution as original target")
        log("-New target must have a higher BST than source Pokemon")
        log("-New target must not have already been picked as an evolution target")
        
        var used:Set<Int> = Set([])
        
		for i in 1 ..< kNumberOfPokemon {
			
			let pokemon = XGPokemon.pokemon(i)
			if pokemon.nameID > 0 {
                log(fPokemon(pokemon), level: 1, startBlock: true)
				let p = XGPokemonStats(index: pokemon.index)
				let m = p.evolutions
                let originalEvos = Set<Int>(p.evolutions.map { (e) -> Int in
                    return e.evolvesInto
                })
				for n in m {
					if n.evolvesInto > 0 {
                        let oldEvo = XGPokemon.pokemon(n.evolvesInto)
                        var sharedTypes = pokemon.typeSet.intersection(oldEvo.typeSet)
                        if sharedTypes.count < 1 {
                            sharedTypes = oldEvo.typeSet
                        }
                        let evoDistance = oldEvo.evosFromFinal()
                        let bst = pokemon.bst()
                        var newEvo:XGPokemon
                        repeat {
                            newEvo = XGPokemon.random()
                        } while (
                            originalEvos.contains(newEvo.index) ||
                            !newEvo.sharesType(sharedTypes) ||
                            newEvo.evosFromFinal() != evoDistance ||
                            newEvo.bst() <= bst ||
                            used.contains(newEvo.index)
                        )
                        n.evolvesInto = newEvo.index
                        used.insert(newEvo.index)
                        log(fPokemon(oldEvo) + " -> " + fPokemon(newEvo), level: 2)
					}
				}
				p.evolutions = m
				
				p.save()
			}
		}
		printg("done!")
        logEndBlock()
	}
	
	class func randomiseTMs() {
		printg("randomising TMs...")
        log("Randomizing TM Moves")
        log("-Replacing damage moves with random damage moves and non-damage moves with random non-damage moves")
        let TMs = allTMsArray()
        for i in 0 ..< TMs.count {
            let tm = TMs[i]
            let oldMove = tm.move
            var newMove = XGMoves.random(baseMove: tm.move)
            var dupe = true
            while dupe {
                dupe = false
                for j in 0 ..< i {
                    if TMs[j].move.index == newMove.index {
                        newMove = XGMoves.random(baseMove: tm.move)
                        dupe = true
                    }
                }
            }
            tm.replaceWithMove(newMove)
            log(tm.item.name.string + " " + fMove(oldMove) + " -> " + fMove(newMove), level: 1)
            
        }
		printg("done!")
        logEndBlock()
	}
	
	
	class func randomiseMoveTypes() {
		printg("randomising move types...")
        log("Randomizing Move Types")
        log("-Replacing each move's type with a completely random type (including ???)")
		for move in allMovesArray() {
			let m = move.data
            let oldType = m.type
			m.type = XGMoveTypes.random()
			m.save()
            log(fMove(move) + " " + oldType.name + " -> " + m.type.name, level: 1)
		}
		printg("done!")
        logEndBlock()
	}
	
	class func randomisePokemonStats() {
		printg("randomising pokemon stats...")
        log("Randomizing Pokemon Base Stats")
        log("-Rebalancing each species' base stats, keeping the same stat total")
		for mon in allPokemonArray() {
			log(fPokemon(mon), level: 1, startBlock: true)
            
			let pokemon = mon.stats
            
            let oAtk = pokemon.attack, oDef = pokemon.defense, oSpd = pokemon.speed, oHp = pokemon.hp, oSpAtk = pokemon.specialAttack, oSpDef = pokemon.specialDefense
			
			// stat total will remain unchanges
			var statsTotal = pokemon.bst
            
            let oBst = statsTotal
			
			// no individual stat will be over this value
			let maxStat = min(statsTotal / 4, 255)
			
			// each stat should be at least 20
			pokemon.attack = 40
			pokemon.defense = 40
			pokemon.speed = 40
			pokemon.hp = 40
			pokemon.specialAttack = 40
			pokemon.specialDefense = 40
			statsTotal -= 240
			
			func randomStat() -> Int {
				return Int(arc4random_uniform(6))
			}
			
			func addToRandomStat(_ v: Int) {
				let stats = [pokemon.attack, pokemon.defense, pokemon.specialAttack, pokemon.specialDefense, pokemon.speed, pokemon.hp]
				if stats.filter({ (i) -> Bool in
					return i < 255
				}).isEmpty {
					statsTotal = 0
					return
				}
				
				if stats.filter({ (i) -> Bool in
					return i + v < 255
				}).isEmpty {
					statsTotal -= v
					return
				}
				var index = randomStat()
				while (stats[index] + v) > maxStat {
					index = randomStat()
				}
				switch index {
				case 0: pokemon.attack += v
				case 1: pokemon.defense += v
				case 2: pokemon.specialAttack += v
				case 3: pokemon.specialDefense += v
				case 4: pokemon.speed += v
				case 5: pokemon.hp += v
				default: break
				}
				statsTotal -= v
			}
			
			while statsTotal > 150 {
				addToRandomStat(statsTotal / 6)
			}
			
			while statsTotal > 25 {
				addToRandomStat(10)
			}
			
			while statsTotal > 0 {
				addToRandomStat(1)
			}
			pokemon.save()
            
            //double check
            statsTotal = pokemon.bst
            
            log("HP   : " + oHp.string    + " -> " + pokemon.hp.string, level: 2)
            log("Atk  : " + oAtk.string   + " -> " + pokemon.attack.string, level: 2)
            log("Def  : " + oDef.string   + " -> " + pokemon.defense.string, level: 2)
            log("Spd  : " + oSpd.string   + " -> " + pokemon.speed.string, level: 2)
            log("SpAtk: " + oSpAtk.string + " -> " + pokemon.specialAttack.string, level: 2)
            log("SpDef: " + oSpDef.string + " -> " + pokemon.specialDefense.string, level: 2)
            log("BST  : " + oBst.string   + " -> " + statsTotal.string, level: 2)
			
		}
		printg("done!")
        logEndBlock()
	}
	
	
}
