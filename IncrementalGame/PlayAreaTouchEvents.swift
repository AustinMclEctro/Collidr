//
//  PlayAreaTouchEvents.swift
//  IncrementalGame
//
//  Created by Andrew Groeneveldt on 2017-10-22.
//  Copyright © 2017 Ben Grande. All rights reserved.
//

import Foundation
import UIKit

extension PlayArea {
    
    func setupTouchEvents() {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchSelf))
        self.addGestureRecognizer(pinch)
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleTaps))
        doubleTap.cancelsTouchesInView = false;
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTap)
        
        let edgePanRight = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePan))
        edgePanRight.edges = .right
        self.addGestureRecognizer(edgePanRight)
        let edgePanLeft = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePan))
        edgePanLeft.edges = .left
        self.addGestureRecognizer(edgePanLeft)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(drag));
        self.addGestureRecognizer(pan);
        pan.require(toFail: edgePanRight);
        pan.require(toFail: edgePanLeft);
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(oneTap))
        singleTap.cancelsTouchesInView = false;
        singleTap.require(toFail: pan)
        self.addGestureRecognizer(singleTap)
    }
    
    @objc func drag(sender: UIPanGestureRecognizer) {
        let location = CGPoint(x: sender.location(in: self).x, y: frame.height-sender.location(in: self).y)
        switch sender.state {
        case .began:
            
            let nodes = scene?.nodes(at: location) ?? []
            for n in nodes {
                if let node = n as? GameObject {
                    selectedNode = node;
                    selectedNode?.physicsBody?.affectedByGravity = false;
                    //selectedNode?.physicsBody?.isDynamic = false;
                    break;
                }
            }
            
            break;
        case .changed:
            if (selectedNode != nil) {
                selectedNode?.position = location;
            }
            break;
        default: // ended, canceled etc.
            let vel = sender.velocity(in: self);
            //selectedNode?.physicsBody?.isDynamic = true;
            selectedNode?.physicsBody?.affectedByGravity = true;
            // TODO - overcome gravity
            selectedNode?.physicsBody?.applyForce(CGVector(dx: vel.x, dy: -vel.y))
            selectedNode = nil;
            
            break;
        }
    }
    
    @objc func oneTap(recognizer: UITapGestureRecognizer) {
        var location = recognizer.location(in: self)
        location = level.convertPoint(fromView: location)
        var nodes = self.level.nodes(at: location)
        var shapeTapped: Shape?;
        for n in nodes {
            if let nodeTemp = n as? Shape {
                shapeTapped = nodeTemp;
                break;
            }
        }
        if shapeTapped != nil {
            gained(amount: shapeTapped!.objectType.getPoints())
            for child in level.children {
                if let otherShape = child as? Shape {
                    let offset = CGVector(dx: otherShape.position.x - shapeTapped!.position.x, dy: otherShape.position.y - shapeTapped!.position.y)
                    if offset.magnitudeSquared() < shapeTapped!.size.width * shapeTapped!.size.width * 1.75 {
                        otherShape.physicsBody?.applyImpulse(offset)
                    }
                }
            }
        }
    }
    
    @objc func handleEdgePan(recognizer: UIScreenEdgePanGestureRecognizer) {
        // Allows draging shapes to override pan
        if (recognizer.state == .began) {
            let location = CGPoint(x: recognizer.location(in: self).x, y: frame.height-recognizer.location(in: self).y)
            let nodes = scene?.nodes(at: location) ?? []
            for n in nodes {
                if let node = n as? GameObject {
                    selectedNode = node;
                    break;
                }
            }
        }
        if (selectedNode == nil) {
        
            var index = zoneNumber
            if recognizer.state == .ended {
                if recognizer.edges == .right {
                    index += 1
                    if index == gameState.zones.count {index = 0}
                } else if recognizer.edges == .left {
                    index -= 1
                    if index < 0 {index = gameState.zones.count - 1}
                }
                // Need to make sure selectedNode is nil, in case drag fails for some reason
                selectedNode = nil;
            // Show zone at index
                selectZone(index: index);
            
            // just for testing
                print(zoneNumber)
            }
        }
        else { // do drag instead of pan
            drag(sender: recognizer);
        }
    }
    
    @objc func pinchSelf(sender: UIPinchGestureRecognizer) {
        let scale = sender.scale
        
        switch sender.state {
        case .began:
            if (tableSceneView == nil) {
                tableSceneView = SceneTableView(frame: CGRect(x: -100, y: -100, width: frame.width+200, height: frame.height+200))
            }
            tableSceneView!.setZones(zones: gameState.zones);
            self.addSubview(tableSceneView!);
        case .changed:
            if (tableOpen) {
                
                tableSceneView?.alpha = scale
                let dif = 200*(1-scale)
                tableSceneView!.frame = CGRect(x: dif, y: dif, width: frame.width+(dif*2), height: frame.height+(dif*2))
            }
            else {
                let maxScale = min(scale, 2)
                let opacity = min(scale-1, 1)
                tableSceneView?.alpha = opacity
                let dif = 100-50*maxScale
                tableSceneView!.frame = CGRect(x: dif, y: dif, width: frame.width+(dif*2), height: frame.height+(dif*2))
            }
        default:
            if scale >= 1.5 {
                tableSceneView!.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
                tableOpen = true
            }
            else {
                tableSceneView?.removeFromSuperview()
                tableOpen = false
            }
        }
    }
    
    
    @objc func handleTaps(recognizer: UITapGestureRecognizer) {
        
        if zoneNumber == 0 && gameState.currencyA >= Zone.newZonePrice {
            zoneNumber = gameState.zones.count
            level = Zone(size: frame.size)
            gameState.zones.append(level)
            gained(amount: -Zone.newZonePrice)
            gameState.zones[0].updateZonePrice(gameState.zones.count * gameState.zones.count * 1000)
            presentScene(level)
            
            // just for testing
            addFixture(of: .Bumper, at: CGPoint(x:0, y:0))
            addShape(of: .Triangle, at: CGPoint(x:150, y:100))
            addShape(of: .Square, at: CGPoint(x:200, y:100))
        }
    }
    
}
