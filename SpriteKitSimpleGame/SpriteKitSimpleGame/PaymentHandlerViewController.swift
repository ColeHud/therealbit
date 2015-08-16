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
    @IBOutlet var backButton: UIButton!
    @IBOutlet var emailAndAddress: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var loginAndSignup: UIButton!
    @IBOutlet var twentyFiveCentButton: UIButton!
    var selectedSegment = 0
    
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
        
        //set up the back button
        backButton.backgroundColor = UIColor.whiteColor()
        backButton.layer.cornerRadius = 5
        backButton.layer.borderWidth = 1
        backButton.layer.borderColor = UIColor.blackColor().CGColor
        
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
    
    //create an account
    @IBAction func loginAndSignup(sender: AnyObject)
    {
        if(selectedSegment == 0)//Create a new wallet
        {
            //get
            println("Stuff")
            let url = NSURL(string:"https://blockchain.info/api/v2/create_wallet?password=\(passwordField.text)%21&api_code=dbcaa55e-9fa1-48e1-aa9d-4d28814ceda8&email=\(emailAndAddress.text)")!
            
            let request = NSMutableURLRequest(URL: url)
            
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) { (data: NSData!, response: NSURLResponse!, error: NSError!) in
                
                if error != nil
                {
                    // Handle error...
                    println("yeah, there was an error")
                    println(error)
                    println(response)
                    println(NSString(data: data, encoding: NSUTF8StringEncoding))
                    
                    //alert the user
                    var alert = UIAlertView(title: "Error", message: "Sorry, something is wrong", delegate: nil, cancelButtonTitle: "ok")
                    
                    // Move to the UI thread
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        // Show the alert
                        alert.show()
                    })

                    return
                }
                //println(response)
                println(NSString(data: data, encoding: NSUTF8StringEncoding))
                var error = NSErrorPointer()
                var json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: error)
                
                //values returned by server
                var guid = json!.objectForKey("guid")
                var address = json!.objectForKey("address")
                var link = json!.objectForKey("link")
                
                //save to nsUserdefaults
                
                
            }
            
            task.resume()
        }
    }
    
    //pay 25 cents and start the game
    @IBAction func payTwentyFiveCents(sender: AnyObject)
    {
        
        
    }
    
}
