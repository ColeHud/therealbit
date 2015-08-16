//
//  PaymentHandlerViewController.swift
//  
//
//  Created by Cole on 8/15/15.
//
//

import UIKit

class PaymentHandlerViewController: UIViewController
{
    //views
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var emailAndAddress: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var loginAndSignup: UIButton!
    @IBOutlet var twentyFiveCentButton: UIButton!
    
    //dismiss the keyboard
    func dismissKeyboard()
    {
        print("\nDismissing keyboard")
        passwordField.resignFirstResponder()
        emailAndAddress.resignFirstResponder()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //set up keyboard dismiss
        var touchDismiss: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        touchDismiss.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(touchDismiss)
        
    }
}
