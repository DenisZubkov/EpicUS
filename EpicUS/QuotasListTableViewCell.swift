//
//  QuotasListTableViewCell.swift
//  EpicUS
//
//  Created by Denis Zubkov on 26/04/2019.
//  Copyright © 2019 TBM. All rights reserved.
//

import UIKit

class QuotasListTableViewCell: UITableViewCell {

    
    @IBOutlet weak var valueOneLabel: UILabel!
    @IBOutlet weak var valueOneColorLabel: UILabel!
    @IBOutlet weak var valueTwoColorLabel: UILabel!
    @IBOutlet weak var valueTwoLabel: UILabel!
    
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
