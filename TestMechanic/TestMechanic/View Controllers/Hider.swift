//
//  Hider.swift
//  TestMechanic
//
//  Created by Igor Ivanov on 23.12.2020.
//

import UIKit
import SceneKit

//MARK:- hiding obstacles
extension ViewController  {
    func makeTransparentHidingObjects(){
       return
        timerHideObstacles = Timer.init(fire: Date().addingTimeInterval(0), interval: 0.5, repeats: true) {_ in
            DispatchQueue.global(qos: .utility).async {
                let nodes = self.scnView.nodesInsideFrustum(of: self.camera)
                let physics = nodes.filter{ $0.physicsBody != nil }
                let hideables = physics.filter{ $0.physicsBody!.categoryBitMask == BitMaskObstacle }
                self.hideObjects(hideables: hideables)
            }
        }
        RunLoop.main.add(timerHideObstacles!, forMode: .common)
    }
    
    
    private func hideObjects(hideables: [SCNNode]){
        
     // DispatchQueue.main.sync {
            hideables.forEach {n in
         //       n.geometry?.firstMaterial?.transparency = 1
            }
      //}
        
        let nearZ = hideables.filter{getNodeFarZ($0) > self.heroNode.presentation.worldPosition.z}
        
        let heroTop = self.hero.getHeroTop(self.heroNode)
        let higher = nearZ.filter{ (getNodeTop($0) - 2) > heroTop }

       // DispatchQueue.main.sync {
            for n in higher {
           //     n.geometry?.firstMaterial?.transparency = 0.1
               // n.opacity = 0.001
            }
        //}
    }
}
