//
//  GameViewController.swift
//  MeuPrimeiroGame3D
//
//  Created by Ricardo Venieris on 25/01/23.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {

        // create a new scene
    let scene = SCNScene(named: "art.scnassets/ship.scn")!
    
      lazy var cameraNode:SCNNode = {
              // create and add a camera to the scene
          let cameraNode = SCNNode()
          cameraNode.camera = SCNCamera()
              // place the camera
          cameraNode.transform = SCNMatrix4MakeRotation(Float.pi, 0, 1, 0)
          cameraNode.position = SCNVector3(x: 0, y: 4, z: -13)
          
          // increase horizon distance
          cameraNode.camera?.zFar = 2000

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
      lazy var ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
    
      var torusNode:SCNNode {
              // create a 3D torus object
          let torusGeometry = SCNTorus(ringRadius: 7, pipeRadius: 0.75)
  
              // apply a metallic material to the torus
          let material = SCNMaterial()
          material.lightingModel = .physicallyBased
          material.metalness.contents = 1
          material.roughness.contents = 0.2
          torusGeometry.materials = [material]
  
              // create a node to hold the torus
          let torusNode = SCNNode(geometry: torusGeometry)
          torusNode.name = "torus"
          
              // apply a rotation matrix to the torus node
          torusNode.transform = SCNMatrix4MakeRotation(Float.pi/2, 1, 0, 0)
          
              // spawn action
          let wait     = SCNAction.wait(duration: 15)
          let kill     = SCNAction.removeFromParentNode()
          let sequence = SCNAction.sequence([wait, kill])
          torusNode.runAction(sequence)

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
          scnView.allowsCameraControl = true
  
              // show statistics such as fps and timing information
          scnView.showsStatistics = false
  
              // configure the view
          scnView.backgroundColor = UIColor.black
  
              // set the scene to the view
          scnView.scene = scene
          
          return scnView
      }()

    override func viewDidLoad() {
        super.viewDidLoad()
        sleep(2)
        scene.rootNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(lightNode)
        scene.rootNode.addChildNode(ambientLightNode)
        scene.rootNode.addChildNode(torusField)

        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
      func addTorus() {
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
    
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        addTorus()
        
        // retrieve the SCNView
//        let scnView = self.view as! SCNView
//
//        // check what nodes are tapped
//        let p = gestureRecognize.location(in: scnView)
//        let hitResults = scnView.hitTest(p, options: [:])
//        // check that we clicked on at least one object
//        if hitResults.count > 0 {
//            // retrieved the first clicked object
//            let result = hitResults[0]
//
//            // get its material
//            let material = result.node.geometry!.firstMaterial!
//
//            // highlight it
//            SCNTransaction.begin()
//            SCNTransaction.animationDuration = 0.5
//
//            // on completion - unhighlight
//            SCNTransaction.completionBlock = {
//                SCNTransaction.begin()
//                SCNTransaction.animationDuration = 0.5
//
//                material.emission.contents = UIColor.black
//
//                SCNTransaction.commit()
//            }
//
//            material.emission.contents = UIColor.red
//
//            SCNTransaction.commit()
//        }
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
    
    func addMetallicCube(to scene: SCNScene) {
            // create a 3D cube object
        let cubeGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.1)
        
            // apply a metallic material to the cube
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.metalness.contents = 1
        material.roughness.contents = 0.2
        cubeGeometry.materials = [material]
        
            // create a node to hold the cube
        let cubeNode = SCNNode(geometry: cubeGeometry)
        
            // add the cube node to the scene
        scene.rootNode.addChildNode(cubeNode)
    }

    



}
