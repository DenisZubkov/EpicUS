//
//  EUSWorkListTableViewController.swift
//  EpicUS
//
//  Created by Denis Zubkov on 06/06/2019.
//  Copyright © 2019 TBM. All rights reserved.
//

import UIKit

class EUSWorkListTableViewController: UITableViewController {

    let globalSettings = GlobalSettings()
    let rootViewController = AppDelegate.shared.rootViewController
    var direction: Direction?
    var quart = 1
    var eusState: State?
    var eusWorkList: [EpicUserStory] = []
    var priorityArray: [Int32] = []
    var priorityChanged = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eusWorkList = rootViewController.epicUserStories.filter({$0.direction == direction && ($0.tfsState == "Выполняется" || $0.tfsState == "Новый" || ($0.tfsId == 0 && $0.num ?? "" != "" ))})
        
        eusWorkList = eusWorkList.sorted(by: { (eus1, eus2) in
            var priority1 = eus1.tfsPriority
            var priority2 = eus2.tfsPriority
            
            if priority1 == 0 { priority1 = eus1.priority }
            if priority1 == 0 { priority1 = 1000 }
            
            if priority2 == 0 { priority2 = eus2.priority }
            if priority2 == 0 { priority2 = 1000 }
           return priority1 < priority2
            
        })
        for eus in eusWorkList {
         priorityArray.append(eus.tfsPriority)
        }
        navigationItem.rightBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem?.title = "Правка"

    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    override func setEditing (_ editing:Bool, animated:Bool)
    {
        super.setEditing(editing,animated:animated)
        if(self.isEditing)
        {
            self.editButtonItem.title = "Готово"
        }else
        {
            self.editButtonItem.title = "Правка"
            savePriorityToTFS()
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedEUS = eusWorkList.remove(at: sourceIndexPath.row)
        eusWorkList.insert(movedEUS, at: destinationIndexPath.row)
        let movedPriority = priorityArray.remove(at: sourceIndexPath.row)
        priorityArray.insert(movedPriority, at: destinationIndexPath.row)
        for priority in 0..<eusWorkList.count {
            eusWorkList[priority].tfsPriority = Int32(priority + 1)
        }
        priorityChanged = true
        tableView.reloadData()
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return eusWorkList.count
    }
    
    

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EUSWorkListCell", for: indexPath) as! EUSWorkListTableViewCell
        let eus = eusWorkList[indexPath.row]
        if eus.tfsId == 0 {
             cell.alpha = 0.5
             cell.backgroundColor = #colorLiteral(red: 0.6682192087, green: 0.6646783948, blue: 0.6686597466, alpha: 1)
        } else if eus.tfsState == "Новый" {
             cell.alpha = 0.75
             cell.backgroundColor = #colorLiteral(red: 0.249651432, green: 0.6727126837, blue: 0.6839100718, alpha: 1)
        } else {
            cell.alpha = 1
            cell.backgroundColor = #colorLiteral(red: 0.1761377156, green: 0.5700153708, blue: 0.5768356919, alpha: 1)
        }
        cell.productLabel.text = eus.product?.name
        if let startIndex = eus.tfsCategory?.startIndex,
            let char = eus.tfsCategory?[startIndex] {
            cell.categoryLabel.text = String(char)
        }
        cell.categoryLabel.layer.cornerRadius = 5
        cell.categoryLabel.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        cell.categoryLabel.layer.borderWidth = 2
        cell.categoryLabel.clipsToBounds = true
        cell.priorityLabel.text = "\(eus.tfsPriority)"
        cell.priorityLabel.layer.cornerRadius = 5
        cell.priorityLabel.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        cell.priorityLabel.layer.borderWidth = 1
        cell.priorityLabel.clipsToBounds = true
        cell.nameLabel.text  = eus.name
        cell.num1cLabel.text  = "\(eus.num ?? "")"
        cell.numTFSLabel.text = "\(eus.tfsId)"
        cell.datebegin1СLabel.text = globalSettings.dateToString(date: eus.dateCreate)
        cell.dateBeginTFSLabel.text  = globalSettings.dateToString(date: eus.tfsBeginDate)
        cell.businessValueLabel.text = "\(eus.businessValue?.value ?? Int32(128))"
        cell.normDaysLabel.text = "Н: \(eus.businessValue?.days ?? Int32(1000)) дн."
        cell.factDaysLabel.text = "Ф: \(rootViewController.numDay(from: eus.tfsBeginDate ?? Date(), to: eus.tfsEndDate ?? Date())) дн."
        if eus.tfsId != 0 {
            cell.productOwnerLabel.text = eus.tfsProductOwner
        }   else {
            cell.productOwnerLabel.text = eus.productOwner?.fio
        }
        cell.storePointsLabel.layer.cornerRadius = 5
        cell.storePointsLabel.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        cell.storePointsLabel.layer.borderWidth = 2
        cell.storePointsLabel.clipsToBounds = true
        if eus.tfsId == 0 {
            if let a = Int(eus.storePointsAnaliticPlane ?? "0"), let b = Int(eus.storePointsDevPlane ?? "0") {
                cell.storePointsLabel.text = " \(a) + \(b) = \(a + b)  "
            }
            else {
                cell.storePointsLabel.text = " 0 + 0 = 0 "
            }
        } else {
        cell.storePointsLabel.text = " \(Int(eus.tfsStorePointAnaliticPlan)) + \(Int(eus.tfsStorePointDevPlan)) = \(Int(eus.tfsStorePointAnaliticPlan) + Int(eus.tfsStorePointDevPlan))  "
        }
        if eus.deathLine == nil {
            cell.deathLineLabel.isHidden = true
        } else {
            cell.deathLineLabel.text = globalSettings.dateToString(date: eus.deathLine)
        }
        cell.stateLabel.text = getStateEus(eus: eus)
        // Configure the cell...

        return cell
    }
 
