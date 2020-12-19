//
//  Pathfind.swift
//  TestMechanic
//
//  Created by Igor Ivanov on 18.12.2020.
//

import GameplayKit
import SpriteKit
import UIKit

class Pathfinder {
    
    var graph: GKGridGraph<GKGridGraphNode>
    let dimension: Int32 = 60
    let graphCenter: Float = 30 //dimension / 2
    
    var obstacleLocations: [SCNVector3] = []

    init(){
        graph = GKGridGraph(fromGridStartingAt: SIMD2(0, 0), width: dimension, height: dimension, diagonalsAllowed: false)
    }
    
    
    func fillGraph(gameScene: SCNScene) {
        let parentNode = gameScene.rootNode.childNode(withName: "Obstacles", recursively: true)
        guard let parent = parentNode
        else {
            fatalError("vf")
        }
        let children = parent.childNodes
        for child in children {
            let vector3 = getNodeSize3D(child)
            excludeObstacle(center: child.worldPosition, size: vector3)
        }
    }
    
    
    func excludeObstacle(center location: SCNVector3, size: SCNVector3) {
        let midX = location.x // center of node
        let midZ = location.z // center of node
        
        let width = size.x
        let len = size.z
        
        
        
        let graphMidX = Int(graphCenter + midX)
        let graphMidY = Int(graphCenter + midZ)
        
        let leadX = graphMidX - Int(width/2)
        let trailX = graphMidX + Int(width/2)
        
        let leadY = graphMidY - Int(len/2)
        let trailY = graphMidY + Int(len/2)
     
        let graphNodes = graph.nodes as! [GKGridGraphNode]
        
        
        let removing = graphNodes.filter { node in
            let x = Int(node.gridPosition.x)
            let y = Int(node.gridPosition.y)
            
            return leadX...trailX ~= x && leadY...trailY ~= y
        }
        graph.remove(removing)
    }
    
    
    
    func convertGraph2Scene(gridPosition: vector_int2, parentWorld: SCNVector3) -> SCNVector3 {
        let graphX = Float(gridPosition.x)
        let graphY = Float(gridPosition.y)
        
        let scnX = graphX - graphCenter
        let scnZ = graphY - graphCenter
        
        return SCNVector3(scnX - (parentWorld.x), -2, scnZ - (parentWorld.z))
    }
    
//
//    func convertGraph2Scene(gridPosition: vector_int2) -> SCNVector3 {
//        let graphX = gridPosition.x
//        let graphY = gridPosition.y
//
//        let center: Int32 = 100 //dimension / 2
//
//        let scnX = Float(graphX - center )
//        let scnZ = Float(graphY - center)
//
//        return SCNVector3(scnX, 0, scnZ)
//    }
    
    
    func convertScene2Graph(node: SCNNode) -> GKGridGraphNode? {
        let location = node.presentation.worldPosition
        let x = location.x
        let z = location.z
        
        
        
        let graphX = Int32(graphCenter + x)
        let graphY = Int32(graphCenter + z)
    
        let gNodePosition = SIMD2(graphX, graphY)
        guard let node = graph.node(atGridPosition: gNodePosition) else {
            return nil
        }
        return node
    }

    
    func animatePath(enemy: SCNNode, enemyParentWorld: SCNNode, target: SCNNode) {
        
        let parentWorldX = enemyParentWorld.presentation.worldPosition.x
        let parentWorldZ = enemyParentWorld.presentation.worldPosition.z
        let parentWorld = SCNVector3(parentWorldX, enemy.presentation.worldPosition.y, parentWorldZ)
        
        let graphEnemy = convertScene2Graph(node: enemy)
        let graphTarget = convertScene2Graph(node: target)
        guard let ge = graphEnemy,
              let gt = graphTarget else { return }
        
        guard let solution = getSolutionPath(startNode: ge, endNode: gt)
        else { return}
        
        var actions = [SCNAction]()
        let duration: Double = Double.random(in: 0.04...0.08 )
        for i in 0..<solution.count {
            let vector3 = convertGraph2Scene(gridPosition: solution[i].gridPosition, parentWorld: parentWorld)
            let move = SCNAction.move(to: vector3, duration: duration)
            let action = SCNAction.sequence([SCNAction.wait(duration: duration), move])
            actions.append(action)
        }
        
        let seq = SCNAction.sequence(actions)
        DispatchQueue.main.async {
            enemy.runAction(seq)
        }
    }
    
    
    func getSolutionPath(startNode: GKGridGraphNode, endNode: GKGridGraphNode) -> [GKGridGraphNode]? {
        let solution = graph.findPath(from: startNode, to: endNode) as! [GKGridGraphNode]
        if solution.isEmpty {
            assertionFailure("No path exists between startNode and endNode.")
            return nil
        }
        else {
            return solution
        }
    }
}
