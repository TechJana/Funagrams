//
//  GameViewController.swift
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 4/4/17.
//  Copyright © 2017 pluggablez. All rights reserved.
//

import UIKit
import FunagramsKit
import GameKit
import GoogleMobileAds

class GameViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet var collectionViewAlphabets: UICollectionView!
    @IBOutlet var lblLevel: UILabel!
    @IBOutlet var lblTimer: UILabel!
    @IBOutlet var lblQuestion: UILabel!
    @IBOutlet var btnScramble: UIButton!
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var btnHint: UIButton!
    @IBOutlet var visualEffectBlurView: UIVisualEffectView!
    @IBOutlet var adBannerView: GADBannerView!
    
    var alphabets: [String] = []
    var blurEffect: UIVisualEffect!
    // drag and drop for UICollectionView
    var longPressGesture: UILongPressGestureRecognizer!
    var panGesture: UIPanGestureRecognizer!
    var draggedCellIndexPath: IndexPath?
    var draggingDelegate: DrapDropCollectionViewDelegate?
    var draggingView: UIView?
    var touchOffsetFromCenterOfCell: CGPoint?
    let pingInterval = 0.3
    var isAutoScrolling = false
    // timer
    var timer = Timer()
    var timerCounter: Int = 0
    // tile size
    let tileSpacing: CGFloat = 5    // should be same as what we have in StoryBoard
    let tileSize = CGSize(width: 50, height: 50)    // should be same as what we have in StoryBoard
    // game data
    public var userSkill: Skill = .none
    public var currentLevel: Level = .Level01
    public var currentGame: Games?
    var maxHintCount: Int = 0
    var hintDisplayedCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // disable the blur effect
        blurEffect = visualEffectBlurView.effect
        visualEffectBlurView.effect = nil
        