    func getStateEus(eus: EpicUserStory) -> String {
        let workItems = rootViewController.treeWorkItems.filter({$0.parentId == eus.tfsId})
        let workItemArrayId = workItems.map({(workItem) -> Int32? in
            return workItem.id})
        let workItemArrayParent = workItems.map({(workItem) -> Bool in
            return workItem.parentId == eus.tfsId })
        let workItemSeq = zip(workItemArrayId, workItemArrayParent)
        let workItemDict = Dictionary(workItemSeq, uniquingKeysWith:{return $1})
        let userStories = rootViewController.userStories.filter { (userStory) -> Bool in
            guard let isChild = workItemDict[userStory.id] else { return false }
            return isChild
        }
        if eus.tfsState == "Новый" {
            return "Работа не начата"
        }
        if eus.tfsId == 0 {
            return "На согласовании в 1С"
        }
        if eus.tfsState == "Выполнено" {
            return "Выполнено"
        }
        for i in userStories {
            //print("\(eus.tfsId): \(i.tfsState) \(i.title) \(i.tfsTeam) \(i.tfsSprintName) \(i.userStoryType?.name) \(eus.tfsProductOwner)")
            if i.tfsState == "Новый"  && i.userStoryType?.id == "[STOP" {
                return i.userStoryType?.name ?? "Неопределено"
            }
            if i.tfsState == "Новый"  && (i.userStoryType?.id == "[WAIT" || i.userStoryType?.id == "[VP") {
                return i.userStoryType?.name ?? "Неопределено"
            }
//            if eus.tfsId == Int32(3801) {
//                print(eus.name)
//            }
            for type in rootViewController.userStoryTypes {
                if i.tfsState == "Новый" && i.userStoryType == type && i.tfsSprintName == "ТБМ" {
                    return "Ожидает: \(i.userStoryType?.name ?? "Неопределено")"
                }
                if i.tfsState == "Одобрено" && i.userStoryType == type {
                    return i.userStoryType?.name ?? "Неопределено"
                }
                
                if i.tfsState == "Новый" && i.userStoryType == type && i.tfsSprintName != "ТБМ" {
                    return i.userStoryType?.name ?? "Неопределено"
                }
                
            }
            
        }
        print()
        return "Ожидает приемки ВП"
       
    }

    func savePriorityToTFS() {
        //Step : 1
        if priorityChanged {
            priorityChanged = false
            let alert = UIAlertController(title: "Приоритет", message: "Сохранить текущие приоритеты в TFS?", preferredStyle: UIAlertController.Style.alert)
            //Step : 2
            let save = UIAlertAction(title: "Сохранить", style: .default) { (alertAction) in
                self.sendToTFS()
            }
            alert.addAction(save)
            //Cancel action
            let cancel = UIAlertAction(title: "Отменить", style: .default) { (alertAction) in
                for i in 0..<self.eusWorkList.count {
                    self.eusWorkList[i].tfsPriority = self.priorityArray[i]
                }
                self.eusWorkList = self.eusWorkList.sorted(by: { (eus1, eus2) in
                    var priority1 = eus1.tfsPriority
                    var priority2 = eus2.tfsPriority
                    
                    if priority1 == 0 { priority1 = eus1.priority }
                    if priority1 == 0 { priority1 = 1000 }
                    
                    if priority2 == 0 { priority2 = eus2.priority }
                    if priority2 == 0 { priority2 = 1000 }
                    return priority1 < priority2
                    
                })
                self.tableView.reloadData()
            }
            alert.addAction(cancel)
            
            self.present(alert, animated:true, completion: nil)
        }
    }
    
    
    func sendToTFS() {
        
        for i in 0..<self.eusWorkList.count {
            var level: Int32 = 3
            if eusWorkList[i].tfsId != 0 {
                self.priorityArray[i] = self.eusWorkList[i].tfsPriority
                rootViewController.addTreeWorkItems(level: &level, context: rootViewController.context, tfsId: eusWorkList[i].tfsId)
            }
            do {
                try rootViewController.context.save()
            } catch let error as NSError {
                print(error.localizedDescription)
                return
            }
        }
        
        print("Save")
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
