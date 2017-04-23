//
//  MainVC.swift
//  Assure
//
//  Created by Kenneth Friedman on 4/22/17.
//  Copyright © 2017 Avery Lamp. All rights reserved.
//

import UIKit

class MainVC: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		
		let bottomView = UIView()
		bottomView.backgroundColor = UIColor(colorLiteralRed: 237/255.0, green: 237/255.0, blue: 237/255.0, alpha: 1)
		bottomView.frame = CGRect(x: 0, y: 555, width: view.frame.width, height: view.frame.width-555)
		view.addSubview(bottomView)
	}

}
