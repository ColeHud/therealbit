//
//  HighScoreViewController.swift
//  
//
//  Created by Cole on 8/15/15.
//
//

import UIKit
import Parse

class HighScoreViewController: UIViewController
{
    @IBOutlet var backButton: UIButton!
    @IBOutlet var label: UILabel!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //get high score from parse
        var query = PFQuery(className: "HighScore")
        var queryObject = query.getFirstObject()
        let highScore = queryObject?.valueForKey("score") as! Int
        label.text = "\(highScore)"
        
        //set up the back button
        backButton.backgroundColor = UIColor.whiteColor()
        backButton.layer.cornerRadius = 5
        backButton.layer.borderWidth = 1
        backButton.layer.borderColor = UIColor.blackColor().CGColor
    }
}
