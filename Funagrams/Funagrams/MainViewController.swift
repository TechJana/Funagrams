//
//  ViewController.swift
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 3/22/17.
//  Copyright © 2017 pluggablez. All rights reserved.
//

import UIKit
import GameKit
import FunagramsKit

class MainViewController: UIViewController, GKGameCenterControllerDelegate {
    
    @IBOutlet var viewGameSkill: UIView!
    @IBOutlet var visualEffectBlurView: UIVisualEffectView!
    @IBOutlet var btnPlay: UIButton!
    @IBOutlet var btnSkillAmateur: UIButton!
    @IBOutlet var btnSkillProfessional: UIButton!
    @IBOutlet var btnSkillExpert: UIButton!
    @IBOutlet var btnCurrentSkill: UIButton!
    @IBOutlet var btnLeaderBoard: UIButton!
    @IBOutlet var btnAchievement: UIButton!
    
    let segueGoToGame = "gotoGame"
    var isGameCenterEnabled: Bool = false
    var gameCenterDefaultLeaderBoard: String = ""
    var score = 0
    let gameCenterLeaderBoardId = Level.Level01.LeaderBoard
    var currentSkill: Skill = Skill.amateur
    
    var blurEffect: UIVisualEffect!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // disable the blur effect
        blurEffect = visualEffectBlurView.effect
        visualEffectBlurView.effect = nil

        // call game center authentication
        authenticateLocalPlayer()
        
        // load last saved game settings
        
        // set skill button based on last selection
        currentSkill = Skill.amateur
        btnCurrentSkill.setImage(UIImage(named: currentSkill.imageName), for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    func dismissGameSkillView() {
        UIView.animate(withDuration: 0.3, animations: {
            // hide blur effect
            self.visualEffectBlurView.effect = nil
            
            // fade-out viewGameSkill
            self.viewGameSkill.alpha = 0
        }) { (success: Bool) in
            self.viewGameSkill.removeFromSuperview()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueGoToGame {
            let gameViewController = (segue.destination as! GameViewController)

            // set respective skill and level
            gameViewController.userSkill = currentSkill
        }
    }
    
    @IBAction func btnSkillAmateur_Click(_ sender: UIButton) {
        currentSkill = Skill.amateur
        btnCurrentSkill.setImage(UIImage(named: "BtnSkillAmateurImage"), for: .normal)
        dismissGameSkillView()
    }
    
    @IBAction func btnSkillProfessional_Click(_ sender: UIButton) {
        currentSkill = Skill.professional
        btnCurrentSkill.setImage(UIImage(named: "BtnSkillProfessionalImage"), for: .normal)
        dismissGameSkillView()
    }
    
    @IBAction func btnSkillExpert_Click(_ sender: UIButton) {
        currentSkill = Skill.expert
        btnCurrentSkill.setImage(UIImage(named: "BtnSkillExpertImage"), for: .normal)
        dismissGameSkillView()
    }
    
    @IBAction func btnCurrentSkill_Click(_ sender: UIButton) {
        // add viewGameSkill and center it
        self.viewGameSkill.alpha = 1
        self.view.addSubview(viewGameSkill)
        viewGameSkill.center = self.view.center
        btnSkillProfessional.center = viewGameSkill.center
        viewGameSkill.layoutSubviews()
        
        // prepare for animation to give a pop-bounce effect
        viewGameSkill.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        
        // animation for pop-bounce effect
        UIView.animate(withDuration: 0.3/1.5, animations: {
            self.visualEffectBlurView.effect = self.blurEffect
            self.viewGameSkill.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { (success: Bool) in
            UIView.animate(withDuration: 0.3/2, animations: {
                self.viewGameSkill.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: { (success: Bool) in
                UIView.animate(withDuration: 0.3/2, animations: {
                    self.viewGameSkill.transform = CGAffineTransform.identity
                })
            })
        }
    }
    
    @IBAction func btnPlay_Click(_ sender: UIButton) {
        // initiate game for selected Skill
        performSegue(withIdentifier: segueGoToGame, sender: sender)
    }
    
    @IBAction func btnLeaderBoard_Click(_ sender: UIButton) {
        if !isGameCenterEnabled {
            authenticateLocalPlayer()
        }
        
        if isGameCenterEnabled {
            let gameCenter = GKGameCenterViewController()
            gameCenter.gameCenterDelegate = self
            gameCenter.viewState = .leaderboards
            gameCenter.leaderboardIdentifier = Level.none.LeaderBoard
            present(gameCenter, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnAchievement_Click(_ sender: UIButton) {
        if !isGameCenterEnabled {
            authenticateLocalPlayer()
        }
        
        if isGameCenterEnabled {
            GKAchievement.loadAchievements { (achievements, error) in
                guard let achievements = achievements else { return }
                print(achievements)
                
                // write custom achievements screen to display for user
            }
            let gameCenter = GKGameCenterViewController()
            gameCenter.gameCenterDelegate = self
            gameCenter.viewState = .achievements
            gameCenter.leaderboardIdentifier = Level.none.LeaderBoard
            present(gameCenter, animated: true, completion: nil)
        }
    }
    
    func authenticateLocalPlayer() -> Void {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            if viewController != nil {
                // show login if player not yet sign-in
                self.present(viewController!, animated: true, completion: nil)
            }
            else if localPlayer.isAuthenticated {
                // player is login; load game center
                self.isGameCenterEnabled = true
                
                // get default leaderboard id
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderBoardIdentifier, error) in
                    if error != nil {
                        print(error!)
                    }
                    else {
                        self.gameCenterDefaultLeaderBoard = leaderBoardIdentifier!
                    }
                })
            }
            else {
                // game center not enabled
                self.isGameCenterEnabled = false
                print("LocalPlayer could not be authenticated")
                print(error!)
            }
        }
    }
    
    func saveScoreToGameCenter(score: Int) {
        let bestScore = GKScore(leaderboardIdentifier: gameCenterLeaderBoardId)
        bestScore.value = Int64(score)
        GKScore.report([bestScore]) { (error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            else {
                print("Score submitted to Game Center")
            }
        }
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}

