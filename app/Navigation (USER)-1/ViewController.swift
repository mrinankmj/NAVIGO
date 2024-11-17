import UIKit
import ARKit
import SceneKit

class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet var sceneView: ARSCNView!
    
    // URL of the 3D model to import
    let modelURL = "https://drive.google.com/file/d/1zKEf5M235goCihcNbO3hBhz8ZNV-PuA8/view?usp=drive_link"
    
    // Variables to manage navigation and waypoints
    var modelNode: SCNNode?
    var waypoints: [SCNNode] = []
    var currentPath: [SCNVector3] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupARView()
        load3DModelFromWeb()
    }
    
    // MARK: - ARKit Setup
    func setupARView() {
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
    }
    
    // MARK: - Load 3D Model from the Web using URLSession
    func load3DModelFromWeb() {
        guard let url = URL(string: modelURL) else {
            print("Invalid URL")
            return
        }
        
        let downloadTask = URLSession.shared.downloadTask(with: url) { localURL, _, error in
            guard let localURL = localURL, error == nil else {
                print("Failed to download model: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            self.loadModelFromPath(localURL.path)
        }
        downloadTask.resume()
    }
    
    // Load the 3D model from the downloaded file path
    func loadModelFromPath(_ path: String) {
        DispatchQueue.main.async {
            do {
                let scene = try SCNScene(url: URL(fileURLWithPath: path))
                self.modelNode = scene.rootNode
                if let modelNode = self.modelNode {
                    modelNode.position = SCNVector3(0, 0, -1.5) // Place the model 1.5 meters in front
                    self.sceneView.scene.rootNode.addChildNode(modelNode)
                }
            } catch {
                print("Failed to load model: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Touch Interaction to Set Waypoints
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchLocation = touches.first?.location(in: sceneView),
              let hitTestResult = sceneView.hitTest(touchLocation, options: nil).first else { return }
        
        let waypointNode = createWaypoint(at: hitTestResult.worldCoordinates)
        waypoints.append(waypointNode)
        sceneView.scene.rootNode.addChildNode(waypointNode)
        
        if waypoints.count > 1 {
            calculatePath()
        }
    }
    
    func createWaypoint(at position: SCNVector3) -> SCNNode {
        let sphere = SCNSphere(radius: 0.05)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.blue
        sphere.materials = [material]
        
        let waypointNode = SCNNode(geometry: sphere)
        waypointNode.position = position
        return waypointNode
    }
    
    // MARK: - Pathfinding (Simple Linear Interpolation)
    func calculatePath() {
        guard waypoints.count >= 2 else { return }
        let start = waypoints.first!.position
        let end = waypoints.last!.position
        
        currentPath = generatePath(start: start, end: end)
        renderPath()
    }
    
    func generatePath(start: SCNVector3, end: SCNVector3) -> [SCNVector3] {
        var path: [SCNVector3] = []
        let stepCount = 20
        let stepX = (end.x - start.x) / Float(stepCount)
        let stepY = (end.y - start.y) / Float(stepCount)
        let stepZ = (end.z - start.z) / Float(stepCount)
        
        for i in 0...stepCount {
            let point = SCNVector3(start.x + stepX * Float(i),
                                   start.y + stepY * Float(i),
                                   start.z + stepZ * Float(i))
            path.append(point)
        }
        return path
    }
    
    func renderPath() {
        for point in currentPath {
            let sphere = SCNSphere(radius: 0.02)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.green
            sphere.materials = [material]
            
            let pathNode = SCNNode(geometry: sphere)
            pathNode.position = point
            sceneView.scene.rootNode.addChildNode(pathNode)
        }
    }
}
