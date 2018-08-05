//
//  ViewController.swift
//  Vhista Clip
//
//  Created by Juan David Cruz Serrano on 8/4/18.
//  Copyright © 2018 Juan David Cruz Serrano. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        VHBluetoothManager.shared.startMonitoring()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

