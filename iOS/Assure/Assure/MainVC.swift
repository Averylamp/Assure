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
	
	//cvs
	let cv1 = UIView()
	let cv2 = UIView()
	let cv3 = UIView()
	let cv4 = UIView()
	let cv5 = UIView()
	let cv6 = UIView()
	let cv7 = UIView()
	
	let bedroomIV = UIImageView()
	let bathroomIV = UIImageView()
	let livingIV = UIImageView()
	let kitchenIV = UIImageView()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		//Set up all main views
		setupGraphView()
		setupMiddleSection()
		setupBottomSection()
		
		runTimer()
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
		leftBar.frame = CGRect(x: 27, y: graphView.frame.maxY, width: 4, height: 25)
		leftBar.backgroundColor = .black
		view.addSubview(leftBar)
		
		//right slider bar
		rightBar.frame = CGRect(x: view.frame.width - 27, y: graphView.frame.maxY , width: 4, height: 25)
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
		
		
		cv1.backgroundColor = green
		cv1.frame = CGRect(x: Double(leftBar.frame.maxX), y: cvY, width: Double(totalBarD*0.3), height: cvHeight )
		view.addSubview(cv1)
		
		
		cv2.backgroundColor = blue
		cv2.frame = CGRect(x: Double(cv1.frame.maxX), y: cvY, width: Double(totalBarD*0.10), height: cvHeight )
		view.addSubview(cv2)
		
		
		cv3.backgroundColor = orange
		cv3.frame = CGRect(x: Double(cv2.frame.maxX), y: cvY, width: Double(totalBarD*0.15), height: cvHeight )
		view.addSubview(cv3)
		
		
		cv4.backgroundColor = blue
		cv4.frame = CGRect(x: Double(cv3.frame.maxX), y: cvY, width: Double(totalBarD*0.15), height: cvHeight )
		view.addSubview(cv4)
		
		
		cv5.backgroundColor = pink
		cv5.frame = CGRect(x: Double(cv4.frame.maxX), y: cvY, width: Double(totalBarD*0.05), height: cvHeight )
		view.addSubview(cv5)
		
		
		cv6.backgroundColor = blue
		cv6.frame = CGRect(x: Double(cv5.frame.maxX), y: cvY, width: Double(totalBarD*0.05), height: cvHeight )
		view.addSubview(cv6)
		
		
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
	
	//handles the pan of the moving of the slider box
	func handlePan(recognizer:UIPanGestureRecognizer) {
		let translation = recognizer.translation(in: self.view)
		if let view = recognizer.view {
			var newX = view.center.x + translation.x
			newX = max(newX, leftBar.frame.maxX+14)	//sorry about the magic number 14.
													//It's 10+4. 10 from half width, 4 from bar
			newX = min(newX, rightBar.frame.minX-14)
			view.center = CGPoint(x:newX, y: view.center.y)
			
			if (newX < cv1.frame.maxX) {
				graphView.setGraphValues(v1: 5, v2: 45, v3: 5, v4: 5)
			} else if (newX < cv2.frame.maxX) {
				graphView.setGraphValues(v1: 35, v2: 10, v3: 5, v4: 10)
			} else if (newX < cv3.frame.maxX) {
				graphView.setGraphValues(v1: 16, v2: 3, v3: 37, v4: 4)
			} else if (newX < cv4.frame.maxX) {
				graphView.setGraphValues(v1: 35, v2: 8, v3: 11, v4: 6)
			} else if (newX < cv5.frame.maxX) {
				graphView.setGraphValues(v1: 10, v2: 14, v3: 5, v4: 31)
			} else if (newX < cv6.frame.maxX) {
				graphView.setGraphValues(v1: 35, v2: 23, v3: 1, v4: 1)
			} else {
				graphView.setGraphValues(v1: 5, v2: 45, v3: 5, v4: 5)
			}
		}
		recognizer.setTranslation(CGPoint.zero, in: self.view)
	}
	
	
	//sets up the bottom area of the main view
	func setupBottomSection() {
		
		let ivWidth = view.frame.width/2.0-20
		let ivHeight = 0.490797546 * ivWidth
		
		bedroomIV.frame = CGRect(x: 20, y: leftBar.frame.maxY+100, width: ivWidth, height: ivHeight)
		bedroomIV.image = UIImage(named: "bedroomoff.png")
		view.addSubview(bedroomIV)
		
		bathroomIV.frame = CGRect(x: bedroomIV.frame.maxX+10, y: bedroomIV.frame.minY, width: ivWidth, height: ivHeight)
		bathroomIV.image = UIImage(named: "bathroomoff.png")
		view.addSubview(bathroomIV)
		
		kitchenIV.frame = CGRect(x: bedroomIV.frame.maxX+10, y: bedroomIV.frame.maxY + 10, width: ivWidth, height: ivHeight)
		kitchenIV.image = UIImage(named: "kitchenoff.png")
		view.addSubview(kitchenIV)
		
		livingIV.frame = CGRect(x: 20, y: bedroomIV.frame.maxY + 10, width: ivWidth, height: ivHeight)
		livingIV.image = UIImage(named: "livingoff.png")
		view.addSubview(livingIV)
		
	}
	
	//this occurs on ecah touch, mostly used for debugging & testing
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.graphView.setGraphValues(v1: 30.0, v2: 5.0, v3: 10.0, v4: 15.0)
	}
	
	func getGeneralLocationInfo() {
		
		let url = URL(string: "http://23.92.20.162:5000/closestModule/")
		let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
			if error != nil {
				print("Is the server running? Well you better go catch it.")
				return
			}
			let result = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
			
			let closestRoomAsStringWithNum = result?.substring(to: 1)
			
			UIView.animate(withDuration: 0.5, delay: 0.4,
			               options: [.curveEaseInOut],
			               animations: {
							
							if (closestRoomAsStringWithNum == "2") {
								self.turnBathroomOn()
							} else if (closestRoomAsStringWithNum == "4") {
								self.turnBedroomOn()
							} else if (closestRoomAsStringWithNum == "5") {
								self.turnKitchenOn()
							} else if (closestRoomAsStringWithNum == "6") {
								self.turnLivingOn()
							} else {
								print("something's gone wrong!")
							}
			})
		}
		
		task.resume()
	}

