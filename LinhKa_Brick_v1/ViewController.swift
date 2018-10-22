//
//  ViewController.swift
//  LinhKa_Brick_v1
//
//  Created by Viet Asc on 10/22/18.
//  Copyright © 2018 Viet Asc. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollisionBehaviorDelegate {

    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var linggkaBall: UIImageView!
    @IBOutlet weak var slingShotPoint1: UIView!
    @IBOutlet weak var slingShotPoint2: UIView!
    @IBOutlet weak var box1: UIImageView!
    @IBOutlet weak var box2: UIImageView!
    @IBOutlet weak var box3: UIImageView!
    @IBOutlet weak var chiiBe: UIImageView!
    @IBOutlet weak var longBii: UIImageView!
    @IBOutlet weak var longHoang: UIImageView!
    
    var originalBallPosition: CGPoint!
    var anchorPoint: CGPoint!
    var previousPoint: CGPoint!
    var timer: Timer!
    var picked = false
    var updateCount = 0
    
    var animator = UIDynamicAnimator()
    var attackmentBehavior: UIAttachmentBehavior!
    var pickUpBehavior: UIAttachmentBehavior!
    var pushBehavior: UIPushBehavior!
    var ballBehavior: UIAttachmentBehavior!
    var ballProperty: UIDynamicItemBehavior!
    
    // For Collision
    func collisionBehavior(behavior: UICollisionBehavior) {
        behavior.translatesReferenceBoundsIntoBoundary = true
        behavior.collisionDelegate = self
        animator.addBehavior(behavior)
    }
    
    // For Picking Up
    @objc func handlePan(gesture: UIPanGestureRecognizer){
        pickUpBehavior.anchorPoint = gesture.location(in: view)
        anchorPoint = pickUpBehavior.anchorPoint
    }
    
    // Set default
    func setDefault() {
        previousPoint = nil
        anchorPoint = nil
        pickUpBehavior.anchorPoint = CGPoint()
        let chiiBePoint = chiiBe.center
        let longBiiPoint = longBii.center
        let longHoangPoint = longHoang.center
        let box1Point = box1.center
        let box2Point = box2.center
        let box3Point = box3.center
        animator.removeAllBehaviors()
        chiiBe.center = chiiBePoint
        longBii.center = longBiiPoint
        longHoang.center = longHoangPoint
        box1.center = box1Point
        box2.center = box2Point
        box3.center = box3Point
        linggkaBall.center = originalBallPosition
    }
    
    // Pick up
    func pickUp() {
        pickUpBehavior = UIAttachmentBehavior(item: linggkaBall, attachedToAnchor: linggkaBall.center)
        animator.addBehavior(pickUpBehavior)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        view.addGestureRecognizer(panGesture)
    }
    
    // Draw strings for the slingshot
    func drawLine(from1: CGPoint, from2: CGPoint, to: CGPoint) {
        
        let p1 = CGPoint(x: from1.x, y: from1.y)
        let p2 = CGPoint(x: from2.x, y: from2.y)
        var p3 = CGPoint()
        if to == CGPoint() {
            p3 = p2
        } else {
            p3 = CGPoint(x: to.x, y: to.y)
        }
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        let context = UIGraphicsGetCurrentContext()
        let size = mainImageView.frame.size
        view.draw(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        context?.addLines(between: [p1, p3, p2])
        context?.setLineCap(.round)
        context?.setLineWidth(10)
        context?.setStrokeColor(red: 0, green: 0, blue: 0, alpha: 1)
        context?.setBlendMode(.normal)
        context?.strokePath()
        mainImageView.alpha = 0.75
        
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        
        //Close
        UIGraphicsEndImageContext()
        
    }
    
    // Initital Data
    func initData() {
        picked = false
        
        // Draw the slingshot
        drawLine(from1: slingShotPoint1.center, from2: slingShotPoint2.center, to: linggkaBall.center)
        animator = UIDynamicAnimator(referenceView: view)
        
        // Touch for boxes
        let boxCollisionBehavior = UICollisionBehavior(items: [linggkaBall, chiiBe, longBii, longHoang, box1, box2, box3])
        collisionBehavior(behavior: boxCollisionBehavior)
        
        // Pick up
        pickUp()
        
        // UIDynamicItemBehavior
        ballProperty = UIDynamicItemBehavior(items: [linggkaBall])
        // Spin
        ballProperty.friction = 100
        animator.addBehavior(ballProperty)
        
    }
    
    // Push
    func pushBall() {
        pushBehavior = UIPushBehavior(items: [linggkaBall], mode: .continuous)
        animator.addBehavior(pushBehavior)
        let o: CGPoint = originalBallPosition
        let b = linggkaBall.center
        let distance = sqrtf(powf(Float(o.x) - Float(b.x), 2) + powf(Float(o.y) - Float(b.y), 2.0))
        let angle = atan2(o.y - b.y, o.x - b.x)
        pushBehavior.magnitude = CGFloat(distance/100)
        pushBehavior.angle = angle
    }
    
    // Update by timer
    @objc func timing() {
        updateCount += 1
        if updateCount >= 100 {
            if linggkaBall.center != originalBallPosition {
                setDefault()
                initData()
            }
            updateCount = 0
        }
        if !picked && anchorPoint != nil {
            if previousPoint != anchorPoint {
                previousPoint = anchorPoint
            } else {
                picked = true
                // Remove anchor
                animator.removeBehavior(pickUpBehavior)
                // Add push
                pushBall()
            }
        }
        if linggkaBall.center.y > slingShotPoint1.center.y {
            drawLine(from1: slingShotPoint1.center, from2: slingShotPoint2.center, to: linggkaBall.center)
        } else {
            drawLine(from1: slingShotPoint1.center, from2: slingShotPoint2.center, to: CGPoint())
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timing), userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        originalBallPosition = linggkaBall.center
        initData()
    }


    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

