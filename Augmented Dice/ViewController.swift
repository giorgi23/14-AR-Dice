//
//  ViewController.swift
//  Augmented Dice
//
//  Created by Giorgi Jashiashvili on 5/3/20.
//  Copyright © 2020 Giorgi Jashiashvili. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var diceArray = [SCNNode]()
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.autoenablesDefaultLighting = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    
    func rollAll() {
        
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice)
            }
        }
        
    }
    
    func roll(_ dice: SCNNode) {
        let randomX = Float(Int.random(in: 1...4)) * (Float.pi/2)
        let randomZ = Float(Int.random(in: 1...4)) * (Float.pi/2)
        
        dice.runAction(
        SCNAction.rotateBy(
            x: CGFloat(randomX * 5),
            y: 0,
            z: CGFloat(randomZ * 5),
            duration: 0.5)
        )
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)

            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first {
                // Create a new scene
                
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
                
                if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
                    
                    diceNode.position = SCNVector3(
                        hitResult.worldTransform.columns.3.x,
                        hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                        hitResult.worldTransform.columns.3.z)
                    
                    diceArray.append(diceNode)
        
                    sceneView.scene.rootNode.addChildNode(diceNode)
                    
                    roll(diceNode)
                    
                }
            }
        }
    }
    
    //MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            print("plane detected")
            let planeAnchor = anchor as! ARPlaneAnchor
            
            let plane  = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIColor.clear
            //gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            plane.materials = [gridMaterial]
            
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(x: planeAnchor.extent.x, y: 0, z: planeAnchor.extent.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            planeNode.geometry = plane
            
            node.addChildNode(planeNode)
        } else {
            return
        }
    }

}
