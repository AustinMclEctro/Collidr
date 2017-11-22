//
//  InfoPanel.swift
//  IncrementalGame
//
//  Created by Ben Grande on 2017-10-05.
//  Copyright © 2017 Ben Grande. All rights reserved.
//

import Foundation
import UIKit


/// The view at the top of the game screen that is used to display information
/// related to the game including the game logo and the user's current score.
class InfoPanel: UIView {
    
    var curABar: ProgressBar;
    var logo: UIImageView;
    var inactiveRateLabel: UILabel;
    //var currentShapes: CurrentShapes;
    //var progressStore: ProgressStore

    var feedbackGenerator = UIImpactFeedbackGenerator();
    override init(frame: CGRect) {
        let height = min(frame.height, 50.0)
        let navButtonsHeight: CGFloat = 20.0
        // Configure currency label
        var progressBarFrame = CGRect(x: 30, y: 30, width: height, height: height);
        // TODO - remove menu buttons too?
        let roomLeft = min(frame.height-height-navButtonsHeight, frame.width);
        // TODO: remove if successful - had the progress bar in the left corner
        //if (roomLeft > 100) {
        progressBarFrame = CGRect(x: (frame.width/2)-((roomLeft-20)/2), y: height+10, width: roomLeft-20, height: roomLeft-20)
        //}
        curABar = ProgressBar(frame: progressBarFrame)
        curABar.valLabel.textColor = .white;
        
        // Configure logo
        let logoWidth = (183/77)*height
        logo = UIImageView(frame: CGRect(x: (frame.width/2)-(logoWidth/2), y: 10, width: logoWidth, height: height))
        logo.image = UIImage(named: "colidr");
        
        // Configure passive rate label
        inactiveRateLabel = UILabel(frame: progressBarFrame)
        inactiveRateLabel.text = "Passive Rate"  // TODO: Get passive rate
        inactiveRateLabel.textColor = UIColor.white
        inactiveRateLabel.textAlignment = NSTextAlignment.center
        inactiveRateLabel.isHidden = true
        
        
        
        super.init(frame: frame);
        
        self.backgroundColor = .black;
        
        self.addSubview(curABar)
        self.addSubview(inactiveRateLabel);
        self.addSubview(logo)
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
        curABar.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPress)))

    }

    @objc func tap(sender: UITapGestureRecognizer) {
        if !curABar.frame.contains(sender.location(in: self)) {
            return;
        }
        feedbackGenerator.prepare();
        feedbackGenerator.impactOccurred();
        
    }
    
    /// Updates the currency label to a new value.
    ///
    /// - Parameter to: The new currency value.
    func upgradeCurrencyA(to: Int) {
        curABar.currency = to;
    }
    
    
    /// Updates the inactive income rate label
    ///
    /// - Parameter amount: The rate at which inactive income is generated.
    func updateInactiveIncomeRate(rate: Int) {
        inactiveRateLabel.text = "\(rate)/second"
    }
    
    
    /// Callback method that is called when the user presses and holds the
    /// progress bar. Changes the progress bar to display the passive income rate.
    ///
    /// - Parameter sender: <#sender description#>
    @objc func longPress(sender: UITapGestureRecognizer) {
        if (sender.state == UIGestureRecognizerState.began) {
            curABar.isHidden = true
            inactiveRateLabel.isHidden = false
        }
        if (sender.state == UIGestureRecognizerState.ended) {
            curABar.isHidden = false
            inactiveRateLabel.isHidden = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

