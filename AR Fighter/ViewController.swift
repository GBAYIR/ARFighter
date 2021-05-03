//
//  ViewController.swift
//  AR Fighter
//
//  Created by Gokhan Bayir on 1.02.2021.
//

import UIKit
import SceneKit
import ARKit
import SpriteKit
//import GoogleMobileAds

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {
   
    
     //var RewardBasedVideo = GADRewardedAd()
    
    var gameCanStartBool:Bool = false
    var gameRestartBool:Bool = false
    
    var playerNode : SCNNode!
    var EnemyManNode: SCNNode!
    var levelNum:Int = 1
    var gameSecond:Int = 10
    var createManNum:Int!
    var createWomanNum:Int!
    var howManyEnemy:Int = 0
    
    var ManPositionZ:Float!
    var WomanPositionZ:Float!
    
    var ManPositionX:Float!
    var WomanPositionX:Float!
    
    var ManPositionY:Float!
    var WomanPositionY:Float!
    
    
    var ManPrePositionZ:Float = 0
    var WomanPrePositionZ:Float = 0
    
    var ManPrePositionY:Float = 0
    var WomanPrePositionY:Float = 0
    
    var randomMove:Float = 0
    
    var gameScore:Int = 0
    
    enum GameState {
        case inGame
        case afterGame
        case preGame
    }
    var currentGameState = GameState.preGame
    
    
    let gameParameter = GameParameter.sharedInstance
    
    
    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var PlayOverLbl: UILabel!
    
    @IBOutlet weak var ScoreLabel: UILabel!
    
    @IBOutlet weak var countDownLbl: UILabel!
    
    let explosionSound = SCNAction.playAudio(SCNAudioSource(fileNamed: "explosion.mp3")!, waitForCompletion: false)
    
    private var userScore: Int = 0 {
        didSet {
            // ensure UI update runs on main thread
            DispatchQueue.main.async {
                self.ScoreLabel.text = String(self.userScore)
            }
        }
    }
    
   
    
    var counter:Int = 0
    @objc func updateCounter() {
        
        if counter > 0 {
            self.countDownLbl.text = "\(counter)"
            counter -= 1
        }
        else if currentGameState == GameState.inGame{
            self.countDownLbl.text = "0"
            self.gameOver()
        }
    }
    
    
    
    func randomMoveDuration(start: Float, end: Float)  { // random float between upper and lower bound (inclusive)
        randomMove =  Float.random(in: start..<end)
    }
    
    func randomManX()  { // random float between upper and lower bound (inclusive)
        ManPositionX = Float.random(in: -10..<10)
    }
    func randomWomenX()  { // random float between upper and lower bound (inclusive)
        WomanPositionX = Float.random(in: -10..<10)
    }
    
    
    func randomManZ()  { // random float between upper and lower bound (inclusive)
        ManPositionZ = -Float.random(in: -10..<10)
 
    }
    func randomWomenZ()  { // random float between upper and lower bound (inclusive)
        WomanPositionZ = -Float.random(in: -10..<10)
    }
    
    func randomManY(PrePosition: Float)  { // random float between upper and lower bound (inclusive)
        ManPositionY = -Float.random(in: 0..<1) - PrePosition
        ManPrePositionY = ManPositionY
    }
    func randomWomenY(PrePosition: Float)  { // random float between upper and lower bound (inclusive)
        WomanPositionY = -Float.random(in: 0..<1) - PrePosition
        WomanPrePositionY = WomanPositionY
    }
    
    
    func movingPositionRandom() -> Float {
         return Float.random(in: -5..<5)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = self
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        
        // Create a new scene
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
          
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateCounter), userInfo: nil, repeats: true)
        })
        
        // Set the scene to the view
        //sceneView.scene = scene
        
        
        
        /*let bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait) //kGADAdSizeBanner)

        addBannerViewToView(bannerView)
        bannerView.adUnitID = "ca-app-pub-5788813335152426/6184088604"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())*/
        
    }
    
    
    // MARK: - Google AdMob
    /*func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        if #available(iOS 11.0, *) {
            view.addConstraints(
                [NSLayoutConstraint(item: bannerView,
                                    attribute: .bottomMargin,
                                    relatedBy: .equal,
                                    toItem: view.safeAreaLayoutGuide,
                                    attribute: .bottomMargin,
                                    multiplier: 1,
                                    constant: 0),
                 NSLayoutConstraint(item: bannerView,
                                    attribute: .centerX,
                                    relatedBy: .equal,
                                    toItem: view,
                                    attribute: .centerX,
                                    multiplier: 1,
                                    constant: 0)
                 
                ])
        } else {
            // Fallback on earlier versions
        }
    }*/
    
    /*override func viewWillLayoutSubviews() {

        
        NotificationCenter.default.addObserver(self, selector: #selector(self.startVideo), name: NSNotification.Name(rawValue: "showvideo"), object: nil)

    }
    
    @objc func startVideo() {
        RewardBasedVideo.delegate = self
        RewardBasedVideo.load(GADRequest(), withAdUnitID: "ca-app-pub-3940256099942544/1712485313")
        rewardBasedVideoAdDidReceive(RewardBasedVideo)
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {
        RewardBasedVideo.present(fromRootViewController: self)
    }
    func rewardBasedVideoAdDidReceive(_ ad:GADRewardBasedVideoAd) {
        RewardBasedVideo.present(fromRootViewController: self)
    }
    func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        gameRestartBool = true
    }*/
    
    
    
    // MARK: - SessionConfig
    func configureSession() {
        if ARWorldTrackingConfiguration.isSupported { // checks if user's device supports the more precise ARWorldTrackingSessionConfiguration
            // equivalent to `if utsname().hasAtLeastA9()`
            // Create a session configuration
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            
            // Run the view's session
            sceneView.session.delegate = self
            sceneView.session.run(configuration)
        } else {
            // slightly less immersive AR experience due to lower end processor
            let configuration = ARWorldTrackingConfiguration()
            // Run the view's session
            sceneView.session.run(configuration)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       configureSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    // MARK: - Node Related
    
    func addPlayer() {
        let newPlayerNode = Player()
        newPlayerNode.position = self.getCameraPosition()
        sceneView.scene.rootNode.addChildNode(newPlayerNode)
        self.playerNode = newPlayerNode
    }
    
    func createEnemyMan() {
        if currentGameState == GameState.inGame {
        
            let enemyMan = SCNScene(named: "art.scnassets/SlenderMan_Model.scn")!
            if let ManNode = enemyMan.rootNode.childNode(withName: "Slenderman", recursively: true) {
            ManNode.position = SCNVector3(ManPositionX, ManPositionY, ManPositionZ)
            ManNode.physicsBody?.isAffectedByGravity = false
            let shape = SCNPhysicsShape(node: ManNode, options: nil)
           
            ManNode.physicsBody = SCNPhysicsBody(type: .static, shape: shape)
            ManNode.physicsBody?.categoryBitMask = PhysicsCategories.EnemyMan
            ManNode.physicsBody?.contactTestBitMask = PhysicsCategories.Bullet
            ManNode.physicsBody?.collisionBitMask = PhysicsCategories.None
            
           
            sceneView.scene.rootNode.addChildNode(ManNode)
                
                
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
              
                let moveMan = SCNAction.moveBy(x: CGFloat(self.ManPositionX - self.movingPositionRandom()), y: CGFloat(self.ManPositionY - self.movingPositionRandom()), z: CGFloat(self.ManPositionZ - self.movingPositionRandom()), duration: TimeInterval(self.randomMove))
                let runFor = SCNAction.repeatForever(moveMan)
                let seqMan = SCNAction.sequence([moveMan, runFor])
                ManNode.runAction(seqMan)
           
            })
            EnemyManNode = ManNode
                
            }
           
        }
    }
    
  
    
    func createEnemyWoman() {
        let EnemyWoman = SCNScene(named: "art.scnassets/ShoknWomn.scn")!
        if let   womanNode = EnemyWoman.rootNode.childNode(withName: "Axe", recursively: true) {
        womanNode.position = SCNVector3(WomanPositionX, WomanPositionY, WomanPositionZ)
        let shape = SCNPhysicsShape(node: womanNode, options: nil)
        womanNode.physicsBody = SCNPhysicsBody(type: .static, shape: shape)
        
        womanNode.physicsBody?.categoryBitMask = PhysicsCategories.EnemyWoman
        womanNode.physicsBody?.contactTestBitMask = PhysicsCategories.Bullet
        womanNode.physicsBody?.collisionBitMask = PhysicsCategories.None
        
        sceneView.scene.rootNode.addChildNode(womanNode)
            
            
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
          
            let moveMan = SCNAction.moveBy(x: CGFloat(self.WomanPositionX + self.movingPositionRandom() ), y: CGFloat(self.WomanPositionY + self.movingPositionRandom()), z: CGFloat(self.WomanPositionZ + self.movingPositionRandom()), duration: TimeInterval(self.randomMove))
            let runFor = SCNAction.repeatForever(moveMan)
            let seqMan = SCNAction.sequence([moveMan, runFor])
            womanNode.runAction(seqMan)
        })
        }
        self.howManyEnemy += 1
    }
    
    
    func fireBullet() {
        //let bullet = SCNScene(named: "art.scnassets/bullet.scn")!
        
        //if let bulletNode = bullet.rootNode.childNode(withName: "Boole", recursively: true){
        if currentGameState == GameState.inGame {
        
            let bulletNode = Bullet()
            
            let (direction, position) = self.getUserVector()
            bulletNode.position = position // SceneKit/AR coordinates are in meters
            let bulletDirection = direction
            
            let impulseVector = SCNVector3(
                x: bulletDirection.x * Float(20),
                y: bulletDirection.y * Float(20),
                z: bulletDirection.z * Float(20)
            )
            
            bulletNode.physicsBody?.applyForce(impulseVector, asImpulse: true)
            sceneView.scene.rootNode.addChildNode(bulletNode)
         
            //G.BAYIR play firebullet sound
            let audioNode = SCNNode()
        
            //let explosionSound = SCNAction.playAudio(SCNAudioSource(fileNamed: "explosion.mp3")!, waitForCompletion: false)
          
            let audioSource = SCNAudioSource(fileNamed: "explosion.mp3")!
        
            audioSource.volume = 1
            audioSource.isPositional = false
            audioSource.load()
            sceneView.scene.rootNode.addChildNode(audioNode)
            audioNode.runAction(SCNAction.playAudio(audioSource, waitForCompletion: false))
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                // remove node
                audioNode.removeAllActions()
            })
        
            //3 seconds after shooting the bullet, remove the bullet node
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                // remove node
                bulletNode.removeFromParentNode()
            })
            
        }
        
    }
    
    func startNewLevel() {
        randomManX()
        randomWomenX()
        randomManY(PrePosition: ManPrePositionY)
        randomWomenY(PrePosition: WomanPrePositionY)
        randomManZ()
        randomWomenZ()
        
        if gameScore == 0{
        randomMoveDuration(start: 2, end: 3)
        }
        if gameScore == 5 {
        randomMoveDuration(start: 2, end: 3)
        }
        if gameScore == 7 {
        randomMoveDuration(start: 2, end: 3)
        }
        if gameScore == 9 {
        randomMoveDuration(start: 1, end: 2)
        }
        if gameScore == 11 {
        randomMoveDuration(start: 0, end: 1)
        }
        if gameScore == 15 {
        randomMoveDuration(start: 0, end: 1)
        }
        if gameScore > 15 {
        randomMoveDuration(start: 0, end: 1)
        }
        
    }
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if currentGameState == GameState.preGame || currentGameState == GameState.afterGame {
           // self.viewWillAppear(true)
            currentGameState = GameState.inGame
            PlayOverLbl.text = ""
            startNewLevel()
            createEnemyMan()
            counter = 10
            

            
        }
        else {
            fireBullet()
        }
    }

    
    
    // MARK: - Vector Related
   /* func getTargetVector(for target: enemyMan?) -> (SCNVector3, SCNVector3) { // (direction, position)
        guard let target = target else {return (SCNVector3Zero, SCNVector3Zero)}
        
        let mat = target.presentation.transform // 4x4 transform matrix describing target node in world space
        let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33) // orientation of target node in world space
        let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of target node world space

        return (dir, pos)
    }*/
    
    func getUserVector() -> (SCNVector3, SCNVector3) { // (direction, position)
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33) // orientation of camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
            
            return (dir, pos)
        }
        return (SCNVector3Zero, SCNVector3Zero)
    }
    
    func getCameraVector() -> (SCNVector3, SCNVector3)  { // (direction, position)
        
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            let dir = SCNVector3(mat.m31, mat.m32, mat.m33) // orientation of camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
            
            return (dir, pos)
        }
        return (SCNVector3Zero, SCNVector3Zero)
    }
    
    func getCameraPosition() -> SCNVector3 {
        let (_ , position) = self.getCameraVector()
        return position
    }
    
    func floatBetween(_ first: Float,  and second: Float) -> Float { // random float between upper and lower bound (inclusive)
        return (Float(arc4random()) / Float(UInt32.max)) * (first - second) + second
    }
    
    func randomOneOfTwoInputFloats(_ first: Float, and second: Float) -> Float {
        let array = [first, second]
        let randomIndex = Int(arc4random_uniform(UInt32(array.count)))
        
        return array[randomIndex]
    }
    
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        var body1 = SCNNode()
        var body2 = SCNNode()
        
        if contact.nodeA.categoryBitMask < contact.nodeB.categoryBitMask {
            body1 = contact.nodeA
            body2 = contact.nodeB
        }
        else {
            body1 = contact.nodeB
            body2 = contact.nodeA
        }
        
        if (body2.physicsBody?.categoryBitMask == PhysicsCategories.EnemyMan && body1.physicsBody?.categoryBitMask == PhysicsCategories.Bullet) {
            body2.removeAllActions()
            body2.removeFromParentNode()
            body1.removeFromParentNode()
            userScore += 1
            
            randomManX()
            randomManY(PrePosition: ManPrePositionY)
            randomManZ()
     
            createEnemyMan()
            
            counter = 10
        }
        if (body2.physicsBody?.categoryBitMask == PhysicsCategories.EnemyWoman && body1.physicsBody?.categoryBitMask == PhysicsCategories.Bullet) {
            body2.removeAllActions()
            body2.removeFromParentNode()
            body1.removeFromParentNode()
            userScore += 1
            self.howManyEnemy -= 1
        
            randomWomenX()
            randomWomenY(PrePosition: WomanPrePositionY)
            randomWomenZ()
            createEnemyWoman()
            counter = 10
        }
       
      
        gameScore += 1
        startNewLevel()
           
    }
    
    func gameOver(){
        if counter == 0 {
            currentGameState = GameState.afterGame
            self.removeFromParent()
            self.EnemyManNode.removeAllActions()
            self.EnemyManNode.removeFromParentNode()
            //self.viewWillDisappear(true)
            PlayOverLbl.text = "GAME OVER"
            gameScore = 0
            userScore = 0
            counter = 0
        }
    }
    
}



// MARK: - ARSessionDelegate
extension ViewController : ARSessionDelegate
{
func session(_ session: ARSession, didUpdate frame: ARFrame) {
    //TODO: See if there's a better way to update player position instead of repositioning it everytime
    //      the camera gets a new frame
    self.playerNode?.position = self.getCameraPosition()
    //self.displayDirectionIndicatorsIfAppropriate()
}
}

// MARK: - SCNSceneRendererDelegate
extension ViewController : SCNSceneRendererDelegate
{
func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {

}
}
