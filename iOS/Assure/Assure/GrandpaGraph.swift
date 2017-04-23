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
		
		//Labels
		let graphLabel1 = UILabel(frame: CGRect(x: 50, y: xAxis.frame.maxY + 5, width: 76, height: 16))
		graphLabel1.text = "Bedroom"
		graphLabel1.textAlignment = NSTextAlignment.center
		graphLabel1.font = UIFont (name: "Avenir-Book", size: 12)
		self.addSubview(graphLabel1)
		
		let graphLabel2 = UILabel(frame: CGRect(x: 126, y: xAxis.frame.maxY + 5, width: 76, height: 16))
		graphLabel2.text = "Living Room"
		graphLabel2.textAlignment = NSTextAlignment.center
		graphLabel2.font = UIFont (name: "Avenir-Book", size: 12)
		self.addSubview(graphLabel2)
		
		let graphLabel3 = UILabel(frame: CGRect(x: 202, y: xAxis.frame.maxY + 5, width: 76, height: 16))
		graphLabel3.text = "Kitchen"
		graphLabel3.textAlignment = NSTextAlignment.center
		graphLabel3.font = UIFont (name: "Avenir-Book", size: 12)
		self.addSubview(graphLabel3)
		
		let graphLabel4 = UILabel(frame: CGRect(x: 280, y: xAxis.frame.maxY + 5, width: 76, height: 16))
		graphLabel4.text = "Bathroom"
		graphLabel4.textAlignment = NSTextAlignment.center
		graphLabel4.font = UIFont (name: "Avenir-Book", size: 12)
		self.addSubview(graphLabel4)
		
		
		
		
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		print("please don't use this")
		fatalError("init(coder:) has not been implemented")
	}

}
