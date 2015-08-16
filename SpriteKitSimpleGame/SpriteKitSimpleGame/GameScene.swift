//Cole Hudson

import AVFoundation
import Parse
import Bolts

var backgroundMusicPlayer: AVAudioPlayer!

func playBackgroundMusic(filename: String)
{
    let url = NSBundle.mainBundle().URLForResource(
        filename, withExtension: nil)
    if (url == nil) {
        println("Could not find file: \(filename)")
        return
    }
    
    var error: NSError? = nil
    backgroundMusicPlayer =
        AVAudioPlayer(contentsOfURL: url, error: &error)
    if backgroundMusicPlayer == nil {
        println("Could not create audio player: \(error!)")
        return
    }
    
    backgroundMusicPlayer.numberOfLoops = -1
    backgroundMusicPlayer.prepareToPlay()
    backgroundMusicPlayer.play()
}

import SpriteKit

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint
{
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Coin   : UInt32 = 0b1
    static let Bill   : UInt32 = 0b1
    static let Player : UInt32 = UInt32.max
    static let Projectile: UInt32 = 0b10
}

struct Layer {
    static let Background: CGFloat = 0
    static let Crocodile: CGFloat = 1
    static let Rope: CGFloat = 1
    static let Prize: CGFloat = 2
    static let Foreground: CGFloat = 3
}

class GameScene: SKScene, SKPhysicsContactDelegate
{
    //viewcontroller
    var viewController: GameViewController?
    
    //score
    var score = 0
    
    let player = SKSpriteNode(imageNamed: "bitplayer.png")
    var monstersDestroyed = 0
    var billsCollected = 0
    var coinsCollected = 0
    let start = NSDate(); // <<<<<<<<<< Start time
    
    //different collider types
    enum ColliderType:UInt32{
        case PLAYER = 1
        case BILL = 2
        case COIN = 3
    }
    
