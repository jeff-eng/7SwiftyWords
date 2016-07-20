//
//  ViewController.swift
//  Project8
//
//  Created by Jeffrey Eng on 7/19/16.
//  Copyright © 2016 Jeffrey Eng. All rights reserved.
//

import UIKit
import GameplayKit

class ViewController: UIViewController {
    @IBOutlet weak var cluesLabel: UILabel!
    @IBOutlet weak var answersLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var currentAnswer: UITextField!

    //array to store all the buttons
    var letterButtons = [UIButton]()
    //array to store the buttons currently being used to spell an answer
    var activatedButtons = [UIButton]()
    //array to store the possible solutions
    var solutions = [String]()
    
    var score = 0
    var level = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for subview in view.subviews where subview.tag == 1001 {
            let btn = subview as! UIButton
            letterButtons.append(btn)
            btn.addTarget(self, action: #selector(letterTapped), forControlEvents: .TouchUpInside)
        }
        
        loadLevel()
    }

    func loadLevel() {
        var clueString = ""
        var solutionString = ""
        var letterBits = [String]()
        
        if let levelFilePath = NSBundle.mainBundle().pathForResource("level\(level)", ofType: "txt") {
            if let levelContents = try? String(contentsOfFile: levelFilePath, usedEncoding: nil) {
                var lines = levelContents.componentsSeparatedByString("\n")
                lines = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(lines) as! [String]
                
                for (index, line) in lines.enumerate() {
                    let parts = line.componentsSeparatedByString(": ")
                    let answer = parts[0]
                    let clue = parts[1]
                    
                    clueString += "\(index + 1). \(clue)\n"
                    
                    let solutionWord = answer.stringByReplacingOccurrencesOfString("|", withString: "")
                    solutionString += "\(solutionWord.characters.count) letters\n"
                    solutions.append(solutionWord)
                    
                    let bits = answer.componentsSeparatedByString("|")
                    letterBits += bits
                }
            }
        }
        
        cluesLabel.text = clueString.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
        answersLabel.text = solutionString.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
        
        letterBits = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(letterBits) as! [String]
        letterButtons = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(letterButtons) as! [UIButton]
        
        if letterBits.count == letterButtons.count {
            for i in 0..<letterBits.count {
                letterButtons[i].setTitle(letterBits[i], forState: .Normal)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    @IBAction func submitTapped(sender: AnyObject) {
        // if the user's answer in the text field matches a possible solution in the array, we get back a position in the array with the indexOf method and save that index position in solutionPosition constant. Then clear the activatedButtons array which stores which buttons user has already clicked.
        if let solutionPosition = solutions.indexOf(currentAnswer.text!) {
            activatedButtons.removeAll()
            
            var splitClues = answersLabel.text!.componentsSeparatedByString("\n")
            splitClues[solutionPosition] = currentAnswer.text!
            answersLabel.text = splitClues.joinWithSeparator("\n")
            
            // clear the text field
            currentAnswer.text = ""
            // increment score
            score += 1
            
            if score % 7 == 0 {
                let ac = UIAlertController(title: "Awesome job!", message: "Ready for the next level?", preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "Let's go", style: .Default, handler: levelUp))
                presentViewController(ac, animated: true, completion: nil)
            }
        }
    }

    @IBAction func clearTapped(sender: AnyObject) {
        //clear text from the current answer text field
        currentAnswer.text = ""
        
        //currently, there is an array that holds all the buttons that were tapped(which is being stored in activatedButtons array). We need to loop through that array in order to change the hidden property to false to unhide those buttons.
        for btn in activatedButtons {
            btn.hidden = false
        }
        
        //clear the activatedButtons array using the removeAll array method
        activatedButtons.removeAll()
    }
 
    func letterTapped(btn: UIButton) {
        currentAnswer.text = currentAnswer.text! + btn.titleLabel!.text!
        activatedButtons.append(btn)
        btn.hidden = true
        
    }
    
    func levelUp(action: UIAlertAction!) {
        // increment the global variable level by one
        level += 1
        
        // clear the solutions array for the next round of clues
        solutions.removeAll()
        
        // call the method to load next level
        loadLevel()
        
        //unhide all the buttons
        for btn in letterButtons {
            btn.hidden = false
        }
        
    }
    
}

