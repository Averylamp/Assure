//
//  MainVC.swift
//  Assure
//
//  Created by Kenneth Friedman on 4/22/17.
//  Copyright © 2017 Avery Lamp. All rights reserved.
//

import UIKit

class MainVC: UIViewController {
	
	let grandpaStatusLabel = UILabel()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		//Bottom View
		let bottomView = UIView()
		bottomView.backgroundColor = UIColor(colorLiteralRed: 237/255.0, green: 237/255.0, blue: 237/255.0, alpha: 1)
		bottomView.frame = CGRect(x: 0, y: 555, width: view.frame.width, height: view.frame.height-555)
		view.addSubview(bottomView)
		
		//Grandpa Status Bar
		grandpaStatusLabel.backgroundColor = UIColor(colorLiteralRed: 201/255.0, green: 201/255.0, blue: 201/255.0, alpha: 1)
		grandpaStatusLabel.frame = CGRect(x: 0, y: 529, width: view.frame.width, height: 26)
		grandpaStatusLabel.text = "Grandpa is currently in the kitchen"
		grandpaStatusLabel.textAlignment = NSTextAlignment.center
		view.addSubview(grandpaStatusLabel)
	}
	
	func setGrandpaLocationStatus() {
		var gLocation = ""
		
		//LOGIC FOR NAMING LOCATION HERE
		
		grandpaStatusLabel.text = "Grandpa is currenty in the \(gLocation)"
	}

}