    override func didMoveToView(view: SKView)
    {
        //collision bitmask for player
        player.physicsBody = SKPhysicsBody(rectangleOfSize: player.size)
        player.physicsBody?.dynamic = true
        player.physicsBody?.categoryBitMask = ColliderType.PLAYER.rawValue
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        player.physicsBody?.collisionBitMask = 0
        player.zPosition = Layer.Foreground
        
        //set bg
        let background = SKSpriteNode(imageNamed: "background")
        background.anchorPoint = CGPointMake(0, 1)
        background.position = CGPointMake(0, size.height)
        background.zPosition = Layer.Background
        background.size = CGSize(width: self.view!.bounds.size.width, height:self.view!.bounds.size.height)
        addChild(background)
        
        playBackgroundMusic("background-music-aac.caf")
        
        backgroundColor = SKColor.whiteColor()
        player.position = CGPoint(x: size.width/2, y: player.size.height)
        addChild(player)
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        /*
        addCoin()
        addBill()
        */
        
        //add coins
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addCoin),
                SKAction.waitForDuration(13.0)
                ])
            ))
        
        //add bills
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addBill),
                SKAction.waitForDuration(3.0)
                ])
            ))
        
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(#min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    //get time elapsed
    func evaluateProblem() -> Double
    {
        
        let end = NSDate();   // <<<<<<<<<<   end time
        
        let timeInterval: Double = end.timeIntervalSinceDate(start); // <<<<< Difference in seconds (double)
        return timeInterval
    }
    
    func highScoreChecker() -> Bool
    {
        println("Score: \(self.score)")
        
        //check to see if you got the hi-score
        var query = PFQuery(className: "HighScore")
        var highScoreQueryObject = query.getFirstObject()
        let highScore = highScoreQueryObject?.objectForKey("score") as! Int
        
        //check if your score is higher than the high score
        if(self.score > highScore)
        {
            println("you have the high score")
            
            //get the user's wallet address from nsuserdefaults
            let defaults = NSUserDefaults.standardUserDefaults()
            if let address = defaults.stringForKey("address")
            {
                //save the new high score
                if let highScoreQueryObject = highScoreQueryObject{
                    highScoreQueryObject["score"] = self.score
                    highScoreQueryObject["address"] = address
                    highScoreQueryObject.saveInBackground()
                }
            }
            return true
        }
        
        return false
    }
    
    
    
    func addCoin()
    {
        // Create sprite
        let coin = SKSpriteNode(imageNamed: "Coin_Sprite")
        coin.physicsBody = SKPhysicsBody(rectangleOfSize: coin.size)
        coin.physicsBody?.dynamic = true
        coin.physicsBody?.categoryBitMask = ColliderType.COIN.rawValue
        coin.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        coin.physicsBody?.collisionBitMask = 0
        coin.zPosition = Layer.Foreground
        
        // Determine where to spawn the monster along the X axis
        let actualX = random(min: coin.size.width/2, max: size.width - (coin.size.width/2))
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        coin.position = CGPoint(x: actualX, y: size.height + coin.size.height/2)
        
        // Add the monster to the scene
        addChild(coin)
        
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(8.0), max: CGFloat(20.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: actualX, y: 0 - coin.size.height), duration: NSTimeInterval(actualDuration))
        
        let actionMoveDone = SKAction.removeFromParent()
        
        let loseAction = SKAction.runBlock()
            {
                let didGetHighScore = self.highScoreChecker()
                let reveal = SKTransition.fadeWithDuration(0.5)
                let gameOverScene = GameOverScene(size: self.size, won: didGetHighScore)
                gameOverScene.viewController = self.viewController
                self.view?.presentScene(gameOverScene, transition: reveal)
        }
        coin.runAction(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
        
    }
    
    func addBill()
    {
        // Create sprite
        let bill = SKSpriteNode(imageNamed: "Bill_Sprite")
        bill.physicsBody = SKPhysicsBody(rectangleOfSize: bill.size)
        bill.physicsBody?.dynamic = true
        bill.physicsBody?.categoryBitMask = ColliderType.BILL.rawValue
        bill.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        bill.physicsBody?.collisionBitMask = 0
        bill.zPosition = Layer.Foreground
        
        // Determine where to spawn the monster along the X axis
        let actualX = random(min: bill.size.width/2, max: size.width - (bill.size.width/2))
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        bill.position = CGPoint(x: actualX, y: size.height + bill.size.height/2)
        
        // Add the monster to the scene
        addChild(bill)
        
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(8.0), max: CGFloat(20.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: actualX, y: 0 - bill.size.height), duration: NSTimeInterval(actualDuration))
        
        let actionMoveDone = SKAction.removeFromParent()
        
        let loseAction = SKAction.runBlock()
            {
                let didGetHighScore = self.highScoreChecker()
                let reveal = SKTransition.fadeWithDuration(0.5)
                let gameOverScene = GameOverScene(size: self.size, won: didGetHighScore)
                gameOverScene.viewController = self.viewController
                self.view?.presentScene(gameOverScene, transition: reveal)
        }
        bill.runAction(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
        
    }
    
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        
        runAction(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
        
        // 1 - Choose one of the touches to work with
        let touch = touches.first as! UITouch
        let touchLocation = touch.locationInNode(self)
        
        var targetPoint = CGPoint(x: touchLocation.x, y: player.position.y)
        
        //calculate the time it takes to move that distance
        var horizontalDistance = abs(touchLocation.x - player.position.x)
        var multiplier = horizontalDistance / 100.0
        var actualDuration:NSTimeInterval = NSTimeInterval(multiplier)
        var actionMove = SKAction.moveTo(targetPoint, duration: actualDuration)
        player.runAction(actionMove)
        
    }
    
    func projectileDidCollideWithMonster(projectile:SKSpriteNode, monster:SKSpriteNode)
    {
        println("Hit")
        projectile.removeFromParent()
        monster.removeFromParent()
        
        monstersDestroyed++
        if (monstersDestroyed > 30) {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size, won: true)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        
    }
    
    //got a coin
    func collectedCoin(coin: SKPhysicsBody)
    {
        println("Got Coin")
        coin.node?.removeFromParent()
        
        coinsCollected++
        score += 5
        println("Coins: \(coinsCollected)")
    }
    
    //got a bill
    func collectedBill(bill: SKPhysicsBody)
    {
        println("Got Bill")
        bill.node?.removeFromParent()
        
        billsCollected++
        score++
        println("Bills: \(billsCollected)")
    }
    
    func didBeginContact(contact: SKPhysicsContact)
    {
        print("contact")
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask
        {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else
        {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        //category
        println("first body \(firstBody.categoryBitMask)")
        println("second body \(secondBody.categoryBitMask)")
        
        var category = secondBody.categoryBitMask
        
        //bill
        if(category == 2)
        {
            // 2
            if ((firstBody.categoryBitMask & PhysicsCategory.Bill != 0) &&
                (secondBody.categoryBitMask & PhysicsCategory.Player != 0))
            {
                print("bill")
                collectedBill(secondBody)
                //projectileDidCollideWithMonster(firstBody.node as! SKSpriteNode, monster: secondBody.node as! SKSpriteNode)
            }
        }
            //coin
        else if(category == 3)
        {
            if ((firstBody.categoryBitMask & PhysicsCategory.Bill != 0) &&
                (secondBody.categoryBitMask & PhysicsCategory.Player != 0))
            {
                print("coin")
                collectedCoin(secondBody)
                //projectileDidCollideWithMonster(firstBody.node as! SKSpriteNode, monster: secondBody.node as! SKSpriteNode)
            }
        }
        
    }
    
}
