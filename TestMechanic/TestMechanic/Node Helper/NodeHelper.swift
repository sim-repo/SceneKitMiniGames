//
//  NodeHelper.swift
//  TestMechanic
//
//  Created by Igor Ivanov on 17.12.2020.
//

import SceneKit

func getNodeSize(_ node: SCNNode) -> CGSize {
    let (minVec, maxVec) = node.boundingBox
    let height = maxVec.y - minVec.y
    let width = maxVec.x - minVec.x
    return CGSize(width: CGFloat(width), height: CGFloat(height))
}


func getNodeTop(_ node: SCNNode) -> CGFloat {
    let size = getNodeSize(node)
    return CGFloat(node.presentation.worldPosition.y) + size.height/2
}


func getNodeBottom(_ node: SCNNode) -> CGFloat {
    let size = getNodeSize(node)
    return CGFloat(node.worldPosition.y) - size.height/2
}


func getNodeFarZ(_ node: SCNNode) -> Float {
    let size = getNodeSize(node)
    return node.presentation.worldPosition.z - Float(size.width/2)
}

func calcDistance(node1: SCNNode, node2: SCNNode) -> CGFloat {
    let dx = node2.presentation.worldPosition.x - node1.presentation.worldPosition.x
    let dz = node2.presentation.worldPosition.z - node1.presentation.worldPosition.z
    
    return CGFloat(sqrt(dx*dx + dz*dz))
}


//MARK:- 3D

func getNodeSize3D(_ node: SCNNode) -> SCNVector3 {
    let (minVec, maxVec) = node.boundingBox
    let height = maxVec.y - minVec.y
    let width = maxVec.x - minVec.x
    let len = maxVec.z - minVec.z
    return SCNVector3(width, height, len)
}
