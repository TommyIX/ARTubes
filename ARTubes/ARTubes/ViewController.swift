//
//  ViewController.swift
//  ARTubes
//

import UIKit
import ARKit
import SwiftUI

var current_tubemodel = "tube3"

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var Tubes: UIButton!
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBAction func Tubes(_ sender: Any) {
        let alertController = UIAlertController(title: "Change the tube", message: "The new selected tube will be selected able to place on the surface", preferredStyle: .actionSheet)
        for index in 1...3{
            let tubeaction = UIAlertAction(title: "Tube"+String(index) , style: .default, handler: {_ in current_tubemodel = "tube"+String(index)})
            alertController.addAction(tubeaction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertController.addAction(cancelAction)
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        self.present(alertController, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self

        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = [SCNDebugOptions.showWireframe, SCNDebugOptions.showFeaturePoints, SCNDebugOptions.showCreases]

        // Create a new scene
        // let scene = SCNScene(named: "art.scnassets/"+current_tubemodel+".dae")!
        // SCNScene *scene = [SCNScene scenenamed:@'art.scnassets/']

        // Set the scene to the view
        // sceneView.scene = scene
    }
    
    func renderer (_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor){
        let meshNode : SCNNode
//        let textNode : SCNNode
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        guard let meshGeometry = ARSCNPlaneGeometry(device: sceneView.device!)
        else {
                fatalError("Can't create plane geometry")
            }
        meshGeometry.update(from: planeAnchor.geometry)
        meshNode = SCNNode(geometry: meshGeometry)
        meshNode.opacity = 0.6
        meshNode.name = "MeshNode"
        
        guard let material = meshNode.geometry?.firstMaterial
            else { fatalError("ARSCNPlaneGeometry always has one material") }
        material.diffuse.contents = UIColor.blue
        
        node.addChildNode(meshNode)
        
//        let textGeometry = SCNText(string: "Plane", extrusionDepth: 1)
//        textGeometry.font = UIFont(name: "Futura", size: 75)
        
//        textNode = SCNNode(geometry: textGeometry)
//        textNode.name = "TextNode"
//
//        textNode.simdScale = SIMD3(repeating: 0.0005)
//        textNode.eulerAngles = SCNVector3(x: Float(-90.degreesToradians), y: 0, z: 0)
//
//        node.addChildNode(textNode)
//        textNode.centerAlign()
//        print("did add plane node")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        if let planeGeometry = node.childNode(withName: "MeshNode", recursively: false)!.geometry as? ARSCNPlaneGeometry {
            planeGeometry.update(from: planeAnchor.geometry)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Create a session configuration
        let configuration =  ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        UIApplication.shared.isIdleTimerDisabled = true
        self.sceneView.autoenablesDefaultLighting = true
        
        // Run the view's session
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate

/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()

        return node
    }
*/

    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user

    }

    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay

    }

    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required

    }
}

extension SCNNode {
    func centerAlign() {
        let (min, max) = boundingBox
        let extents = ((max) - (min))
        simdPivot = float4x4(translation: SIMD3((extents / 2) + (min)))
    }
}

extension float4x4 {
    init(translation vector: SIMD3<Float>) {
        self.init(SIMD4(1, 0, 0, 0),
                  SIMD4(0, 1, 0, 0),
                  SIMD4(0, 0, 1, 0),
                  SIMD4(vector.x, vector.y, vector.z, 1))
    }
}

func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}
func / (left: SCNVector3, right: Int) -> SCNVector3 {
    return SCNVector3Make(left.x / Float(right), left.y / Float(right), left.z / Float(right))
}
extension Int {
    var degreesToradians : Double {return Double(self) * .pi/100}
}
