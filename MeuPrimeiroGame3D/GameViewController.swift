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
    
      let cameraNode:SCNNode = {
              // create and add a camera to the scene
          let cameraNode = SCNNode()
          cameraNode.camera = SCNCamera()
              // place the camera
          cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
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
        let torusGeometry = SCNTorus(ringRadius: 3, pipeRadius: 0.3)
        
            // apply a metallic material to the torus
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.metalness.contents = 1
        material.roughness.contents = 0.2
        torusGeometry.materials = [material]
        
            // create a node to hold the torus
        let torusNode = SCNNode(geometry: torusGeometry)
        torusNode.name = "torus"
            // add return the new torus
        return torusNode
    }
      
        // retrieve the SCNView
      lazy var scnView:SCNView = {
          let scnView = self.view as! SCNView
              // allows the user to manipulate the camera
          scnView.allowsCameraControl = true
  
              // show statistics such as fps and timing information
          scnView.showsStatistics = true
  
              // configure the view
          scnView.backgroundColor = UIColor.black
  
              // set the scene to the view
          scnView.scene = scene
          
          return scnView
      }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scene.rootNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(lightNode)
        scene.rootNode.addChildNode(ambientLightNode)
        scene.rootNode.addChildNode(torusNode)

        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
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