//        // enable long press
//        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(GameViewController.handleLongGesture(_:)))
//        self.collectionViewAlphabets.addGestureRecognizer(longPressGesture)
        
        // enable pan gesture
        panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(GameViewController.handlePanGesture(_:)))
        self.collectionViewAlphabets.addGestureRecognizer(panGesture)
        
        //currentLevel = DataManager.getLastIncompleteLevel(skill: userSkill)!
        loadGame(skill: userSkill)
        
        // google ads
        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
        let request = GADRequest()
        #if DEBUG
            request.testDevices = [kGADSimulatorID]
        #endif
        adBannerView.adUnitID = GoogleAdsHelper.readPropertyFromGoogleService(propertyName: GoogleAdsHelper.Properties.Banner)
        adBannerView.rootViewController = self
        adBannerView.adSize = kGADAdSizeSmartBannerLandscape
        adBannerView.load(request)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if currentGame == nil {
            // something terrible happened, so dismiss current view and let user know
            let alertView = UIAlertController(title: "What's going on", message: "Couldn't load the game due to some reason, sorry about that 😞", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "whatever", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                print("OK")
                self.dismiss(animated: true, completion: nil)
            }
            
            alertView.addAction(okAction)

            // animation for pop-bounce effect
            UIView.animate(withDuration: 0.2, animations: {
                self.visualEffectBlurView.effect = self.blurEffect
            })

            present(alertView, animated: true, completion: nil)
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override var prefersStatusBarHidden: Bool {
        return false
    }

    @IBAction func btnHintClick(_ sender: UIButton) {
        showHint()
    }
    
    @IBAction func btnBackClick(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnScrambleClick(_ sender: UIButton) {
        scramble()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        var cellHeight = tileSize.height
        // adjust the view of collection view to have only one row
        // increasing Header Size Height and Footer Size Height should provide this effect
        if let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) {
            cellHeight = cell.frame.size.height
        }
        return (collectionView.frame.size.height - cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return alphabets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellAlphabet", for: indexPath) as! AlphabetCollectionViewCell
        //cell.imageTile.image = alphabets[indexPath.item]
        cell.lblTitle.text = alphabets[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let temp = alphabets.remove(at: sourceIndexPath.item)
        alphabets.insert(temp, at: destinationIndexPath.item)
    }
    
    func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let touchLocation = gesture.location(in: self.collectionViewAlphabets)
        
        switch(gesture.state) {
        case UIGestureRecognizerState.began:
            draggedCellIndexPath = self.collectionViewAlphabets.indexPathForItem(at: touchLocation)
            if (draggedCellIndexPath != nil) {
                draggingDelegate?.dragDropCollectionViewDraggingDidBeginWithCellAtIndexPath?(draggedCellIndexPath!)
                let draggedCell = self.collectionViewAlphabets.cellForItem(at: draggedCellIndexPath! as IndexPath) as UICollectionViewCell!
                draggingView = UIImageView(image: self.collectionViewAlphabets.getRasterizedImageCopyOfCell(draggedCell!))
                draggingView!.center = (draggedCell!.center)
                self.collectionViewAlphabets.addSubview(draggingView!)
                draggedCell!.alpha = 0.0
                touchOffsetFromCenterOfCell = CGPoint(x: draggedCell!.center.x - touchLocation.x, y: draggedCell!.center.y - touchLocation.y)
                UIView.animate(withDuration: 0.4, animations: { () -> Void in
                    self.draggingView!.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                    self.draggingView!.alpha = 0.8
                })
            }
            
        case UIGestureRecognizerState.changed:
            if draggedCellIndexPath != nil {
                draggingView!.center = CGPoint(x: touchLocation.x + touchOffsetFromCenterOfCell!.x, y: touchLocation.y + touchOffsetFromCenterOfCell!.y)
                
                if !isAutoScrolling {
                    
                    Helper.dispatchOnMainQueueAfter(pingInterval, closure: { () -> () in
                        let scroller = self.collectionViewAlphabets.shouldAutoScroll(touchLocation, currentTouchLocation: self.panGesture.location(in: self.collectionViewAlphabets.superview))
                        if  (scroller.shouldScroll) {
                            self.collectionViewAlphabets.autoScroll(scroller.direction, currentLongPressTouchLocation: touchLocation, draggingView: self.draggingView)
                            self.isAutoScrolling = true
                        }
                    })
                }
                
                Helper.dispatchOnMainQueueAfter(pingInterval, closure: { () -> () in
                    let shouldSwapCellsTuple = self.collectionViewAlphabets.shouldSwapCells(touchLocation, currentTouchLocation: self.panGesture.location(in: self.collectionViewAlphabets.superview), draggedCellIndexPath: self.draggedCellIndexPath)
                    if shouldSwapCellsTuple.shouldSwap {
                        self.draggedCellIndexPath = self.collectionViewAlphabets.swapDraggedCellWithCellAtIndexPath(shouldSwapCellsTuple.newIndexPath!, draggedCellIndexPath: self.draggedCellIndexPath, draggingDelegate: self.draggingDelegate)
                    }
                })
            }
            
        case UIGestureRecognizerState.ended:
            if draggedCellIndexPath != nil {
                draggingDelegate?.dragDropCollectionViewDraggingDidEndForCellAtIndexPath?(draggedCellIndexPath!)
                let draggedCell = self.collectionViewAlphabets.cellForItem(at: draggedCellIndexPath! as IndexPath)
                UIView.animate(withDuration: 0.4, animations: { () -> Void in
                    self.draggingView!.transform = CGAffineTransform.identity
                    self.draggingView!.alpha = 1.0
                    if (draggedCell != nil) {
                        self.draggingView!.center = draggedCell!.center
                    }
                }, completion: { (finished) -> Void in
                    self.draggingView!.removeFromSuperview()
                    self.draggingView = nil
                    draggedCell?.alpha = 1.0
                    self.draggedCellIndexPath = nil
                })
            }
            // verify the answer to check if the user resolved the question
            verifyAnswer()
        
        default: ()
        }
    }
    
    func handleLongGesture(_ gesture: UILongPressGestureRecognizer) {
        let touchLocation = gesture.location(in: self.collectionViewAlphabets)
        
        switch(gesture.state) {
            
        case UIGestureRecognizerState.began:
            draggedCellIndexPath = self.collectionViewAlphabets.indexPathForItem(at: touchLocation)
            if (draggedCellIndexPath != nil) {
                draggingDelegate?.dragDropCollectionViewDraggingDidBeginWithCellAtIndexPath?(draggedCellIndexPath!)
                let draggedCell = self.collectionViewAlphabets.cellForItem(at: draggedCellIndexPath! as IndexPath) as UICollectionViewCell!
                draggingView = UIImageView(image: self.collectionViewAlphabets.getRasterizedImageCopyOfCell(draggedCell!))
                draggingView!.center = (draggedCell!.center)
                self.collectionViewAlphabets.addSubview(draggingView!)
                draggedCell!.alpha = 0.0
                touchOffsetFromCenterOfCell = CGPoint(x: draggedCell!.center.x - touchLocation.x, y: draggedCell!.center.y - touchLocation.y)
                UIView.animate(withDuration: 0.4, animations: { () -> Void in
                    self.draggingView!.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                    self.draggingView!.alpha = 0.8
                })
            }
            
        case UIGestureRecognizerState.changed:
            if draggedCellIndexPath != nil {
                draggingView!.center = CGPoint(x: touchLocation.x + touchOffsetFromCenterOfCell!.x, y: touchLocation.y + touchOffsetFromCenterOfCell!.y)
                
                if !isAutoScrolling {
                    
                    Helper.dispatchOnMainQueueAfter(pingInterval, closure: { () -> () in
                        let scroller = self.collectionViewAlphabets.shouldAutoScroll(touchLocation, currentTouchLocation: self.longPressGesture.location(in: self.collectionViewAlphabets.superview))
                        if  (scroller.shouldScroll) {
                            self.collectionViewAlphabets.autoScroll(scroller.direction, currentLongPressTouchLocation: touchLocation, draggingView: self.draggingView)
                            self.isAutoScrolling = true
                        }
                    })
                }
                
                Helper.dispatchOnMainQueueAfter(pingInterval, closure: { () -> () in
                    let shouldSwapCellsTuple = self.collectionViewAlphabets.shouldSwapCells(touchLocation, currentTouchLocation: self.longPressGesture.location(in: self.collectionViewAlphabets.superview), draggedCellIndexPath: self.draggedCellIndexPath)
                    if shouldSwapCellsTuple.shouldSwap {
                        self.draggedCellIndexPath = self.collectionViewAlphabets.swapDraggedCellWithCellAtIndexPath(shouldSwapCellsTuple.newIndexPath!, draggedCellIndexPath: self.draggedCellIndexPath, draggingDelegate: self.draggingDelegate)
                    }
                })
            }
            
        case UIGestureRecognizerState.ended:
            if draggedCellIndexPath != nil {
                draggingDelegate?.dragDropCollectionViewDraggingDidEndForCellAtIndexPath?(draggedCellIndexPath!)
                let draggedCell = self.collectionViewAlphabets.cellForItem(at: draggedCellIndexPath! as IndexPath)
                UIView.animate(withDuration: 0.4, animations: { () -> Void in
                    self.draggingView!.transform = CGAffineTransform.identity
                    self.draggingView!.alpha = 1.0
                    if (draggedCell != nil) {
                        self.draggingView!.center = draggedCell!.center
                    }
                }, completion: { (finished) -> Void in
                    self.draggingView!.removeFromSuperview()
                    self.draggingView = nil
                    draggedCell?.alpha = 1.0
                    self.draggedCellIndexPath = nil
                })
            }
            // verify the answer to check if the user resolved the question
            verifyAnswer()
            
        default: ()
        }
    }
    
    func loadGame(skill: Skill) {
        let maximumTileCount: Int = Int((self.view.frame.width - (tileSize.width + tileSpacing)) / (tileSize.width + tileSpacing))
        currentGame = DataManager.getNextGame(skill: userSkill, anagramMaxLength: maximumTileCount)

        if currentGame == nil {
            // something terrible happened, so dismiss current view and let user know
            return
        }

        let questionLength: Int = (currentGame?.anagram?.questionText?.characters.count)!
        maxHintCount = Int((currentGame?.mode?.hintsPercentile)! * Float(questionLength))
        currentLevel = Level(rawValue: Int(currentGame!.level!.levelId))!
        lblLevel.text = "\(userSkill.description) \(currentLevel.description)"
        lblQuestion.text = currentGame?.anagram?.questionText

        // split question to tiles
        let strippedQuestion: String = (currentGame?.anagram?.questionText?.replacingOccurrences(of: " ", with: ""))!
        alphabets = strippedQuestion.characters.map({ (s) -> String in
            String(s)
        })
        
        // reset timer
        lblTimer.text = "0.00"
        if #available(iOS 10.0, *) {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (thisTimer) in
                self.timerCounter += 1
                self.lblTimer.text = String(format: "%d:%02d", (self.timerCounter / 60), (self.timerCounter % 60))
            })
        } else {
            // Fallback on earlier versions
        }
    }
    
    func getCurrentUserAnswer() -> (answer: String, answerArray: [String]) {
        var currentUserAnswer: String = ""
        for index in 0..<collectionViewAlphabets.numberOfItems(inSection: 0) {
            let cell = collectionViewAlphabets.cellForItem(at: IndexPath(item: index, section: 0)) as! AlphabetCollectionViewCell
            currentUserAnswer += cell.lblTitle.text!
        }
        let tempAlphabets: [String] = currentUserAnswer.characters.map({ (s) -> String in
            String(s)
        })
        
        return (currentUserAnswer, tempAlphabets)
    }
    
    func updateScoreToGameCenter(level: Level, score: Int) {
        let gameScore = GKScore(leaderboardIdentifier: level.LeaderBoard)
        gameScore.value = Int64(score)
        GKScore.report([gameScore]) { (error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            else {
                print("\(level.description) score (\(score)) submitted to Game Center")
            }
        }
    }
    
    func verifyAnswer() {
        let currentUserAnswer: String = getCurrentUserAnswer().answer
        
        let strippedAnswer: String = (currentGame?.anagram?.answerText?.replacingOccurrences(of: " ", with: ""))!
        if strippedAnswer == currentUserAnswer {
            // answer resolved
            
            // stop the timer
            timer.invalidate()
            
            // calculate score
            var score: Int = 0
            score = Int((currentGame?.maxScore)!) + ((1 - (hintDisplayedCount / maxHintCount)) * Int((currentGame?.maxScore)!))
            // update Game Center score board
            updateScoreToGameCenter(level: currentLevel, score: score)
            // update Score in db
            DataManager.updateScore(gameId: (currentGame?.gameId)!, score: Int32(score))
            
            // show alert to progress next level
            let alertView = UIAlertController(title: "You did it!", message: "It's \"\(currentGame!.anagram!.answerText!)\".  Your score is \(score)", preferredStyle: UIAlertControllerStyle.alert)
            
            let nextAction = UIAlertAction(title: "let's keep going", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                print("OK")
//                self.dismiss(animated: true, completion: nil)
                
                // move to next level
                self.hintDisplayedCount = 0
                self.loadGame(skill: self.userSkill)
                self.collectionViewAlphabets.reloadData()
            }
            present(alertView, animated: true, completion: nil)
            
            let backAction = UIAlertAction(title: "am good", style: UIAlertActionStyle.cancel) {
                (result : UIAlertAction) -> Void in
                print("CANCEL")
                self.dismiss(animated: true, completion: nil)
            }
            
            alertView.addAction(nextAction)
            alertView.addAction(backAction)
        }
    }
    
    func scramble() {
        for index in 0..<alphabets.count {
            let newIndex: Int = Int(arc4random_uniform(UInt32(alphabets.count-1)))
            let tempAlphabet: String = alphabets[index]
            alphabets[index] = alphabets[newIndex]
            alphabets[newIndex] = tempAlphabet
        }
        collectionViewAlphabets.reloadData()
        
        // reset the hint display count as the position of the tiles would have jumbled
        hintDisplayedCount = 0
    }
    
    func showHint() {
        if hintDisplayedCount >= maxHintCount {
            return
        }
        
        let userAnswer = getCurrentUserAnswer()
        let currentUserAnswer: String = userAnswer.answer
        let strippedAnswer: String = (currentGame?.anagram?.answerText?.replacingOccurrences(of: " ", with: ""))!
        let answerAlphabets: [String] = strippedAnswer.characters.map({ (s) -> String in
            String(s)
        })
        
        // verify if the answers are not yet resolved
        if currentUserAnswer != strippedAnswer {
            let tempAlphabets: [String] = userAnswer.answerArray
            var unresolvedAlphabetIndices: [Int] = []
            
            // identify all unresolved character positions
            for index in 0..<tempAlphabets.count {
                if answerAlphabets[index] != tempAlphabets[index] {
                    unresolvedAlphabetIndices.append(index)
                }
            }
            
            // randomize to identify the hint index
            let hintIndex: Int = unresolvedAlphabetIndices[Int(arc4random_uniform(UInt32(unresolvedAlphabetIndices.count-1)))]
            var hintSwapIndex: Int = -1
            
            // find the hintIndex character in the unresolved alphabets for a swap
            for index in 0..<unresolvedAlphabetIndices.count {
                if hintIndex != unresolvedAlphabetIndices[index]  &&  answerAlphabets[hintIndex] == tempAlphabets[unresolvedAlphabetIndices[index]] {
                    hintSwapIndex = unresolvedAlphabetIndices[index]
                    break
                }
            }
            
            // swap between hint index and hint's swap index
            if hintIndex == alphabets.count-1 {
                collectionViewAlphabets.moveItem(at: IndexPath(item: hintSwapIndex, section: 0), to: IndexPath(item: alphabets.count-1, section: 0))
                collectionViewAlphabets.moveItem(at: IndexPath(item: hintIndex-1, section: 0), to: IndexPath(item: hintSwapIndex, section: 0))
                }
            else if hintSwapIndex == alphabets.count-1 {
                    collectionViewAlphabets.moveItem(at: IndexPath(item: hintIndex, section: 0), to: IndexPath(item: alphabets.count-1, section: 0))
                    collectionViewAlphabets.moveItem(at: IndexPath(item: hintSwapIndex-1, section: 0), to: IndexPath(item: hintIndex, section: 0))
                }
            else if hintIndex < hintSwapIndex {
                // based on the index positions use the first one to move based on whichever is far
                collectionViewAlphabets.moveItem(at: IndexPath(item: hintSwapIndex, section: 0), to: IndexPath(item: alphabets.count-1, section: 0))
                collectionViewAlphabets.moveItem(at: IndexPath(item: hintIndex, section: 0), to: IndexPath(item: hintSwapIndex-1, section: 0))
                collectionViewAlphabets.moveItem(at: IndexPath(item: alphabets.count-1, section: 0), to: IndexPath(item: hintIndex, section: 0))
            }
            else {
                // based on the index positions use the first one to move based on whichever is far
                collectionViewAlphabets.moveItem(at: IndexPath(item: hintIndex, section: 0), to: IndexPath(item: alphabets.count-1, section: 0))
                collectionViewAlphabets.moveItem(at: IndexPath(item: hintSwapIndex, section: 0), to: IndexPath(item: hintIndex-1, section: 0))
                collectionViewAlphabets.moveItem(at: IndexPath(item: alphabets.count-1, section: 0), to: IndexPath(item: hintSwapIndex, section: 0))
            }
            
            // highlight with animation the hintIndex
            let hintCell = self.collectionViewAlphabets.cellForItem(at: IndexPath(item: hintIndex, section: 0)) as UICollectionViewCell!
            draggingView = UIImageView(image: self.collectionViewAlphabets.getRasterizedImageCopyOfCell(hintCell!))
            draggingView!.center = (hintCell!.center)
            self.collectionViewAlphabets.addSubview(draggingView!)
            hintCell!.alpha = 0.0
            btnHint.isEnabled = false
            UIView.animate(withDuration: 0.4, animations: {() -> Void in
                self.draggingView!.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                self.draggingView!.alpha = 0.8
            }, completion: { (sucess: Bool) in
                UIView.animate(withDuration: 1.0, animations: { () -> Void in
                    self.draggingView!.transform = CGAffineTransform.identity
                    self.draggingView!.alpha = 1.0
                    if (hintCell != nil) {
                        self.draggingView!.center = hintCell!.center
                    }
                }, completion: { (finished) -> Void in
                    self.draggingView!.removeFromSuperview()
                    self.draggingView = nil
                    hintCell?.alpha = 1.0
                    self.draggedCellIndexPath = nil
                    self.btnHint.isEnabled = true
                })
            })
            
            hintDisplayedCount += 1
            
            if hintDisplayedCount >= maxHintCount {
                btnHint.isEnabled = false
            }
            
            // verify if the answer is resolved
            verifyAnswer()
        }
    }
}
