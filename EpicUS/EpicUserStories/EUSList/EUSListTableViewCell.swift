//
//  EpicUserStoryListTableViewCell.swift
//  EpicUS
//
//  Created by Denis Zubkov on 15/04/2019.
//  Copyright © 2019 TBM. All rights reserved.
//

import UIKit

class EUSListTableViewCell: UITableViewCell {
    
    var eus: EpicUserStory?
    let globalSettings = GlobalSettings()
    let rootViewController = AppDelegate.shared.rootViewController

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var number1CLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var dateBeginLabel: UILabel!
    @IBOutlet weak var dateEndLabel: UILabel!
    @IBOutlet weak var timeFactLabel: UILabel!
    @IBOutlet weak var storePointsAnaliticPlan: UILabel!
    @IBOutlet weak var storePointsDevPlan: UILabel!
    @IBOutlet weak var storePointsPlan: UILabel!
    @IBOutlet weak var storePointsDevFact: UILabel!
    @IBOutlet weak var storePointsFact: UILabel!
    @IBOutlet weak var tfsIdLabel: UILabel!
    
    @IBOutlet weak var storePointsAnaliticFact: UILabel!
    
    @IBAction func sendDataTo1CButton(_ sender: UIButton) {
        
        guard let sendEus = eus else { return }
        rootViewController.createPatchQuery(eus: sendEus)
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
