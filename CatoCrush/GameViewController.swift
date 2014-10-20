//
//  GameViewController.swift
//  CatoCrush
//
//  Created by Peter on 2014-09-08.
//  Copyright (c) 2014 Digital AG Studios. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class GameViewController: UIViewController {
    var scene: GameScene!
    var level: Level!
    var movesLeft: Int = 0
    var score: Int = 0
    var tapGestureRecognizer: UITapGestureRecognizer!
    var backgroundMusic: AVAudioPlayer!
    
    @IBOutlet var targetLabel: UILabel!
    @IBOutlet var movesLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var gameOverPanel: UIImageView!
    @IBOutlet var shuffleButton: UIButton!
    
    @IBAction func shuffleButtonPressed(AnyObject) {
        shuffle()
        decrementMoves()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure the view.
        let skView = self.view as SKView
        skView.multipleTouchEnabled = false
        
        
        /* Set the scale mode to scale to fit the window */
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        level = Level(filename: "Level_1")
        scene.level = level
        scene.addTiles()
        
        scene.swipeHandler = handleSwipe
        
        gameOverPanel.hidden = true
        
        skView.presentScene(scene)
        
        // Load and start background music.
        let url = NSBundle.mainBundle().URLForResource("Mining by Moonlight", withExtension: "mp3")
        backgroundMusic = AVAudioPlayer(contentsOfURL: url, error: nil)
        backgroundMusic.numberOfLoops = -1
        backgroundMusic.play()
        
        beginGame()
        
        
    }

    override func shouldAutorotate() -> Bool {
        return true
    }
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.toRaw())
        } else {
            return Int(UIInterfaceOrientationMask.All.toRaw())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    func beginGame() {
        movesLeft = level.maximumMoves
        score = 0
        updateLabels()
        
        level.resetComboMultiplier()
        scene.animateBeginGame() {
            self.shuffleButton.hidden = false
        }
        
        shuffle()
    }
    
    func shuffle() {
        scene.removeAllProgramSprites()
        
        let newPrograms = level.shuffle()
        scene.addSpritesForPrograms(newPrograms)
    }
    
    func handleSwipe(swap: Swap) {
        view.userInteractionEnabled = false
        
        if level.isPossibleSwap(swap) {
            level.performSwap(swap)
            scene.animateSwap(swap, completion: handleMatches)
        } else {
            scene.animateInvalidSwap(swap) {
                self.view.userInteractionEnabled = true
            }
        }
    }
    
    func handleMatches() {
        let chains = level.removeMatches()
        
        if chains.count == 0 {
            beginNextTurn()
            return
        }
        // TODO: do something with the chains set
        
        scene.animateMatchedPrograms(chains) {
            let columns = self.level.fillHoles()
            self.scene.animateFallingPrograms(columns) {
                let columns = self.level.topUpPrograms()
                self.scene.animateNewPrograms(columns) {
                    self.handleMatches()
                }
            }
        }
        
        for chain in chains {
            self.score += chain.score
        }
        self.updateLabels()
    }
    
    func beginNextTurn() {
        level.detectPossibleSwaps()
        view.userInteractionEnabled = true
        
        decrementMoves()
    }
    
    func updateLabels() {
        targetLabel.text = NSString(format: "%ld", level.targetScore)
        movesLabel.text = NSString(format: "%ld", movesLeft)
        scoreLabel.text = NSString(format: "%ld", score)
    }
    
    func decrementMoves() {
        --movesLeft
        updateLabels()
        
        if score >= level.targetScore {
            gameOverPanel.image = UIImage(named: "LevelComplete")
            showGameOver()
        } else if movesLeft == 0 {
            gameOverPanel.image = UIImage(named: "GameOver")
            showGameOver()
        }
    }
    
    func showGameOver() {
        gameOverPanel.hidden = false
        scene.userInteractionEnabled = false
        
        shuffleButton.hidden = true
        
        scene.animateGameOver() {
            self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "hideGameOver")
            self.view.addGestureRecognizer(self.tapGestureRecognizer)
        }
    }
    
    func hideGameOver() {
        view.removeGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer = nil
        
        gameOverPanel.hidden = true
        scene.userInteractionEnabled = true
        
        beginGame()
    }
    
}
