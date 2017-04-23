//
//  GrandpaGraph.swift
//  Assure
//
//  Created by Kenneth Friedman on 4/22/17.
//  Copyright © 2017 Avery Lamp. All rights reserved.
//

import UIKit

class GrandpaGraph: UIView {

	let timeTitle = UILabel()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		//Title
		let grandpaTitle = UILabel(frame: CGRect(x: 0, y: 2, width: self.frame.width, height: 25))
		grandpaTitle.text = "Grandpa's Activity"
		grandpaTitle.textAlignment = NSTextAlignment.center
		grandpaTitle.font = UIFont (name: "Avenir-Book", size: 20)
		self.addSubview(grandpaTitle)
		
		//Time
		let timeTitle = UILabel(frame: CGRect(x: 0, y: grandpaTitle.frame.maxY + 2 , width: self.frame.width, height: 50))
		timeTitle.text = "1pm to 2pm"
		timeTitle.textAlignment = NSTextAlignment.center
		timeTitle.font = UIFont (name: "Avenir-Book", size: 20)
		self.addSubview(timeTitle)
		
		//Axis
		let yAxis = UIView(frame: CGRect(x: 44, y: timeTitle.frame.maxY + 5, width: 4, height: 158))
		yAxis.backgroundColor = .black
		self.addSubview(yAxis)
		
		let xAxis = UIView(frame: CGRect(x: 44, y: yAxis.frame.maxY, width: 316, height: 4))
		xAxis.backgroundColor = .black
		self.addSubview(xAxis)
		
		//Label Constants
		let labelY = xAxis.frame.maxY + 5
		
		//Labels
		let graphLabel1 = UILabel(frame: CGRect(x: 50, y: labelY, width: 76, height: 16))
		graphLabel1.text = "Bedroom"
		graphLabel1.textAlignment = NSTextAlignment.center
		graphLabel1.font = UIFont (name: "Avenir-Book", size: 12)
		self.addSubview(graphLabel1)
		
		let graphLabel2 = UILabel(frame: CGRect(x: 126, y: labelY, width: 76, height: 16))
		graphLabel2.text = "Living Room"
		graphLabel2.textAlignment = NSTextAlignment.center
		graphLabel2.font = UIFont (name: "Avenir-Book", size: 12)
		self.addSubview(graphLabel2)
		
		let graphLabel3 = UILabel(frame: CGRect(x: 202, y: labelY, width: 76, height: 16))
		graphLabel3.text = "Kitchen"
		graphLabel3.textAlignment = NSTextAlignment.center
		graphLabel3.font = UIFont (name: "Avenir-Book", size: 12)
		self.addSubview(graphLabel3)
		
		let graphLabel4 = UILabel(frame: CGRect(x: 280, y: labelY, width: 76, height: 16))
		graphLabel4.text = "Bathroom"
		graphLabel4.textAlignment = NSTextAlignment.center
		graphLabel4.font = UIFont (name: "Avenir-Book", size: 12)
		self.addSubview(graphLabel4)
		
		//bars
		
		let graphBar1 = UIView(frame: CGRect(x: 57, y: xAxis.frame.minY-100, width: 65, height: 100))
		graphBar1.backgroundColor = UIColor(colorLiteralRed: 114/255.0, green: 160/255.0, blue: 235/255.0, alpha: 1)
		self.addSubview(graphBar1)
		
		let graphBar2 = UIView(frame: CGRect(x: 133, y: xAxis.frame.minY-100, width: 65, height: 100))
		graphBar2.backgroundColor = UIColor(colorLiteralRed: 104/255.0, green: 209/255.0, blue: 184/255.0, alpha: 1)
		self.addSubview(graphBar2)
		
		let graphBar3 = UIView(frame: CGRect(x: 208, y: xAxis.frame.minY-100, width: 65, height: 100))
		graphBar3.backgroundColor = UIColor(colorLiteralRed: 245/255.0, green: 166/255.0, blue: 35/255.0, alpha: 1)
		self.addSubview(graphBar3)
		
		let graphBar4 = UIView(frame: CGRect(x: 283, y: xAxis.frame.minY-100, width: 65, height: 100))
		graphBar4.backgroundColor = UIColor(colorLiteralRed: 255/255.0, green: 140/255.0, blue: 154/255.0, alpha: 1)
		self.addSubview(graphBar4)
		
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		print("please don't use this")
		fatalError("init(coder:) has not been implemented")
	}

}
