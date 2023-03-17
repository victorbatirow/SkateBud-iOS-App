//
//  BladeTrickViewController.swift
//  SkateBud
//
//  Created by Victor on 2023-03-15.
//

import UIKit

class BladeTrickViewController: UIViewController {

    // UI components
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var generateBtn: UIButton!
    
    // CONSTANTS: Trick Names -- Order: easy to hard
    let allTricks = ["Makio", "Grind", "Soul", "Mizou", "Porn Star", "Acid", "Fahrvergnugen", "Royale", "Unity", "Savannah", "X-Grind", "Torque Soul", "Mistrail", "Torque", "Backslide", "Cab Driver", "Christ Makio", "UFO",  "Fastslide", "Stub Soul", "Tea Kettle", "Pudslide"]
    let soulplateTricks = ["Makio", "Soul", "Mizou", "Porn Star", "Acid", "X-Grind", "Torque Soul", "Mistrail", "Christ Makio", "Stub Soul", "Tea Kettle"]
    let grooveTricks = ["Grind", "Fahrvergnugen ", "Royale", "Unity", "Savannah", "Torque", "Backslide", "Cab Driver", "UFO", "Fastslide", "Pudslide"]
    let topsideNegativeTricks = ["Makio", "Soul", "Mizou", "Porn Star", "Acid", "Torque Soul", "Mistrail", "Christ Makio"]
    
    // CONSTANTS: Spins -- Order: easy to hard
    let soulplateForwardInSpins = ["", "Alley-Oop", "True Spin", "360", "Hurricane"]
    let soulplateFakieInSpins = ["In-Spin", "Out-Spin", "Zero Spin", "Cab Alley-Oop", "Cab True Spin"]
    let soulplateForwardOutSpins = ["", "to Fakie", "360 Out"]
    let soulplateFakieOutSpins = ["", "to Forward", "Full-Cab Out"]
    let grooveForwardInSpins = ["FS", "BS", "270 BS", "270 FS"]
    let grooveFakieInSpins = ["FS", "BS", "270 BS", "270 FS"]
    let grooveSidewaysOutSpins = ["to Fakie", "to Forward", "270 Out", "270 to Fakie Out", "270 to Forward Out", "450 Out"]
    
    // Game Difficulty Options
    var difficulty: Double = 0.8

    // TRICK NAME DISPLAYED VARIABLES
    var trickName: String = ""
    var spinIn: String = ""
    var fakieStamp: String = ""
    var topsideStamp: String = ""
    var negativeStamp: String = ""
    var rewindStamp: String = ""
    var spinOut: String = ""
    var difficultyStamp: String = "Noob"

    // Difficulty Option System
    var fakieChance: Double = 0.5
    var topsideChance: Double = 0.7
    var negativeChance: Double = 0.2
    var rewindChance: Double = 0.25

    var tricksCAP: Int = 22
    var soulplateForwardInSpinsCAP: Int = 5
    var soulplateFakieInSpinsCAP: Int = 5
    var soulplateForwardOutSpinsCAP: Int = 3
    var soulplateFakieOutSpinsCAP: Int = 3
    var grooveForwardInSpinsCAP: Int = 4
    var grooveFakieInSpinsCAP: Int = 4
    var grooveSidewaysOutSpinsCAP: Int = 6

    
    // TRICK VARIATIONS (move to inside function)
    var isFakie: Bool = false
    var isTopside: Bool = false
    var isNegative: Bool = false
    var isRewind: Bool = false

    // Skater's current stance during a trick
    var currentStance: String = "Forward"
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        generateBtn.layer.cornerRadius = 10

