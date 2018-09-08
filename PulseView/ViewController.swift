//
//  ViewController.swift
//  PulseView
//
//  Created by Bohdan Savych on 9/8/18.
//  Copyright © 2018 Bohdan Savych. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    lazy var pulseView = PulseView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pulseView.center = self.view.center
        view.insertSubview(pulseView, at: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        pulseView.start()
    }
}

