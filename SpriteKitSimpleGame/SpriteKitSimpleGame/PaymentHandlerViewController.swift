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
    var selectedSegment = 0
    
    @IBAction func segmentedControlValueChanged(sender: UISegmentedControl)
    {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            println("new wallet")
            selectedSegment = 0
            emailAndAddress.placeholder = "email"
        case 1:
            println("address")
            selectedSegment = 1
            emailAndAddress.placeholder = "bitcoin wallet address"
        default:
            println("new wallet")
            selectedSegment = 0
            emailAndAddress.placeholder = "email"
        }
    }
    
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
    
    //sign up for a new wallet
    func getNewWallet()
    {
        let url = NSURL(string: "https://blockchain.info/api/v2/create_wallet")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = "password=\(passwordField.text)&api_code=47a89220-6b15-4a32-84ec-00h011467145&priv=5Kb8kLf9zgWQnogidDA76MzPL6TsZZY36hWXMssSzNydYXYB9KF&label=Welcome%20to%20My%20Wallet&email=\(emailAndAddress.text)".dataUsingEncoding(NSUTF8StringEncoding);
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data: NSData!, response: NSURLResponse!, error: NSError!) in
            
            if error != nil {
                // Handle error...
                return
            }
            
            println(error)
            println(response)
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
        }
        
        task.resume()
    }
    
    //login or signup depending on the selection
    @IBAction func loginAndSignup(sender: AnyObject)
    {
        if(selectedSegment == 0)//Create a new wallet
        {
            RestHelper.post(["password": passwordField.text, "api_code": RestHelper.apicode, "priv": "5Kb8kLf9zgWQnogidDA76MzPL6TsZZY36hWXMssSzNydYXYB9KF", "label": "Welcome%20to%20My%20Wallet", "email": emailAndAddress.text], url: "https://blockchain.info/api/v2/create_wallet") { (succeeded: Bool, msg: String) -> () in
                if (!succeeded)
                {
                    var alert = UIAlertView(
                        title: "Error",
                        message: msg,
                        delegate: nil,
                        cancelButtonTitle: "Ok"
                    )
                    
                    // Move to the UI thread
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        // Show the alert
                        alert.show()
                    })
                    return
                }
                println("YOURE IN!")
                println(msg)
                
                //set the user defaults
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(self.emailAndAddress.text, forKey: "email")
                defaults.setObject(self.passwordField.text, forKey: "password")
            }
        }
        else//sign in with an existing wallet
        {
            //check to make sure that the address and password match
        }
    }
    
    //pay 25 cents and start the game
    @IBAction func payTwentyFiveCents(sender: AnyObject)
    {
        RestHelper.post(["password": passwordField.text, "api_code": RestHelper.apicode, "priv": "5Kb8kLf9zgWQnogidDA76MzPL6TsZZY36hWXMssSzNydYXYB9KF", "label": "Welcome%20to%20My%20Wallet", "email": emailAndAddress.text], url: "https://blockchain.info/api/v2/create_wallet") { (succeeded: Bool, msg: String) -> () in
            if (!succeeded)
            {
                var alert = UIAlertView(
                    title: "Error",
                    message: msg,
                    delegate: nil,
                    cancelButtonTitle: "Ok"
                )
                
                // Move to the UI thread
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    // Show the alert
                    alert.show()
                })
                return
            }
            println("YOURE IN!")
            println(msg)
            
            //set the user defaults
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(self.emailAndAddress.text, forKey: "email")
            defaults.setObject(self.passwordField.text, forKey: "password")
        }
        
    }
    
}
