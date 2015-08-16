//Cole Hudson

import UIKit
import SpriteKit

class GameViewController: UIViewController
{
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    let scene = GameScene(size: view.bounds.size)
    let skView = view as! SKView
    skView.showsFPS = false
    skView.showsNodeCount = false
    skView.ignoresSiblingOrder = true
    scene.scaleMode = .ResizeFill
    scene.viewController = self
    skView.presentScene(scene)
  }
  
  override func prefersStatusBarHidden() -> Bool
  {
    return true
  }
}
