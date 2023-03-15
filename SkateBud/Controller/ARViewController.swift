//
//  ARViewController.swift
//  SkateBud
//
//  Created by Victor on 2023-01-02.
//

import UIKit
import ARKit
import ARVideoKit

class ARViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,  ARSCNViewDelegate {

    @IBOutlet weak var itemsCollectionView: UICollectionView!
    @IBOutlet weak var planeDetectedLbl: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    
    let itemsArray: [String] = ["cup", "skateboard", "cone1", "car1", "car2", "bench", "sign", "tires", "bricks", "dumpster", "trash", "rail"]
    var itemsIconArray = [UIImage(named: "item_cup_50x50"), UIImage(named: "item_skateboard_50x50"), UIImage(named: "item_cone1_50x50"), UIImage(named: "item_car1_50x50"), UIImage(named: "item_car2_50x50"), UIImage(named: "item_bench_50x50"), UIImage(named: "item_sign_50x50"), UIImage(named: "item_tires_50x50"), UIImage(named: "item_bricks_50x50"), UIImage(named: "item_dumpster_50x50"), UIImage(named: "item_trash_50x50"), UIImage(named: "item_rail_50x50")]
    let configuration = ARWorldTrackingConfiguration()
    var selectedItem: String?
    
    //ARVideoKit Variables
    var recorder: RecordAR?
    
    // Recorder UIButton. This button will start and stop a video recording.
    var recorderButton:UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Record", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        btn.frame = CGRect(x: 0, y: 0, width: 110, height: 60)
        btn.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height*0.75)
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
        btn.center = CGPoint(x: UIScreen.main.bounds.width*0.15, y: UIScreen.main.bounds.height*0.75)
        btn.layer.cornerRadius = btn.bounds.height/2
        btn.alpha = 0.3
        btn.isEnabled = false
        return btn
    }()
     
    // Clear Button. This button will remove all previously placed items.
    var clearItemsButton:UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Clear", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        btn.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        btn.center = CGPoint(x: UIScreen.main.bounds.width*0.85, y: UIScreen.main.bounds.height*0.75)
        btn.layer.cornerRadius = btn.bounds.height/2
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Show AR debug elements in the scene
//        self.sceneView.debugOptions = [ ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration)
        self.itemsCollectionView.dataSource = self
        self.itemsCollectionView.delegate = self
        self.itemsCollectionView.backgroundColor = UIColor.clear.withAlphaComponent(0)
        self.sceneView.delegate = self
        // sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = true
        self.registerGestureRecognizers()
        
        //ARVideoKit  Stuff
        // Add the buttons as subviews of the View Controller
        self.view.addSubview(recorderButton)
        self.view.addSubview(pauseButton)
        self.view.addSubview(clearItemsButton)
    
        // Add buttons’ targets and connect them to the methods
        recorderButton.addTarget(self, action: #selector(recorderAction(sender:)), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(pauseAction(sender:)), for: .touchUpInside)
        clearItemsButton.addTarget(self, action: #selector(clearAction(sender:)), for: .touchUpInside)
        
        // Initialize with SpriteKit scene
        recorder = RecordAR(ARSceneKit: sceneView)
        // Specifiy supported orientations
        recorder?.inputViewOrientations = [.portrait, .landscapeLeft, .landscapeRight]
        // Add environment light rendering to the recorder
        recorder?.enableAdjustEnvironmentLighting = true
            
        // Do any additional setup after loading the view.
    }
    
    // Record and stop method
    @objc func recorderAction(sender:UIButton) {
        
        if recorder?.status == .readyToRecord {
            // Start recording
            recorder?.record()
            
            // Change button title
            sender.setTitle("Stop", for: .normal)
            sender.setTitleColor(.red, for: .normal)
            
            // Enable Pause button
            pauseButton.alpha = 1
            pauseButton.isEnabled = true
            
            // Disable clear button
            clearItemsButton.alpha = 0.3
            clearItemsButton.isEnabled = false
        } else if recorder?.status == .recording || recorder?.status == .paused {
            // Stop recording and export video to camera roll
            recorder?.stopAndExport()
            
            // Change button title
            sender.setTitle("Record", for: .normal)
            sender.setTitleColor(.black, for: .normal)
            
            // Enable clear button
            clearItemsButton.alpha = 1
            clearItemsButton.isEnabled = true
            
            // Disable Pause button
            pauseButton.alpha = 0.3
            pauseButton.isEnabled = false
            
            // Alert user that the video has been saved
             var dialogMessage = UIAlertController(title: "Video Saved", message: "The video has been saved to your photo library.", preferredStyle: .alert)
             let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                 print("Ok button tapped")
              })
             dialogMessage.addAction(ok)
             self.present(dialogMessage, animated: true, completion: nil)
        }
        
    }
    
    // Pause and resume method
    @objc func pauseAction(sender:UIButton) {
        if recorder?.status == .recording {
            // Pause recording
            recorder?.pause()
            
            // Change button title
            sender.setTitle("Resume", for: .normal)
            sender.setTitleColor(.blue, for: .normal)
        } else if recorder?.status == .paused {
            // Resume recording
            recorder?.record()
            
            // Change button title
            sender.setTitle("Pause", for: .normal)
            sender.setTitleColor(.black, for: .normal)
        }
    }
    
    // Clear all items method
    @objc func clearAction(sender:UIButton) {
        removeAllItems()
    }
    
    func removeAllItems() {
        var existingNodes = self.sceneView.scene.rootNode.childNodes
        print(existingNodes)
        for itemNode in existingNodes {
            itemNode.removeFromParentNode()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // hide navigation bar andtab bar when mapview opens
//        self.navigationController?.navigationBar.isHidden = true
//        self.tabBarController?.tabBar.isHidden = true
        
        // Make the ARCSView cover the entire screen
        if (self.tabBarController?.tabBar.isHidden == true) {
            NSLayoutConstraint.activate([
                sceneView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
                sceneView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0),
                sceneView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
                sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
            ])
        }
        
        //ARVideoKit stuff
        recorder?.prepare(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeAllItems()
        sceneView.session.pause()
        recorder?.rest()
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
        cell.itemImage.image = self.itemsIconArray[indexPath.row]
        cell.itemImage.sizeToFit()
        cell.layer.cornerRadius = 32
        cell.clipsToBounds = true
        if (self.itemsArray[indexPath.row] == self.selectedItem) {
            cell.backgroundColor = UIColor.green
        } else {
            cell.backgroundColor = UIColor.clear
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        self.selectedItem = itemsArray[indexPath.row]
        cell?.backgroundColor = UIColor.green
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.clear
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
