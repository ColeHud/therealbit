//Cole Hudson

import Foundation
import SpriteKit
import UIKit

class GameOverScene: SKScene
{
    var viewController: GameViewController?
    
    func blank()
    {
        
    }
    
  init(size: CGSize, won:Bool)
  {
    super.init(size: size)
    
    
    // 1
    backgroundColor = SKColor.whiteColor()
    
    // 2
    var message = won ? "You hold the HIGH SCORE!!!" : "Try again 😕"
    
    // 3
    let label = SKLabelNode(fontNamed: "Retro Computer_DEMO")
    label.text = message
    label.fontSize = 40
    label.fontColor = SKColor.blackColor()
    label.position = CGPoint(x: size.width/2, y: size.height/2)
    addChild(label)
    
    // 4
    runAction(SKAction.sequence([
      SKAction.waitForDuration(3.0),
      SKAction.runBlock() {
        
        println("attempt to segue")
        self.viewController?.performSegueWithIdentifier("endGame", sender: self.viewController)
      }
    ]))
    
  }

  // 6
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}