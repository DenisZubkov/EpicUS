//
//  ReportViewController.swift
//  EpicUS
//
//  Created by Denis Zubkov on 17/04/2019.
//  Copyright © 2019 TBM. All rights reserved.
//

import UIKit

class ReportViewController: UIViewController {

    let globalSettings = GlobalSettings()
    let rootViewController = AppDelegate.shared.rootViewController
    var currentBusinessValue: Int32 = 0
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var lastView: UIView!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var thirdView: UIView!
    
    @IBOutlet weak var firstHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var thirdHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var thirdLabel: UILabel!
    @IBOutlet weak var lastLabel: UILabel!
    
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var businessValueSegmentControl: UISegmentedControl!
    @IBAction func businessValueChangedSegmentControl(_ sender: UISegmentedControl) {
        
        switch businessValueSegmentControl.selectedSegmentIndex {
        case 0:
            currentBusinessValue = 0
        case 1:
            currentBusinessValue = 8
        case 2:
            currentBusinessValue = 16
        case 3:
            currentBusinessValue = 32
        case 4:
            currentBusinessValue = 64
        case 5:
            currentBusinessValue = 128
        default:
            currentBusinessValue = 0
        }
        countEusState()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        countEusState()
    }

    
    func countEusState() {
        var allEus = rootViewController.epicUserStories.count
        var firstEus = rootViewController.epicUserStories.filter({$0.tfsState == "Выполнено"}).count
        var secondEus = rootViewController.epicUserStories.filter({$0.tfsState == "Выполняется"}).count
        var thirdEus = rootViewController.epicUserStories.filter({$0.tfsState == "Новый"}).count
        
        
        if currentBusinessValue != 0 {
            allEus = rootViewController.epicUserStories.filter({$0.businessValue?.value == currentBusinessValue}).count
            firstEus = rootViewController.epicUserStories.filter({$0.tfsState == "Выполнено" && $0.businessValue?.value == currentBusinessValue}).count
            secondEus = rootViewController.epicUserStories.filter({$0.tfsState == "Выполняется" && $0.businessValue?.value == currentBusinessValue}).count
            thirdEus = rootViewController.epicUserStories.filter({$0.tfsState == "Новый" && $0.businessValue?.value == currentBusinessValue}).count
        }
        let allHeght = mainView.frame.height
        
        firstLabel.text = "Выполнено \(firstEus) ЭПИ"
        secondLabel.text = "Выполняются \(secondEus) ЭПИ"
        thirdLabel.text = "В очереди \(thirdEus) ЭПИ"
        mainLabel.text = "Всего \(allEus) ЭПИ"
        lastLabel.text = "Подготавливаются в 1С \(allEus - firstEus - secondEus - thirdEus) ЭПИ"
        firstHeightConstraint.constant = CGFloat(firstEus) * allHeght / CGFloat(allEus)
        secondHeightConstraint.constant = CGFloat(secondEus) * allHeght / CGFloat(allEus)
        thirdHeightConstraint.constant = CGFloat(thirdEus) * allHeght / CGFloat(allEus)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
