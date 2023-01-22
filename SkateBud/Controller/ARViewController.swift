//
//  ARViewController.swift
//  SkateBud
//
//  Created by Victor on 2023-01-02.
//

import UIKit
import ARKit

class ARViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,  ARSCNViewDelegate {

    @IBOutlet weak var itemsCollectionView: UICollectionView!
    @IBOutlet weak var planeDetectedLbl: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    
    let itemsArray: [String] = ["cup", "table", "skateboard", "cone1", "car1", "car2", "bench", "sign", "tires", "bricks", "dumpster", "trash", "rail"]
    let configuration = ARWorldTrackingConfiguration()
    var selectedItem: String?
    
    //ARVideoKit Variables
    // Recorder UIButton. This button will start and stop a video recording.
    var recorderButton:UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Record", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        btn.frame = CGRect(x: 0, y: 0, width: 110, height: 60)
        btn.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height*0.90)
        btn.layer.cornerRadius = btn.bounds.height/2
        btn.tag = 0
        return btn
    }()
     
    // Pause UIButton. This button will pause a video recording.
    var pauseButton:UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Pause", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        btn.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        btn.center = CGPoint(x: UIScreen.main.bounds.width*0.15, y: UIScreen.main.bounds.height*0.90)
        btn.layer.cornerRadius = btn.bounds.height/2
        btn.alpha = 0.3
        btn.isEnabled = false
        return btn
    }()
     
    // GIF UIButton. This button will capture a GIF image.
    var gifButton:UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("GIF", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        btn.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        btn.center = CGPoint(x: UIScreen.main.bounds.width*0.85, y: UIScreen.main.bounds.height*0.90)
        btn.layer.cornerRadius = btn.bounds.height/2
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Show AR debug elements in the scene
        self.sceneView.debugOptions = [ ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration)
        self.itemsCollectionView.dataSource = self
        self.itemsCollectionView.delegate = self
        self.sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        self.registerGestureRecognizers()
        
        //ARVideoKit  Stuff
        // Add the buttons as subviews of the View Controller
        self.view.addSubview(recorderButton)
        self.view.addSubview(pauseButton)
        self.view.addSubview(gifButton)
    
        // Add buttons’ targets and connect them to the methods
        recorderButton.addTarget(self, action: #selector(recorderAction(sender:)), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(pauseAction(sender:)), for: .touchUpInside)
        gifButton.addTarget(self, action: #selector(gifAction(sender:)), for: .touchUpInside)
        
        // Do any additional setup after loading the view.
    }
    
    // Record and stop method
    @objc func recorderAction(sender:UIButton) {
            
    }
    // Pause and resume method
    @objc func pauseAction(sender:UIButton) {
        
    }
    // Capture GIF method
    @objc func gifAction(sender:UIButton) {
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // hide navigation bar andtab bar when mapview opens
//        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func registerGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(placeItem))
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(resizeItem))
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(rotateItem))
        longPressGestureRecognizer.minimumPressDuration = 0.1
        self.sceneView.addGestureRecognizer(pinchGestureRecognizer)
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        self.sceneView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc func placeItem(sender: UITapGestureRecognizer) {
        let sceneView = sender.view as! ARSCNView
        let tapLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        if !hitTest.isEmpty {
            self.addItem(hitTestResult: hitTest.first!)
        }
    }
    
    @objc func resizeItem(sender: UIPinchGestureRecognizer) {
        let sceneView = sender.view as! ARSCNView
        let pinchLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(pinchLocation)
        if !hitTest.isEmpty {
            let results = hitTest.first!
            let node = results.node
            let pinchAction = SCNAction.scale(by: sender.scale, duration: 0)
            print(sender.scale)
            node.runAction(pinchAction)
            sender.scale = 1.0
        }
    }
    
    @objc func rotateItem(sender: UILongPressGestureRecognizer) {
        let sceneView = sender.view as! ARSCNView
        let holdLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(holdLocation)
        if !hitTest.isEmpty {
            
            let results = hitTest.first!
            
            if sender.state == .began {
                let rotation = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 1)
                let forever = SCNAction.repeatForever(rotation)
                results.node.runAction(forever)
            } else if sender.state == .ended {
                results.node.removeAllActions()
            }
        }
    }
    
    func addItem(hitTestResult: ARHitTestResult) {
        if let selectedItem = self.selectedItem {
            let scene = SCNScene(named: "Models/\(selectedItem).scn")
            let node = (scene?.rootNode.childNode(withName: selectedItem, recursively: false))!
            let transform = hitTestResult.worldTransform
            let thirdColumn = transform.columns.3
            node.position = SCNVector3(thirdColumn.x, thirdColumn.y, thirdColumn.z)
            self.sceneView.scene.rootNode.addChildNode(node)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ARCollectionViewItemCell", for: indexPath) as! ItemCollectionViewCell
        cell.itemLabel.text = self.itemsArray[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        self.selectedItem = itemsArray[indexPath.row]
        cell?.backgroundColor = UIColor.green
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.lightGray
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
        DispatchQueue.main.async {
            self.planeDetectedLbl.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.planeDetectedLbl.isHidden = true
            }
        }
    }
}

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi/180 }
}
