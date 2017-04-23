//
//  AlertTableViewCell.swift
//  Assure
//
//  Created by Avery Lamp on 4/23/17.
//  Copyright © 2017 Avery Lamp. All rights reserved.
//

import UIKit

class AlertTableViewCell: UITableViewCell {

    @IBOutlet weak var alertLabel: UILabel!
    
    @IBOutlet weak var onWayButton: UIButton!
    
    @IBOutlet weak var resolvedButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
