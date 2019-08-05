//
//  EUSWorkListTableViewCell.swift
//  EpicUS
//
//  Created by Denis Zubkov on 06/06/2019.
//  Copyright © 2019 TBM. All rights reserved.
//

import UIKit

class EUSWorkListTableViewCell: UITableViewCell {

    @IBOutlet weak var num1cLabel: UILabel!
    @IBOutlet weak var datebegin1СLabel: UILabel!
    @IBOutlet weak var numTFSLabel: UILabel!
    @IBOutlet weak var dateBeginTFSLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var businessValueLabel: UILabel!
    @IBOutlet weak var factDaysLabel: UILabel!
    @IBOutlet weak var normDaysLabel: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var productOwnerLabel: UILabel!
    @IBOutlet weak var storePointsLabel: UILabel!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var deathLineLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
