//
//  GoDPokemonView.swift
//  GoD Tool
//
//  Created by The Steez on 18/09/2017.
//
//

import Cocoa


class GoDPokemonView: NSImageView {
	
	var index = 0

	var dpkm = GoDDPKMPopUpButton()
	var ddpk = GoDDDPKPopUpButton()
	var body = NSImageView()
	var name = GoDPokemonPopUpButton()
	var item = GoDItemPopUpButton()
	var level = GoDLevelPopUpButton()
	var moves = [GoDMovePopUpButton]()
	
	var ability = GoDPopUpButton()
	var nature = GoDNaturePopUpButton()
	var gender = GoDGenderPopUpButton()
	var happiness = NSTextField(frame: .zero)
	
	var ivs = NSTextField(frame: .zero)
	var evs  = [NSTextField]()
	
	var shadowMoves = [GoDMovePopUpButton]()
	var shadowCatchrate = NSTextField(frame: .zero)
	var shadowCounter = NSTextField(frame: .zero)
	var shadowAggression = NSTextField(frame: .zero)
	var shadowFlee = NSTextField(frame: .zero)
	
	var views = [String : NSView]()
	var metrics = [String : NSNumber]()
	
	var delegate : GoDTrainerViewController! {
		didSet {
			setUp()
		}
	}
	
	func setUp() {
		let trainer = self.delegate.currentTrainer
		
		if self.dpkm.deck != trainer.deck {
			self.dpkm.deck = self.delegate.currentTrainer.deck
		}
		
		let pokemon = self.delegate.pokemon[self.index]
		
		if !pokemon.isSet {
			self.setBackgroundColour(GoDDesign.colourGrey())
		} else if pokemon.isShadowPokemon {
			self.setBackgroundColour(GoDDesign.colourPurple())
		} else {
			self.setBackgroundColour(GoDDesign.colourLightGrey())
		}
		
		for key in views.keys {
			let view = views[key]!
			if key.contains("shadow") {
				view.isHidden = !pokemon.isShadowPokemon
			} else if (key != "dpkm") && (key != "ddpk") {
				view.isHidden = !pokemon.isSet
			} else {
				view.isHidden = false
			}
		}
		
		self.name.selectPokemon(pokemon: pokemon.species)
		self.dpkm.selectItem(at: pokemon.deckData.DPKMIndex)
		self.ddpk.selectItem(at: pokemon.isShadowPokemon ? pokemon.deckData.index : 0)
		self.body.image = pokemon.species.body
		self.level.selectLevel(level: pokemon.level)
		self.item.selectItem(item: pokemon.item)
		for move in self.moves {
			move.selectMove(move: pokemon.moves[move.tag])
		}
		for move in self.shadowMoves {
			move.selectMove(move: pokemon.shadowMoves[move.tag])
		}
		
		self.ivs.integerValue = pokemon.IVs
		for i in 0 ..< 6 {
			self.evs[i].integerValue = pokemon.EVs[i]
		}
		
		
		self.ability.setTitles(values: [pokemon.species.stats.ability1.name.string , pokemon.species.stats.ability2.name.string])
		self.ability.selectItem(at: pokemon.ability)
		self.nature.selectNature(nature: pokemon.nature)
		self.gender.selectGender(gender: pokemon.gender)
		self.happiness.integerValue = pokemon.happiness
		
		self.shadowCounter.integerValue = pokemon.shadowCounter
		self.shadowAggression.integerValue = pokemon.shadowAggression
		self.shadowFlee.integerValue = pokemon.shadowFleeValue
		self.shadowCatchrate.integerValue = pokemon.shadowCatchRate
		
		
	}
	
