//: Playground - noun: a place where people can play

import UIKit


XCPSetExecutionShouldContinueIndefinitely()

let url = URL(string: "http://23.92.20.162/get-location/")

let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
	
	let result = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
	print(result)
}

task.resume()