        // Do any additional setup after loading the view.
    }
    
    @IBAction func generateBtn(_ sender: Any) {
        print("\n\n- Fakie chance: \(fakieChance * 100)%")
        print("- Topside chance: \(topsideChance * 100)%")
        print("- Negative chance: \(negativeChance * 100)%")
        print("- Rewind chance: \t\(rewindChance * 100)%")
        print("TRICKS CAP IS::: \(tricksCAP)")
        // Choose a soulplate or groove trick (this wil determine the spin, topside and negative options) - Difficulty applied
        var trick = allTricks[Int.random(in: 0..<tricksCAP)]

        // Find out if the chosen trick is done with soul plate
        if soulplateTricks.contains(trick) {
            // SOULPLATE TRICK CHOSEN !!!
            print("SOULPLATE TRICK CHOSEN!!!")
            
            // 1.1 Choose Fakie
            // Set the Fakie chance according to difficulty
            isFakie = (Double.random(in: 0...1) < fakieChance)
            if isFakie {
                currentStance = "Fakie"
                fakieStamp = "Fakie"
            } else {
                currentStance = "Forward"
                fakieStamp = ""
            }
            
            // 1.2 Choose Spin in
            if currentStance == "Fakie" {
                // Choose a spin from the list according to the difficulty
                spinIn = soulplateFakieInSpins[Int.random(in: 0..<soulplateFakieInSpinsCAP)]
                // Update the skater's current stance
                if spinIn == "In-Spin" || spinIn == "Out-Spin" {
                    currentStance = "Forward"
                }
            } else if currentStance == "Forward" {
                // Choose a spin from the list according to the difficulty
                spinIn = soulplateForwardInSpins[Int.random(in: 0..<soulplateForwardInSpinsCAP)]
                // Update the skater's current stance
                if spinIn == "Alley-Oop" || spinIn == "True Spin" {
                    currentStance = "Fakie"
                }
            }
            
            // 1.3 Choose topside
            if topsideNegativeTricks.contains(trick) {
                // Set the topside according to topside chance
                isTopside = (Double.random(in: 0...1) < topsideChance)
                // Update the topside stamp
                if isTopside {
                    topsideStamp = " Top"
                } else {
                    topsideStamp = ""
                }
            }
            
            // 1.4 Choose Negative
            if topsideNegativeTricks.contains(trick) {
                //Reduce chance of negative if trick is topside
                if isTopside && negativeChance != 0 {
                    negativeChance = 0.05
                }
                // Set the topside chance according to difficulty
                isNegative = (Double.random(in: 0...1) < negativeChance)
                // Update the negative stamp
                if isNegative {
                    negativeStamp = " Negative"
                } else {
                    negativeStamp = ""
                }
                // Cancel negative + topsides unless in God difficulty
                if difficulty <= 79 && isTopside && isNegative {
                    negativeStamp = ""
                }
            }
            
            // 1.5 Choose Spin Out
            if currentStance == "Fakie" {
                spinOut = soulplateFakieOutSpins[Int.random(in: 0..<soulplateFakieOutSpinsCAP)]
                // Update the skater's current stance
                if spinOut == "to Forward" {
                    currentStance = "Forward"
                }
            } else {
                spinOut = soulplateForwardOutSpins[Int.random(in: 0..<soulplateForwardOutSpinsCAP)]
                // Update the skater's current stance
                if spinOut == "to Fakie" {
                    currentStance = "Fakie"
                }
            }
            
            // 1.6 Choose if Spin Out is Rewind
            // Set the topside chance according to difficulty
            isRewind = (Double.random(in: 0...1) < rewindChance)
            // check if there's at least a 180 spin in and out
            if (spinIn == "" || spinIn == "Zero Spin" || spinOut == "") {
                rewindStamp = ""
            } else {
                if (isRewind) {
                    rewindStamp = " Rewind"
                }
            }
            
            // 1.7 Find the edge cases: Special named tricks
            // Edge Case: Top Makio = Fishbrain
            if (trick == "Makio" && isTopside == true) {
                trick = "Fishbrain"
                topsideStamp = ""
            }
            // Edge Case: Top Christ Makio = Christ Fishbrain
            if (trick == "Christ Makio" && isTopside == true) {
                trick = "Christ Fishbrain"
                topsideStamp = ""
            }
            // Edge Case: Top Mizou = Sweatstance
            if (trick == "Mizou" && isTopside == true) {
                trick = "Sweatstance"
                topsideStamp = ""
            }
            // Edge Case: Alley-Oop Sweatstance = Kind
            if (trick == "Sweatstance" && spinIn == "Alley-Oop") {
                trick = "Kind Grind"
                spinIn = ""
            }
            // Edge Case: Cab Alley-Oop Sweatstance = Cab Kind
            if (trick == "Sweatstance" && spinIn == "Cab Alley-Oop") {
                trick = "Kind Grind"
                spinIn = "Cab"
            }
            // Edge Case: True Spin Sweatstance = True Spin Kind
            if (trick == "Sweatstance" && (spinIn == "True Spin" || spinIn == "Cab True Spin" || spinIn == "Zero Spin")) {
                trick = "Kind Grind"
            }
            // Edge Case: Alley-Oop Top Mistrail = Misfit
            if (trick == "Mistrail" && isTopside == true && spinIn == "Alley-Oop") {
                trick = "Misfit"
                spinIn = ""
                topsideStamp = ""
            }
            // Edge Case: Cab Alley-Oop top mistrail = Misfit
            if (trick == "Mistrail" && isTopside == true && spinIn == "Cab Alley-Oop") {
                trick = "Misfit"
                spinIn = "Cab"
                topsideStamp = ""
            }
            // Edge Case: True Spin Top Mistrail = True Spin Misfit
            // MAYBE USE CURRENT STANCE FAKIE INSTEAD OF SPIN IN???
            if (trick == "Mistrail" && isTopside == true && (spinIn == "True Spin" || spinIn == "Cab True Spin")) {
                trick = "Misfit"
                topsideStamp = ""
            }
            // Edge Case: fakie stance + torque soul = soulyale
            if (trick == "Torque Soul" && currentStance == "Fakie") {
                trick = "Soyale"
            }
            
            // Edge Case: fakie stance + torque soul = soulyale
            
            // FINAL STEP: Set trick name
            trickName = ("\(spinIn)\(negativeStamp)\(topsideStamp) \(trick)\(rewindStamp) \(spinOut)")
            
        } else {
            // GROOVE TRICK CHOSEN !!!
            print("\nGROOVE TRICK CHOSEN!!!")

//            var initialStance = ""

            // 1.1 Choose Fakie
            // Set the Fakie chance according to difficulty
            isFakie = (Double.random(in: 0...1) < fakieChance)
            if (isFakie) {
                currentStance = "Fakie"
                fakieStamp = "Fakie"
                // initialStance = 'Fakie'
            } else {
                currentStance = "Forward"
                fakieStamp = ""
                // initialStance = 'Forward'
            }

            // 2.2 Choose Spin in
            if (currentStance == "Fakie") {
                spinIn = grooveFakieInSpins[Int.random(in: 0..<grooveFakieInSpinsCAP)]
                // Update the skater's current stance
                //currentStance = 'Sideways' // this messes up the edge case for true spins
            } else if (currentStance == "Forward") {
                spinIn = grooveForwardInSpins[Int.random(in: 0..<grooveForwardInSpinsCAP)]
                // Update the skater's current stance
                //currentStance = 'Sideways' // this messes up the edge case for true spins
            }

            // Edge Case: forward stance 270 frontside = True Spin
            if (currentStance == "Forward" && spinIn == "270 FS") {
                spinIn = "270 FS (True Spin)"
            }
            
            // 2.3 Choose Spin Out
            if (currentStance == "Fakie") {
              spinOut = grooveSidewaysOutSpins[Int.random(in: 0..<grooveSidewaysOutSpinsCAP)]
              // Update the skater's current stance
              if (spinOut == "to Forward") {
                currentStance = "Forward"
              }
            } else {
              spinOut = grooveSidewaysOutSpins[Int.random(in: 0..<grooveSidewaysOutSpinsCAP)];
              // Update the skater's current stance
              if (spinOut == "to Fakie") {
                currentStance = "Fakie"
              }
            }

            // 2.4 Choose if Spin Out is Rewind
            // ?? should i even do this? everyone's frontside and backside grinds are different & different shoulder fakie
            // Forward + BS || Fakie + 270 BS
            // Fakie
            rewindStamp = "";


            // 2.5 Find the edge cases and address them
            // Edge Case: FS grind = Frontside // maybe just leave the way it is
            if (spinIn == "FS" && spinIn == "270 FS") {
              spinIn = "270 FS (True Spin)"
            }
            // Edge Case: BS Grind = Backside Grind && 270 BS Grind = 270 Backside Grind
            if (trick == "Grind" && spinIn.contains("BS")) {
              trick = "Backside Grind"
              if (spinIn == "BS") {
                spinIn = ""
              } else
              if (spinIn == "270 BS") {
                spinIn = "270"
              }
            }
            // Edge Case: FS Grind = Frontside Grind && 270 FS Grind = 270 Frontside Grind
            if (trick == "Grind" && spinIn.contains("FS")) {
              trick = "Frontside Grind"
              if (spinIn == "FS") {
                spinIn = ""
              } else
              if (spinIn == "270 FS") {
                spinIn = "270"
              }
            }

            // FINAL STEP: Set trick name
            trickName = (fakieStamp + " " + spinIn + " " + trick + rewindStamp + " " + spinOut);

        }

        // Update trick name label
        nameLbl.text = trickName

    }

}
