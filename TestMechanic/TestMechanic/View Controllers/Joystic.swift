//
//  Joystic.swift
//  TestMechanic
//
//  Created by Igor Ivanov on 25.12.2020.
//

import UIKit


extension ViewController {
    
    
    func setupPanTapView(){
        setupJoyMove()
        setupJoyJump()
        setupSwitchCamera()
    }
    

    func setupJoyMove(){
        panView.backgroundColor = .clear
        self.view.addSubview(panView)
     
        let size: CGFloat = 160
        panView.translatesAutoresizingMaskIntoConstraints = false
        let panLead = panView.widthAnchor.constraint(equalToConstant: size)
        let panBottom = panView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        let panTrail = panView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -96)
        let panHeight = panView.heightAnchor.constraint(equalToConstant: size)
        view.addConstraints([panLead, panBottom, panTrail, panHeight])
        
        
        let centroid = UIView()
        centroid.translatesAutoresizingMaskIntoConstraints = false
        centroid.backgroundColor = .blue
        panView.addSubview(centroid)
        
        
        let cWidth = centroid.widthAnchor.constraint(equalToConstant: 6)
        let cHeight = centroid.heightAnchor.constraint(equalToConstant: 6)
        let cCenterX = centroid.centerXAnchor.constraint(equalTo: panView.centerXAnchor)
        let cCenterY = centroid.centerYAnchor.constraint(equalTo: panView.centerYAnchor)
        view.addConstraints([cWidth, cHeight, cCenterX, cCenterY])
        
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 3, y: 3), radius: CGFloat(60), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        joyPanCircleLayer.path = circlePath.cgPath
        joyPanCircleLayer.fillColor = UIColor.clear.cgColor
        joyPanCircleLayer.strokeColor = UIColor.blue.cgColor
        joyPanCircleLayer.lineWidth = 1.0
        centroid.layer.addSublayer(joyPanCircleLayer)
    }
    
    
    
    func setupJoyJump(){
        tapView.backgroundColor = .clear
        self.view.addSubview(tapView)
        
        
        tapView.translatesAutoresizingMaskIntoConstraints = false
        let tapLead = tapView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let tapBottom = tapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        let tapWidth = tapView.widthAnchor.constraint(equalToConstant: 148)
        let tapHeight = tapView.heightAnchor.constraint(equalToConstant: 148)
        view.addConstraints([tapLead, tapBottom, tapWidth, tapHeight])
        
        
        let centroid = UIView()
        centroid.translatesAutoresizingMaskIntoConstraints = false
        centroid.backgroundColor = .clear
        tapView.addSubview(centroid)
        
        let cWidth = centroid.widthAnchor.constraint(equalToConstant: 6)
        let cHeight = centroid.heightAnchor.constraint(equalToConstant: 6)
        let cCenterX = centroid.centerXAnchor.constraint(equalTo: tapView.centerXAnchor)
        let cCenterY = centroid.centerYAnchor.constraint(equalTo: tapView.centerYAnchor)
        view.addConstraints([cWidth, cHeight, cCenterX, cCenterY])
        
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 3, y: 3), radius: CGFloat(60), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        joyTapCircleLayer.path = circlePath.cgPath
        joyTapCircleLayer.fillColor = UIColor.clear.cgColor
        joyTapCircleLayer.strokeColor = UIColor.blue.cgColor
        joyTapCircleLayer.lineWidth = 1.0
        centroid.layer.addSublayer(joyTapCircleLayer)
    }
    
    
    func setupSwitchCamera(){
        switchCameraView.backgroundColor = .brown
        self.view.addSubview(switchCameraView)
        switchCameraView.translatesAutoresizingMaskIntoConstraints = false
        let tapLead = switchCameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let tapTop = switchCameraView.topAnchor.constraint(equalTo: view.topAnchor)
        let tapWidth = switchCameraView.widthAnchor.constraint(equalToConstant: 100)
        let tapHeight = switchCameraView.heightAnchor.constraint(equalToConstant: 100)
        view.addConstraints([tapLead, tapTop, tapWidth, tapHeight])
        
        
        tapCameraRecognizer.addTarget(self, action: #selector(handleSwitchCamera))
        tapCameraRecognizer.numberOfTapsRequired = 1
        switchCameraView.addGestureRecognizer(tapCameraRecognizer)
    }
    
    
    @objc func handleSwitchCamera() {
        if scnView.pointOfView == horizZoomCamera {
            hero.cameraMode = .statically
            scnView.pointOfView = horizTopCamera
        } else {
            hero.cameraMode = .dynamically
            scnView.pointOfView = horizZoomCamera
        }
    }
}
