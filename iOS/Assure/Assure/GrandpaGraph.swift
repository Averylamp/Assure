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
		
		//Bars
		let yAxis = UIView(frame: CGRect(x: 44, y: timeTitle.frame.maxY + 5, width: 4, height: 158))
		yAxis.backgroundColor = .black
		self.addSubview(yAxis)
		
		let xAxis = UIView(frame: CGRect(x: 44, y: yAxis.frame.maxY, width: 316, height: 4))
		xAxis.backgroundColor = .black
		self.addSubview(xAxis)
		
		
		
		
		
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		print("please don't use this")
		fatalError("init(coder:) has not been implemented")
	}

}
