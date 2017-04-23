//
//  MainVC.swift
//  Assure
//
//  Created by Kenneth Friedman on 4/22/17.
//  Copyright © 2017 Avery Lamp. All rights reserved.
//

import UIKit

class MainVC: UIViewController {
	
	//class vars, which are called from multiple functions
	let grandpaStatusLabel = UILabel()
	var graphView = GrandpaGraph()
	let leftBar = UIView()
	let rightBar = UIView()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		//Set up all main views
		setupGraphView()
		setupMiddleSection()
		setupBottomSection()
	}
	
	
	func setupGraphView() {
		//Graph View
		let graphViewFrame = CGRect(x: 0, y: 20, width: view.frame.width, height: 300)
		graphView = GrandpaGraph(frame: graphViewFrame)
		//		graphView.backgroundColor = .red //to be commented out after debugging
		view.addSubview(graphView)
	}
	
	func setupMiddleSection() {
		//Middle Area
		
		//left slider bar
		leftBar.frame = CGRect(x: 27, y: graphView.frame.maxY + 96, width: 4, height: 25)
		leftBar.backgroundColor = .black
		view.addSubview(leftBar)
		
		//right slider bar
		rightBar.frame = CGRect(x: view.frame.width - 27, y: graphView.frame.maxY + 96, width: 4, height: 25)
		rightBar.backgroundColor = .black
		view.addSubview(rightBar)
		
		//color views: generic naming for fast changing
		let totalBarD = rightBar.frame.minX - leftBar.frame.maxX
		let cvHeight = 20.0
		let cvY = Double(leftBar.frame.midY) - cvHeight/2.0
		let green = UIColor(colorLiteralRed: 104/255.0, green: 209/255.0, blue: 184/255.0, alpha: 1)
		let blue = UIColor(colorLiteralRed: 114/255.0, green: 160/255.0, blue: 235/255.0, alpha: 1)
		let orange = UIColor(colorLiteralRed: 245/255.0, green: 166/255.0, blue: 35/255.0, alpha: 1)
		let pink = UIColor(colorLiteralRed: 255/255.0, green: 140/255.0, blue: 154/255.0, alpha: 1)
		
		let cv1 = UIView()
		cv1.backgroundColor = green
		cv1.frame = CGRect(x: Double(leftBar.frame.maxX), y: cvY, width: Double(totalBarD*0.3), height: cvHeight )
		view.addSubview(cv1)
		
		let cv2 = UIView()
		cv2.backgroundColor = blue
		cv2.frame = CGRect(x: Double(cv1.frame.maxX), y: cvY, width: Double(totalBarD*0.10), height: cvHeight )
		view.addSubview(cv2)
		
		let cv3 = UIView()
		cv3.backgroundColor = orange
		cv3.frame = CGRect(x: Double(cv2.frame.maxX), y: cvY, width: Double(totalBarD*0.15), height: cvHeight )
		view.addSubview(cv3)
		
		let cv4 = UIView()
		cv4.backgroundColor = blue
		cv4.frame = CGRect(x: Double(cv3.frame.maxX), y: cvY, width: Double(totalBarD*0.15), height: cvHeight )
		view.addSubview(cv4)
		
		let cv5 = UIView()
		cv5.backgroundColor = pink
		cv5.frame = CGRect(x: Double(cv4.frame.maxX), y: cvY, width: Double(totalBarD*0.05), height: cvHeight )
		view.addSubview(cv5)
		
		let cv6 = UIView()
		cv6.backgroundColor = blue
		cv6.frame = CGRect(x: Double(cv5.frame.maxX), y: cvY, width: Double(totalBarD*0.05), height: cvHeight )
		view.addSubview(cv6)
		
		let cv7 = UIView()
		cv7.backgroundColor = green
		cv7.frame = CGRect(x: Double(cv6.frame.maxX), y: cvY, width: Double(totalBarD*0.2), height: cvHeight )
		view.addSubview(cv7)
		
		
		let box = UIView()
		box.frame = CGRect(x: rightBar.frame.minX-30, y: leftBar.frame.midY-15, width: 30, height: 30)
		box.backgroundColor = .white
		box.layer.borderWidth = 2
		box.layer.borderColor = UIColor.black.cgColor
		view.addSubview(box)
		
		
		let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(recognizer:)))
		box.addGestureRecognizer(pan)
	}
	
//	func panBox(_ send:UIPanGestureRecognizer) {
//		print("working")
//	}
	
	func handlePan(recognizer:UIPanGestureRecognizer) {
		let translation = recognizer.translation(in: self.view)
		if let view = recognizer.view {
			var newX = view.center.x + translation.x
			newX = max(newX, leftBar.frame.maxX+14)	//sorry about the magic number 14.
													//It's 10+4. 10 from half width, 4 from bar
			newX = min(newX, rightBar.frame.minX-14)
			view.center = CGPoint(x:newX, y: view.center.y)
		}
		recognizer.setTranslation(CGPoint.zero, in: self.view)
	}
	
	func setupBottomSection() {
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
		grandpaStatusLabel.textAlignment = NSTextAlignment.center
		view.addSubview(grandpaStatusLabel)
		
		getAndSetGrandpaLocationStatus()
	}
	
	//this occurs on ecah touch, mostly used for debugging & testing
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		//self.getGeneralLocationInfo()
		self.graphView.setGraphValues(v1: 30.0, v2: 5.0, v3: 10.0, v4: 15.0)
	}
	
	//
	func getGeneralLocationInfo() {
		
		let url = URL(string: "http://23.92.20.162:5000/closestModule/")
		
		let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
			if error != nil {
				print("Is the server running? Well you better go catch it.")
				return
			}
			let result = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
			print(result ?? "You can't see this.")
		}
		
		task.resume()
		
		
	}

	func getAndSetGrandpaLocationStatus() {
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
