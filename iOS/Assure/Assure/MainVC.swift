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
		
		//Graph View
		let graphViewFrame = CGRect(x: 0, y: 20, width: view.frame.width, height: 300)
		let graphView = GrandpaGraph(frame: graphViewFrame)
		graphView.backgroundColor = .red //to be commented out after debugging
		view.addSubview(graphView)

		
		//Bottom View
		let bottomView = UIView()
		bottomView.backgroundColor = UIColor(colorLiteralRed: 237/255.0, green: 237/255.0, blue: 237/255.0, alpha: 1)
		bottomView.frame = CGRect(x: 0, y: 555, width: view.frame.width, height: view.frame.height-555)
		view.addSubview(bottomView)
		
		//Grandpa Status Bar
		grandpaStatusLabel.backgroundColor = UIColor(colorLiteralRed: 201/255.0, green: 201/255.0, blue: 201/255.0, alpha: 1)
		grandpaStatusLabel.frame = CGRect(x: 0, y: 529, width: view.frame.width, height: 26)
		grandpaStatusLabel.text = "Grandpa is currently in the kitchen"
		grandpaStatusLabel.font = UIFont (name: "Avenir-Book", size: 16)
		//UILabel.appearance().defaultFont = UIFont.systemFont(ofSize: 16)
		grandpaStatusLabel.textAlignment = NSTextAlignment.center
		view.addSubview(grandpaStatusLabel)
		
		getGrandpaLocationStatus()
		
		
		
	}
	
	func getGrandpaLocationStatus() {
		let gLocation = ""
		
		//LOGIC FOR NAMING LOCATION HERE
		let url = URL(string: "http://23.92.20.162:5000/get-location/")
		
		let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
			if error != nil {
				print("Is the server running? Well you better go catch it.")
				return
			}
			let result = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
			print(result ?? "You can't see this.")
		}
		
		task.resume()
		
		grandpaStatusLabel.text = "Grandpa is currenty in the \(gLocation)"
	}

}