	init() {
		super.init(frame: .zero)
		
		self.translatesAutoresizingMaskIntoConstraints = false
		self.wantsLayer = true
		self.layer?.cornerRadius = 12
		self.layer?.borderColor = GoDDesign.colourBlack().cgColor
		self.layer?.borderWidth = 1
		
		for i in 0 ..< 4 {
			let move = GoDMovePopUpButton()
			move.tag = i
			self.moves.append(move)
			self.addSubview(move)
			self.views["move\(i)"] = move
			move.font = GoDDesign.fontOfSize(8)
			
			if i != 0 {
				self.addConstraintEqualSizes(view1: moves[0], view2: move)
			}
			
			let shadow = GoDMovePopUpButton()
			shadow.tag = i
			self.shadowMoves.append(shadow)
			self.addSubview(shadow)
			self.views["shadow\(i)"] = shadow
			shadow.font = GoDDesign.fontOfSize(8)
			
			self.addConstraintEqualSizes(view1: moves[0], view2: shadow)
		}
		
		for i in 0 ..< 6 {
			let ev = NSTextField(frame: .zero)
			ev.tag = i
			self.evs.append(ev)
			self.addSubview(ev)
			self.views["ev\(i)"] = ev
		}
		
		self.dpkm.font = GoDDesign.fontOfSize(8)
		self.ddpk.font = GoDDesign.fontOfSize(8)
		
		let byteFormat = NumberFormatter()
		let ivFormat = NumberFormatter()
		let shortFormat = NumberFormatter()
		
		byteFormat.minimum = 0x00
		byteFormat.maximum = 0xFF
		ivFormat.minimum = 0
		ivFormat.maximum = 31
		shortFormat.minimum = 0x00
		shortFormat.maximum = 0xFFFF
		
		for view in evs + [shadowCatchrate,shadowAggression,shadowFlee,happiness] {
			view.formatter = byteFormat
		}
		shadowCounter.formatter = shortFormat
		ivs.formatter = ivFormat
		
		self.addSubview(dpkm)
		self.views["dpkm"] = dpkm
		self.addSubview(ddpk)
		self.views["ddpk"] = ddpk
		self.addSubview(name)
		self.views["name"] = name
		self.addSubview(body)
		self.views["body"] = body
		self.addSubview(item)
		self.views["item"] = item
		self.addSubview(level)
		self.views["level"] = level
		self.addSubview(ability)
		
		self.views["ability"] = ability
		self.addSubview(nature)
		self.views["nature"] = nature
		self.addSubview(gender)
		self.views["gender"] = gender
		self.addSubview(happiness)
		self.views["happ"] = happiness
		self.addSubview(ivs)
		self.views["iv"] = ivs
		
		self.addSubview(shadowCatchrate)
		self.views["shadowcr"] = shadowCatchrate
		self.addSubview(shadowCounter)
		self.views["shadowct"] = shadowCounter
		self.addSubview(shadowAggression)
		self.views["shadowag"] = shadowAggression
		self.addSubview(shadowFlee)
		self.views["shadowfl"] = shadowFlee
		
		
		let titles = ["IVs","HP","Atk","Def","Sp.A","Sp.D","Speed","Happiness","Counter","Flee","Aggression","Catch rate"]
		let visuals = ["IVs","hpEV","atkEV","defEV","spaEV","spdEV","speEV","happiness","shadowctT","shadowflT","shadowagT","shadowcrT"]
		for i in 0 ..< titles.count {
			let title = titles[i]
			let name = visuals[i]
			
			let view = NSTextField(frame: .zero)
			view.stringValue = title
			view.setBackgroundColour(.clear)
			views[name] = view
			self.addSubview(view)
			view.alignment = .center
			self.addConstraintHeight(view: view, height: 15)
			view.font = GoDDesign.fontOfSize(10)
			view.drawsBackground = false
			view.isBezeled = false
			view.isEditable = false
		}
		
		for i in 0 ... 5 {
			let view1 = views[["hpEV","atkEV","defEV","spaEV","spdEV","speEV",][i]]!
			let view2 = evs[i]
			self.addConstraintAlignLeftAndRightEdges(view1: view1, view2: view2)
			view2.alignment = .right
			view2.font = GoDDesign.fontOfSize(8)
		}
		
		for i in 0 ... 5 {
			let view1 = views[["IVs","happiness","shadowctT","shadowflT","shadowagT","shadowcrT"][i]]!
			let view2 = [ivs,happiness,shadowCounter,shadowFlee,shadowAggression,shadowCatchrate][i]
			self.addConstraintAlignLeftAndRightEdges(view1: view1, view2: view2)
			view2.alignment = .right
			view2.font = GoDDesign.fontOfSize(8)
		}
		
		for i in 1 ... 3 {
			self.addConstraintEqualWidths(view1: moves[0], view2: moves[i])
			self.addConstraintEqualWidths(view1: shadowMoves[0], view2: shadowMoves[i])
		}
		
		for view in ["hpEV","atkEV","defEV","spaEV","spdEV","speEV",] {
			self.addConstraintEqualWidths(view1: evs[0], view2: views[view]!)
		}
		for i in 1 ... 5 {
			self.addConstraintEqualSizes(view1: evs[i], view2: evs[0])
		}
		
		for key in views.keys {
			let view = views[key]!
			view.translatesAutoresizingMaskIntoConstraints = false
			
			view.isHidden = true
		}
		
		self.metrics["g"] = 5
		
		for view in [shadowCatchrate,shadowFlee,shadowAggression] {
			self.addConstraintEqualWidths(view1: view, view2: shadowCounter)
		}
		
		self.addConstraintWidth(view: self.body, width: 80)
		self.addConstraintEqualSizes(view1: ivs, view2: happiness)
		self.addConstraintHeight(view: ivs, height: 15)
		self.addConstraintHeight(view: moves[0], height: 20)
		self.addConstraintHeight(view: evs[0], height: 15)
		self.addConstraintEqualWidths(view1: self.dpkm, view2: self.ddpk)
		
		for (view1, view2) : (NSView, NSView) in [(level,name),(ability,item),(nature,gender)] as! [(NSView, NSView)] {
			self.addConstraintEqualSizes(view1: view1, view2: view2)
		}
		
		self.addConstraints(visualFormat: "H:|-(g)-[dpkm]-(g)-[ddpk]-(g)-|", layoutFormat: [.alignAllTop,.alignAllBottom], metrics: metrics, views: views)
		self.addConstraints(visualFormat: "V:|-(g)-[dpkm(20)]-(g)-[body(80)]", layoutFormat: [.alignAllLeft], metrics: metrics, views: views)
		self.addConstraints(visualFormat: "H:|-(g)-[body]-(g)-[level]-(g)-[name]-(g)-|", layoutFormat: [.alignAllTop], metrics: metrics, views: views)
		self.addConstraints(visualFormat: "H:[body]-(g)-[ability]-(g)-[item]-(g)-|", layoutFormat: [.alignAllCenterY], metrics: metrics, views: views)
		self.addConstraints(visualFormat: "H:[body]-(g)-[nature]-(g)-[gender]-(g)-|", layoutFormat: [.alignAllBottom], metrics: metrics, views: views)
		self.addConstraints(visualFormat: "V:[name(20)]-(10)-[ability(20)]-(10)-[nature(20)]", layoutFormat: [], metrics: metrics, views: views)
		self.addConstraintEqualSizes(view1: name, view2: level)
		self.addConstraintEqualSizes(view1: name, view2: item)
		self.addConstraintEqualSizes(view1: ability, view2: nature)
		self.addConstraintEqualSizes(view1: ability, view2: gender)
		self.addConstraintHeight(view: ability, height: 20)
		self.addConstraints(visualFormat: "V:[iv]-(g)-[hpEV][ev0]-(g)-[move0]-(g)-[shadow0]-(g)-[shadowctT][shadowct]", layoutFormat: [], metrics: metrics, views: views)
		self.addConstraints(visualFormat: "V:[nature]-(g)-[IVs][iv]", layoutFormat: [.alignAllLeft, .alignAllRight], metrics: metrics, views: views)
		self.addConstraints(visualFormat: "V:[gender]-(g)-[happiness][happ]", layoutFormat: [.alignAllLeft, .alignAllRight], metrics: metrics, views: views)
		self.addConstraints(visualFormat: "H:|-(g)-[hpEV]-(g)-[atkEV]-(g)-[defEV]-(g)-[spaEV]-(g)-[spdEV]-(g)-[speEV]-(g)-|", layoutFormat: [.alignAllTop, .alignAllBottom], metrics: metrics, views: views)
		self.addConstraints(visualFormat: "H:|-(g)-[ev0]-(g)-[ev1]-(g)-[ev2]-(g)-[ev3]-(g)-[ev4]-(g)-[ev5]-(g)-|", layoutFormat: [.alignAllTop, .alignAllBottom], metrics: metrics, views: views)
		self.addConstraints(visualFormat: "H:|-(g)-[move0]-(g)-[move1]-(g)-[move2]-(g)-[move3]-(g)-|", layoutFormat: [.alignAllTop, .alignAllBottom], metrics: metrics, views: views)
		self.addConstraints(visualFormat: "H:|-(g)-[shadow0]-(g)-[shadow1]-(g)-[shadow2]-(g)-[shadow3]-(g)-|", layoutFormat: [.alignAllTop, .alignAllBottom], metrics: metrics, views: views)
		self.addConstraints(visualFormat: "H:|-(g)-[shadowctT]-(g)-[shadowflT]-(g)-[shadowagT]-(g)-[shadowcrT]-(g)-|", layoutFormat: [.alignAllTop, .alignAllBottom], metrics: metrics, views: views)
		self.addConstraints(visualFormat: "H:|-(g)-[shadowct]-(g)-[shadowfl]-(g)-[shadowag]-(g)-[shadowcr]-(g)-|", layoutFormat: [.alignAllTop, .alignAllBottom], metrics: metrics, views: views)
		
		
		
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	func swapAbility() {
		self.delegate.pokemon[self.index].ability = 1 - self.delegate.pokemon[self.index].ability
		self.setUp()
	}
	
}