//	func getAndSetGrandpaLocationStatus() {
//		let gLocation = ""
//		
//		//LOGIC FOR NAMING LOCATION HERE
//		let url = URL(string: "http://23.92.20.162:5000/get-location/")
//		
//		let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
//			if error != nil {
//				print("Is the server running? Well you better go catch it.")
//				return
//			}
//			let result = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
//			print(result ?? "You can't see this.")
//			
//			
//			
//		}
//		
//		task.resume()
//		
//		
//		//grandpaStatusLabel.text = "Grandpa is currenty in the \(gLocation)"
//	}
	
	func runTimer() {
		let timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.grabModule), userInfo: nil, repeats: true)
		timer.fire()
	}
	
	func grabModule() {
		getGeneralLocationInfo()
	}
	
	func turnBedroomOn() {
		bedroomIV.image = UIImage(named: "bedroomon.png")
		bathroomIV.image = UIImage(named: "bathroomoff.png")
		kitchenIV.image = UIImage(named: "kitchenoff.png")
		livingIV.image = UIImage(named: "livingoff.png")
	}
	
	func turnBathroomOn() {
		bedroomIV.image = UIImage(named: "bedroomoff.png")
		bathroomIV.image = UIImage(named: "bathroomon.png")
		kitchenIV.image = UIImage(named: "kitchenoff.png")
		livingIV.image = UIImage(named: "livingoff.png")
	}
	
	func turnKitchenOn() {
		bedroomIV.image = UIImage(named: "bedroomoff.png")
		bathroomIV.image = UIImage(named: "bathroomoff.png")
		kitchenIV.image = UIImage(named: "kitchenon.png")
		livingIV.image = UIImage(named: "livingoff.png")
	}
	
	func turnLivingOn() {
		bedroomIV.image = UIImage(named: "bedroomoff.png")
		bathroomIV.image = UIImage(named: "bathroomoff.png")
		kitchenIV.image = UIImage(named: "kitchenoff.png")
		livingIV.image = UIImage(named: "livingon.png")
	}
}
