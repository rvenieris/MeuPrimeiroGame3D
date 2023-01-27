    //
    //  GameViewController.swift
    //  MeuPrimeiroGame3D
    //
    //  Created by Ricardo Venieris on 25/01/23.
    //

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController, SCNPhysicsContactDelegate {
    
        // create a new scene
    let scene = SCNScene(named: "art.scnassets/ship.scn")!
    
    lazy var cameraNode:SCNNode = {
            // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
            // place the camera
        let startPosition = SCNVector3(x: 0, y: 4, z: -10)
        cameraNode.transform = SCNMatrix4MakeRotation(Float.pi, 0, 1, 0)
        cameraNode.position = startPosition
        
            // increase horizon distance
        cameraNode.camera?.zFar = 1000
        
            // follow the ship
        let delay = 0.2
        let folowship = SCNAction.run {node in
            var newPosition = self.ship.position
            newPosition.x += startPosition.x
            newPosition.y += startPosition.y
            newPosition.z += startPosition.z
            node.runAction(SCNAction.move(to: newPosition, duration: delay))
        }
        let wait     = SCNAction.wait(duration: delay)
        let sequence = SCNAction.sequence([folowship, wait])
        let repeatSequence = SCNAction.repeatForever(sequence)
        cameraNode.runAction(repeatSequence)
        
        return cameraNode
    }()
    
    let lightNode:SCNNode = {
            // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        return lightNode
        
    }()
    
    let ambientLightNode:SCNNode = {
            // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        return ambientLightNode
    }()
    
        // retrieve the ship node
    var speed:Float = 0
    lazy var ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
        
    var torusNode:SCNNode {
            // create a 3D torus object
        let radius:CGFloat = 7
        let torusGeometry = SCNTorus(ringRadius: radius, pipeRadius: 0.75)
        
            // apply a metallic material to the torus
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.metalness.contents = 1
        material.roughness.contents = 0.2
        torusGeometry.materials = [material]
        
            // create a node to hold the torus
        let torusNode = SCNNode(geometry: torusGeometry)
        torusNode.name = "torus"
        
        let physicsBodyGeometry = SCNBox(width: radius, height: 1, length: radius, chamferRadius: 0)
        let physicsBodyShape    = SCNPhysicsShape(geometry: physicsBodyGeometry)
        let physicsBody         = SCNPhysicsBody(type: .static, shape: physicsBodyShape)
        physicsBody.contactTestBitMask = 2
        torusNode.physicsBody = physicsBody
        
            // apply a rotation matrix to the torus node
        torusNode.transform = SCNMatrix4MakeRotation(Float.pi/2, 1, 0, 0)
        
            // return the new torus
        return torusNode
    }
    
        // A node to hold all torus
    lazy var torusField:SCNNode = {
        let torusField = SCNNode()
        
            // spawn action
        let wait           = SCNAction.wait(duration: 1)
        let spawn          = SCNAction.run {_ in self.addTorus() }
        let sequence       = SCNAction.sequence([wait, spawn])
        let repeatSequence = SCNAction.repeatForever(sequence)
        torusField.runAction(repeatSequence)
        
        return torusField
    }()
    
        // retrieve the SCNView
    lazy var scnView:SCNView = {
        let scnView = self.view as! SCNView
            // allows the user to manipulate the camera
        scnView.allowsCameraControl = false
        
            // show statistics such as fps and timing information
        scnView.showsStatistics = false
//        scnView.debugOptions = [.showPhysicsShapes]
        
            // configure the view
        scnView.backgroundColor = UIColor.black
        
            // set the scene to the view
        scnView.scene = scene
        
        return scnView
    }()
    
    var score:Int = 0 {
        didSet { scoreLabel.geometry = scoreText }
    }
    
    var scoreText:SCNText {
        let material = SCNMaterial ()
        material.diffuse.contents = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        
        let text = SCNText(string: "Score: \(score)", extrusionDepth: 1)
        text.flatness = 0
        text.materials = [material]
        return text
    }
    
    lazy var scoreLabel:SCNNode = {
        let node = SCNNode()
        node.position = SCNVector3(x:-50, y: 20, z:-50)
        node.scale = SCNVector3(x:0.5, y: 0.5, z:0.5)
        node.geometry = scoreText
        return node
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scene.rootNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(lightNode)
        scene.rootNode.addChildNode(ambientLightNode)
        scene.rootNode.addChildNode(torusField)
        
        cameraNode.addChildNode(scoreLabel)
        
        scene.physicsWorld.contactDelegate = self
        
        startShipEngine()
    }
    
    func addTorus() {
        removeOldTorus()
        guard torusField.childNodes.count < 30 else {return}
            // get last torus position
        let lastTorusposition = torusField.childNodes.last?.position ?? SCNVector3(x: 0, y: 0, z: 0)
            // create a new Torus
        let newTorus = torusNode
        
            // generate a displacement distance generated in a "grid way" for left or right
        let randomLR:Float = Float(([-1, 1].randomElement()!) * Int.random(in: 2...5) * 10)
        newTorus.position.x = lastTorusposition.x + randomLR
        
            // generate a displacement distance random generated in a range
        newTorus.position.z = lastTorusposition.z + Float.random(in:  50...80)
        
        torusField.addChildNode(newTorus)
        
    }
    
    func removeOldTorus() {
        for node in torusField.childNodes {
            if node.position.z < cameraNode.position.z {
                node.removeFromParentNode()
            } else {
                return // As nodes are in order, at first viewable node, quit.
            }
        }
    }
    
    func startShipEngine() {
        let runWait     = SCNAction.wait(duration: 0.1)
        let runMove     = SCNAction.run { node in
            node.runAction(SCNAction.moveBy(x: CGFloat(self.speed), y: 0, z: 3, duration: 0.1))
        }
        let runSequence = SCNAction.sequence([runWait, runMove])
        let runRepeat   = SCNAction.repeatForever(runSequence)
        
        let wait          = SCNAction.wait(duration: 2)
        let startSequence = SCNAction.sequence([wait, runRepeat])
        ship.runAction(startSequence)
    }
    
    func updateShipSpeed(for touches: Set<UITouch>) {
        guard let touch = touches.first else {return}
        let location = touch.location(in: scnView)
        self.speed = Float(scnView.frame.midX - location.x) * 0.05 // negative if at leftSide * constant for maximum speed
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateShipSpeed(for: touches)
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateShipSpeed(for: touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            // return to idle
        self.speed = .zero
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        guard let torusNode = [contact.nodeA, contact.nodeB].filter({$0.name == "torus"}).first else {return}
        torusNode.physicsBody = nil
        score += 1
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
}
