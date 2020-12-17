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
    return CGFloat(node.position.y) + size.height/2
}


func getNodeBottom(_ node: SCNNode) -> CGFloat {
    let size = getNodeSize(node)
    return CGFloat(node.position.y) - size.height/2
}

