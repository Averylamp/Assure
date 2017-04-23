//
//  AlertViewController.swift
//  Assure
//
//  Created by Avery Lamp on 4/23/17.
//  Copyright © 2017 Avery Lamp. All rights reserved.
//

import UIKit
import Parse

class AlertViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var alerts = [PFObject]()
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        fetchAlerts()
        
        // Do any additional setup after loading the view.
    }
    
    func fetchAlerts(){
        let query = PFQuery(className: "Alerts")
        query.addDescendingOrder("createdAt")
        query.findObjectsInBackground { (results, error) in
            if error == nil {
                if results != nil {
                    self.alerts = results!
                    self.tableView.reloadData()
                }
                print(results)
            }else{
                print("Error fetching from Parse -\(error)")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table View Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alerts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlertCell") as! AlertTableViewCell
        
        cell.resolvedButton.layer.borderWidth = 2
        cell.resolvedButton.layer.borderColor = UIColor.black.cgColor
        cell.alertLabel.text = alerts[indexPath.row].value(forKey: "alertMessage") as? String
        cell.onWayButton.setTitle(alerts[indexPath.row].value(forKey: "positiveResponse") as? String, for: .normal)
        cell.onWayButton.tag = indexPath.row
        cell.resolvedButton.tag = indexPath.row
        
        cell.onWayButton.addTarget(self, action: #selector(AlertViewController.sendPositiveResposne(sender:)), for: .touchUpInside)
        cell.resolvedButton.addTarget(self, action: #selector(AlertViewController.dismissAlert(sender:)), for: .touchUpInside)
        
        if alerts[indexPath.row]["dismissed"] as? Bool == true {
            cell.coverView.alpha = 0.2
        }else{
            cell.coverView.alpha = 0.0
        }
        return cell
    }
    
    func dismissAlert(sender:UIButton){
        alerts[sender.tag]["dismissed"] = true
        alerts[sender.tag]["viewed"] = true
        alerts[sender.tag].saveInBackground()
        UIView.animate(withDuration: 1.0) {
            (self.tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! AlertTableViewCell).coverView.alpha = 0.2
        }
        
    }
    
    func sendPositiveResposne(sender:UIButton){
        dismissAlert(sender: sender)
        let url = URL(string: "http://23.92.20.162:5000/positiveResponse/")
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            if error != nil {
                print("Is the server running? Well you better go catch it.")
                return
            }
            let result = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print(result)
        }
        task.resume()
    }
    @IBAction func backClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
