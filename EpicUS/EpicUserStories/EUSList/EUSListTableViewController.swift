//
//  EUSListTableViewController.swift
//  EpicUS
//
//  Created by Denis Zubkov on 15/04/2019.
//  Copyright © 2019 TBM. All rights reserved.
//

import UIKit
import CoreData

class EUSTableViewController: UITableViewController {
    
    let globalSettings = GlobalSettings()
    let rootViewController = AppDelegate.shared.rootViewController
    var direction: Direction?
    var quart = 1
    var eusState: State?
    var epicUserStories: [EpicUserStory] = []
    
    @IBAction func send1cButton(_ sender: Any) {
        
        for eus in rootViewController.epicUserStories {
            rootViewController.createPatchQuery(eus: eus)
            
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        epicUserStories = rootViewController.epicUserStories.filter({$0.direction == direction && rootViewController.getQuart(from: $0.tfsEndDate) ==  quart && $0.state == eusState})
        epicUserStories = epicUserStories.sorted(by: {$0.tfsEndDate! < $1.tfsEndDate!})
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return epicUserStories.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EUSListSell", for: indexPath) as! EUSListTableViewCell
        let eus = epicUserStories[indexPath.row]
        cell.eus = eus
        cell.nameLabel.text = eus.name
        cell.number1CLabel.text = eus.num
        cell.valueLabel.text = "\(eus.businessValue?.value ?? 128)"
        cell.tfsIdLabel.text = "\(eus.tfsId)"
        cell.statusLabel.text = eus.state?.name
        cell.dateEndLabel.text = globalSettings.dateToString(date: eus.tfsEndDate)
        cell.dateBeginLabel.text = globalSettings.dateToString(date: eus.tfsBeginDate)
        cell.directionLabel.text = eus.direction?.name
        
        let dateEnd: Date = eus.tfsEndDate ?? Date()
        let dateBegin: Date = eus.tfsBeginDate ?? (eus.tfsDateCreate ?? Date())
        cell.timeFactLabel.text = "\(Int(dateEnd.timeIntervalSince(dateBegin) / 24 / 60 / 60))"
        
        let storePointsAnaliticPlane = Double(eus.storePointsAnaliticPlane ?? "0") ?? Double(0)
        let storePointsDevPlane = Double(eus.storePointsDevPlane ?? "0") ?? Double(0)
        cell.storePointsAnaliticPlan.text = "\(storePointsAnaliticPlane)"
        cell.storePointsDevPlan.text = "\(storePointsDevPlane)"
        cell.storePointsPlan.text = "\(storePointsDevPlane + storePointsAnaliticPlane)"
        
        cell.storePointsAnaliticFact.text = "\(eus.tfsStorePointAnaliticFact)"
        cell.storePointsDevFact.text = "\(eus.tfsStorePointDevFact)"
        cell.storePointsFact.text = "\(eus.tfsStorePointFact)"
        
        
        // Configure the cell...
        
        return cell
    }
    
    
    
    
    
    
}
