//
//  PulseView.swift
//  PulseView
//
//  Created by Bohdan Savych on 9/8/18.
//  Copyright © 2018 Bohdan Savych. All rights reserved.
//

import UIKit

struct PulseViewConfig {
    var pulseViewColor = UIColor(red:0.99, green:0.83, blue:0.86, alpha:1.00)
    var pulseBorderColor = UIColor(red:0.95, green:0.80, blue:0.84, alpha:1.00)
    var pulseDuration = 5.0
    var nextPulseAfter = 2.0
    var pulseWaveSizeCoef: CGFloat = 4.0
    var borderWidth: CGFloat = 2
}

struct CAAnimationGroupDescription: Hashable {
    var hashValue: Int {
        return hashArr
            .map { "&" + String($0) }
            .reduce("", +)
            .hashValue
    }
    
    var hashArr = [Int]()
    
    init(animationGroup: CAAnimationGroup) {
        hashArr = animationGroup.animations?.map { $0.hashValue } ?? []
    }
}

final class PulseView: UIView {
    private let config: PulseViewConfig
    private var isPulsing = false
    private var timer: Timer?
    private var layerAnimationMatchingDictionary = [CAAnimationGroupDescription: CALayer?]()
    
    init(frame: CGRect,config: PulseViewConfig = PulseViewConfig()) {
        self.config = config
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func start() {
        guard !isPulsing else { return }
   
        pulse()
        timer = Timer.scheduledTimer(withTimeInterval: config.nextPulseAfter, repeats: true) { [weak self] _ in
            self?.isPulsing = true
            self?.pulse()
        }
    }
    
    private func pulse() {
        let layer = CALayer()
        layer.frame = CGRect(origin: .zero, size: frame.size)
        layer.backgroundColor = config.pulseViewColor.cgColor
        layer.borderColor = config.pulseBorderColor.cgColor
        layer.masksToBounds = true
        layer.cornerRadius = layer.frame.height / 2
        layer.borderWidth = config.borderWidth
        self.layer.addSublayer(layer)
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1
        opacityAnimation.toValue = 0
        layer.opacity = 0
        
        let frameAnimation = CABasicAnimation(keyPath: "bounds")
        frameAnimation.fromValue = NSValue(cgRect: layer.bounds)
        let width = layer.frame.width * config.pulseWaveSizeCoef
        let height = layer.frame.height * config.pulseWaveSizeCoef
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        frameAnimation.toValue = NSValue(cgRect: rect)
        layer.bounds = rect
        
        let cornerRadiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
        cornerRadiusAnimation.fromValue = layer.cornerRadius
        let newCorner = rect.height / 2
        cornerRadiusAnimation.toValue = newCorner
        layer.cornerRadius = newCorner
        
        let animGroup = CAAnimationGroup()
        animGroup.animations = [opacityAnimation, frameAnimation, cornerRadiusAnimation]
        animGroup.duration = config.pulseDuration
        animGroup.delegate = self
        
        layer.add(animGroup, forKey: nil)
        layerAnimationMatchingDictionary[CAAnimationGroupDescription(animationGroup: animGroup)] = layer
    }
}

// MARK: - CAAnimationDelegate
extension PulseView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let animGroup = anim as! CAAnimationGroup
        let animationGroupDescription = CAAnimationGroupDescription(animationGroup: animGroup)
        let layer = layerAnimationMatchingDictionary[animationGroupDescription]
        layer??.removeFromSuperlayer()
        layerAnimationMatchingDictionary[animationGroupDescription] = nil
    }
}
