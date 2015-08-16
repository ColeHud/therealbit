//
//  PaymentHandlerViewController.swift
//  
//
//  Created by Cole on 8/15/15.
//
//

import UIKit

//string length
extension String {
    var length: Int { return count(self)         }  // Swift 1.2
}

class PaymentHandlerViewController: UIViewController
{
    //views
    @IBOutlet var backButton: UIButton!
    @IBOutlet var emailAndAddress: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var loginAndSignup: UIButton!
    @IBOutlet var twentyFiveCentButton: UIButton!
    var selectedSegment = 0
    
    //variables
    var guid = ""
    var address = ""
    var email = ""
    var password = ""
    var link = ""
    
    var bitcoinInTwentyFiveCents = 0.0
    var userHasEnoughMoney = false
    
    //dismiss the keyboard
    func dismissKeyboard()
    {
        print("\nDismissing keyboard")
        passwordField.resignFirstResponder()
        emailAndAddress.resignFirstResponder()
    }
    
    //check if the values are stored and alert the user
    func valuesStored()
    {
        //get the values from NSUserdefaults
        let defaults = NSUserDefaults.standardUserDefaults()
        if let myGuid = defaults.stringForKey("guid")
        {
            guid = myGuid
            if let myAddress = defaults.stringForKey("address")
            {
                address = myAddress
                if let myEmail = defaults.stringForKey("email")
                {
                    email = myEmail
                    if let myPassword = defaults.stringForKey("password")
                    {
                        password = myPassword
                        if let myLink = defaults.stringForKey("link")
                        {
                            link = myLink
                            
                            var alert = UIAlertView(title: "Congrats!", message: "You're all logged in", delegate: nil, cancelButtonTitle: "😀")
                            
                            // Move to the UI thread
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                // Show the alert
                                alert.show()
                            })
                            
                        }
                    }
                }
            }
        }

    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //get the number of bitcoin in a quarter
        self.twentyFiveCentsInBitcoin()
        
        //set up keyboard dismiss
        var touchDismiss: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        touchDismiss.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(touchDismiss)
        
        //set up the back button
        backButton.backgroundColor = UIColor.whiteColor()
        backButton.layer.cornerRadius = 5
        backButton.layer.borderWidth = 1
        backButton.layer.borderColor = UIColor.blackColor().CGColor
        
        self.valuesStored()
        
        //does the user have enough???
        doesUserHaveEnoughMoneyToPlayGame()
        
    }

    
    //create an account
    @IBAction func loginAndSignup(sender: AnyObject)
    {
        if(selectedSegment == 0)//Create a new wallet
        {
            //get
            println("Stuff")
            let url = NSURL(string:"https://blockchain.info/api/v2/create_wallet?password=\(passwordField.text)&api_code=dbcaa55e-9fa1-48e1-aa9d-4d28814ceda8&email=\(emailAndAddress.text)")!
            
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
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(guid, forKey: "guid")
                defaults.setObject(address, forKey: "address")
                defaults.setObject(link, forKey: "link")
                defaults.setObject(self.passwordField.text, forKey: "password")
                defaults.setObject(self.emailAndAddress.text, forKey: "email")
                
                //open the link to your account
                var myURL = NSURL(string: link as! String)
                UIApplication.sharedApplication().openURL(myURL!)
                
            }
            
            task.resume()
        }
        self.valuesStored()
    }
    
    //25 cents converted to bitcoin
    func twentyFiveCentsInBitcoin()
    {
        let url = NSURL(string: "https://blockchain.info/tobtc?currency=USD&value=.25&api_code=dbcaa55e-9fa1-48e1-aa9d-4d28814ceda8")!
        let request = NSMutableURLRequest(URL: url)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data: NSData!, response: NSURLResponse!, error: NSError!) in
            
            if error != nil {
                // Handle error...
                println(error)
                return
            }
            
            //println(response)
            var stringy = NSString(data: data, encoding: NSUTF8StringEncoding)
            println(stringy)
            self.bitcoinInTwentyFiveCents = stringy!.doubleValue
        }
        task.resume()
    }
    
    //is the user's balance greater than 25 cents?
    func doesUserHaveEnoughMoneyToPlayGame()
    {
        //check and see if the user has any funds
        let url = NSURL(string: "https://blockchain.info/merchant/\(guid)/balance?password=\(password)&api_code=dbcaa55e-9fa1-48e1-aa9d-4d28814ceda8")!
        let request = NSMutableURLRequest(URL: url)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data: NSData!, response: NSURLResponse!, error: NSError!) in
            
            if error != nil {
                // Handle error...
                return
            }
            
            //println(error)
            //println(response)
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            
            var error = NSErrorPointer()
            var json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: error)
            
            let balance = json!.objectForKey("balance") as! Double
            
            println("balance: \(balance/100000000), 25 cents = \(self.bitcoinInTwentyFiveCents)")
            if(balance/100000000 > self.bitcoinInTwentyFiveCents)
            {
                println("User has enough money to play a game")
                self.userHasEnoughMoney = true
            }
        }
        
        task.resume()
    }
    
    
    //pay 25 cents and start the game
    @IBAction func payTwentyFiveCents(sender: AnyObject)
    {
        doesUserHaveEnoughMoneyToPlayGame()
        //the user hasn't signed in yet
        if(self.guid == "" || guid.length < 2)
        {
            //alert the user
            var alert = UIAlertView(title: "Sign in", message: "You need to sign in before you can play", delegate: nil, cancelButtonTitle: "ok")
            
            // Move to the UI thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // Show the alert
                alert.show()
            })

        }
        else
        {
            
            
            if(self.userHasEnoughMoney == false)
            {
                //alert the user
                var alert = UIAlertView(title: "$$$", message: "You don't have enough money to play", delegate: nil, cancelButtonTitle: "ok")
                
                // Move to the UI thread
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    // Show the alert
                    alert.show()
                })
            }
            else
            {
                println("else statement")
                let theAccountOfColeHudson = "1NuL6cSsndGRCEk9dijAa9v7ysqo4qQax5"
                let amount:Int = Int(self.bitcoinInTwentyFiveCents * 100000000)
                
                let url = NSURL(string: "https://blockchain.info/merchant/\(guid)/payment?password=\(password)&address=\(theAccountOfColeHudson)&amount=\(amount)&from=\(address)&fee=10000&api_code=dbcaa55e-9fa1-48e1-aa9d-4d28814ceda8")!
                let request = NSMutableURLRequest(URL: url)
                
                let session = NSURLSession.sharedSession()
                let task = session.dataTaskWithRequest(request) { (data: NSData!, response: NSURLResponse!, error: NSError!) in
                    
                    if error != nil {
                        // Handle error...
                        var alert = UIAlertView(title: "Error", message: "Something went wrong", delegate: nil, cancelButtonTitle: "ok")
                        
                        // Move to the UI thread
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            // Show the alert
                            alert.show()
                        })
                        return
                    }
                    
                    
                    println(response)
                    //println(NSString(data: data, encoding: NSUTF8StringEncoding))
                }
                
                task.resume()
                performSegueWithIdentifier("gameOn", sender: self)
            }
            

        }
        
        
    }
    
}
