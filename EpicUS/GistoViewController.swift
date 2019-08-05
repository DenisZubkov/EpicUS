//
//  GistoViewController.swift
//  EpicUS
//
//  Created by Denis Zubkov on 18/04/2019.
//  Copyright © 2019 TBM. All rights reserved.
//

import UIKit

class GistoViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    let globalSettings = GlobalSettings()
    let rootViewController = AppDelegate.shared.rootViewController
    var gistoData: [GistoData] = []
    var dataView: [GistoData.Value] = []
    
    var arrayGistoData: [GistoData] = []
    var currentSubPickerArray: [GistoData.Value] = []
    var currentMainPicker = -1 {
        didSet {
                currentSubPickerArray = gistoData[self.currentMainPicker].values
        }
    }
    var currentSubPicker = 0
    var currentHeight = CGFloat(1)
    var allHeight = CGFloat(0)
    var allWidth = CGFloat(0)
    
    var gistoTitle: String = "Состояния ЭПИ"
    var headerLabel = UILabel()
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var gistoView: UIView!
    
    @IBOutlet weak var mainPickerView: UIPickerView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainStackView: UIStackView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        tabBarController?.tabBar.tintColor = .white
        let titleLabel = UILabel()
        titleLabel.text = gistoTitle
        titleLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 17) // Нужный шрифт
        titleLabel.textColor = #colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1)
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.75 // Минимальный относительный размер шрифта
        navigationItem.titleView = titleLabel
        initGistoData()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
    
        mainPickerView.delegate = self
        mainPickerView.dataSource = self
        createHeader()
        currentMainPicker = 0
        mainPickerView.reloadAllComponents()
        dataView = gistoData[currentMainPicker].values
        currentHeight = CGFloat(1)
        drawGisto(height: 1, width: 1)
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        currentHeight = size.height
        drawGisto(height: view.frame.height / size.height , width: view.frame.width / size.width)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return gistoData.count
        } else {
            return gistoData[currentMainPicker].values.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return gistoData[row].name
        } else {
            return gistoData[currentMainPicker].values[row].name
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            currentMainPicker = row
            titleLabel.text = gistoData[row].name
            currentSubPicker = 0
            subTitleLabel.text = gistoData[currentMainPicker].values[currentSubPicker].name
            
            mainPickerView.reloadComponent(1)
            mainPickerView.selectRow(0, inComponent: 1, animated: true)
        } else {
            currentSubPicker = row
            subTitleLabel.text = gistoData[currentMainPicker].values[row].name
        }
        if currentSubPicker == 0 {
            dataView = gistoData[currentMainPicker].values
        } else {
            dataView = gistoData[currentMainPicker].values.filter({$0.name == subTitleLabel.text})
        }
        drawGisto(height: 1, width: 1)
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 12)
            pickerLabel?.textAlignment = .center
        }
        if component == 0 {
            pickerLabel?.text = gistoData[row].name
        } else {
            pickerLabel?.text = gistoData[currentMainPicker].values[row].name
        }
        pickerLabel?.textColor = UIColor.black
        return pickerLabel!
    }
    
    
    
    
    
    func initGistoData() {

    // Ценность
        var values: [GistoData.Value] = []
        var allEus = rootViewController.epicUserStories.count
        var firstEus = rootViewController.epicUserStories.filter({$0.tfsState == "Выполнено"}).count
        var secondEus = rootViewController.epicUserStories.filter({$0.tfsState == "Выполняется"}).count
        var thirdEus = rootViewController.epicUserStories.filter({$0.tfsState == "Новый"}).count
        values.append(GistoData.Value(name: "Все", valuesOne: [GistoData.GistoObject(name: "Выполнено", value: Float(firstEus)),
                                                               GistoData.GistoObject(name: "Выполняется", value: Float(secondEus)),
                                                               GistoData.GistoObject(name: "В очереди", value: Float(thirdEus)),
                                                               GistoData.GistoObject(name: "В работе", value: Float(allEus - firstEus - secondEus - thirdEus))], valuesTwo: []))
        for businessValue in rootViewController.businessValues {
            if let _ = values.filter({$0.name == String(businessValue.value)}).first { continue }
            allEus = rootViewController.epicUserStories.filter({$0.businessValue?.value == businessValue.value}).count
            firstEus = rootViewController.epicUserStories.filter({$0.tfsState == "Выполнено" && $0.businessValue?.value == businessValue.value}).count
            secondEus = rootViewController.epicUserStories.filter({$0.tfsState == "Выполняется" && $0.businessValue?.value == businessValue.value}).count
            thirdEus = rootViewController.epicUserStories.filter({$0.tfsState == "Новый" && $0.businessValue?.value == businessValue.value}).count
            values.append(GistoData.Value(name: String(businessValue.value), valuesOne: [GistoData.GistoObject(name: "Выполнено", value: Float(firstEus)),
                                                                                         GistoData.GistoObject(name: "Выполняется", value: Float(secondEus)),
                                                                                         GistoData.GistoObject(name: "В очереди", value: Float(thirdEus)),
                                                                                         GistoData.GistoObject(name: "В работе", value: Float(allEus - firstEus - secondEus - thirdEus))], valuesTwo: []))
            
        }
        gistoData.append(GistoData(name: "Ценность", values: values))
        
     // Направления
        values = []
        allEus = rootViewController.epicUserStories.count
        firstEus = rootViewController.epicUserStories.filter({$0.tfsState == "Выполнено"}).count
        secondEus = rootViewController.epicUserStories.filter({$0.tfsState == "Выполняется"}).count
        thirdEus = rootViewController.epicUserStories.filter({$0.tfsState == "Новый"}).count
        values.append(GistoData.Value(name: "Все", valuesOne: [GistoData.GistoObject(name: "Выполнено", value: Float(firstEus)),
                                                                  GistoData.GistoObject(name: "Выполняется", value: Float(secondEus)),
                                                                  GistoData.GistoObject(name: "В очереди", value: Float(thirdEus)),
                                                                  GistoData.GistoObject(name: "В работе", value: Float(allEus - firstEus - secondEus - thirdEus))], valuesTwo: []))
        for direction in rootViewController.directions {
            if let _ = values.filter({$0.name == direction.name}).first { continue }
            allEus = rootViewController.epicUserStories.filter({$0.direction == direction}).count
            firstEus = rootViewController.epicUserStories.filter({$0.tfsState == "Выполнено" && $0.direction == direction}).count
            secondEus = rootViewController.epicUserStories.filter({$0.tfsState == "Выполняется" && $0.direction == direction}).count
            thirdEus = rootViewController.epicUserStories.filter({$0.tfsState == "Новый" && $0.direction == direction}).count
            values.append(GistoData.Value(name: direction.name ?? "", valuesOne: [GistoData.GistoObject(name: "Выполнено", value: Float(firstEus)),
                                                                                  GistoData.GistoObject(name: "Выполняется", value: Float(secondEus)),
                                                                                  GistoData.GistoObject(name: "В очереди", value: Float(thirdEus)),
                                                                                  GistoData.GistoObject(name: "В работе", value: Float(allEus - firstEus - secondEus - thirdEus))],valuesTwo: []))
            
        }
        gistoData.append(GistoData(name: "Направления", values: values))
        
        
        // Категория
        values = []
        allEus = rootViewController.epicUserStories.count
        firstEus = rootViewController.epicUserStories.filter({$0.tfsState == "Выполнено"}).count
        secondEus = rootViewController.epicUserStories.filter({$0.tfsState == "Выполняется"}).count
        thirdEus = rootViewController.epicUserStories.filter({$0.tfsState == "Новый"}).count
        values.append(GistoData.Value(name: "Все", valuesOne: [GistoData.GistoObject(name: "Выполнено", value: Float(firstEus)),
                                                                  GistoData.GistoObject(name: "Выполняется", value: Float(secondEus)),
                                                                  GistoData.GistoObject(name: "В очереди", value: Float(thirdEus)),
                                                                  GistoData.GistoObject(name: "В работе", value: Float(allEus - firstEus - secondEus - thirdEus))], valuesTwo: []))
        for category in rootViewController.categories {
            if let _ = values.filter({$0.name == category.name}).first { continue }
            allEus = rootViewController.epicUserStories.filter({$0.category == category}).count
            firstEus = rootViewController.epicUserStories.filter({$0.tfsState == "Выполнено" && $0.category == category}).count
            secondEus = rootViewController.epicUserStories.filter({$0.tfsState == "Выполняется" && $0.category == category}).count
            thirdEus = rootViewController.epicUserStories.filter({$0.tfsState == "Новый" && $0.category == category}).count
            values.append(GistoData.Value(name: category.name ?? "", valuesOne: [GistoData.GistoObject(name: "Выполнено", value: Float(firstEus)),
                                                                                 GistoData.GistoObject(name: "Выполняется", value: Float(secondEus)),
                                                                                 GistoData.GistoObject(name: "В очереди", value: Float(thirdEus)),
                                                                                 GistoData.GistoObject(name: "В работе", value: Float(allEus - firstEus - secondEus - thirdEus))], valuesTwo: []))
            
        }
        gistoData.append(GistoData(name: "Категория", values: values))
        
        // Тактика
        values = []
        allEus = rootViewController.epicUserStories.count
        firstEus = rootViewController.epicUserStories.filter({$0.tfsState == "Выполнено"}).count
        secondEus = rootViewController.epicUserStories.filter({$0.tfsState == "Выполняется"}).count
        thirdEus = rootViewController.epicUserStories.filter({$0.tfsState == "Новый"}).count
        values.append(GistoData.Value(name: "Все", valuesOne: [GistoData.GistoObject(name: "Выполнено", value: Float(firstEus)),
                                                                  GistoData.GistoObject(name: "Выполняется", value: Float(secondEus)),
                                                                  GistoData.GistoObject(name: "В очереди", value: Float(thirdEus)),
                                                                  GistoData.GistoObject(name: "В работе", value: Float(allEus - firstEus - secondEus - thirdEus))], valuesTwo: []))
        for tactic in rootViewController.tactics {
            if let _ = values.filter({$0.name == tactic.name}).first { continue }
            allEus = rootViewController.epicUserStories.filter({$0.tactic == tactic}).count
            firstEus = rootViewController.epicUserStories.filter({$0.tfsState == "Выполнено" && $0.tactic == tactic}).count
            secondEus = rootViewController.epicUserStories.filter({$0.tfsState == "Выполняется" && $0.tactic == tactic}).count
            thirdEus = rootViewController.epicUserStories.filter({$0.tfsState == "Новый" && $0.tactic == tactic}).count
            values.append(GistoData.Value(name: tactic.name ?? "", valuesOne: [GistoData.GistoObject(name: "Выполнено", value: Float(firstEus)),
                                                                               GistoData.GistoObject(name: "Выполняется", value: Float(secondEus)),
                                                                               GistoData.GistoObject(name: "В очереди", value: Float(thirdEus)),
                                                                               GistoData.GistoObject(name: "В работе", value: Float(allEus - firstEus - secondEus - thirdEus))], valuesTwo: []))
            
        }
        gistoData.append(GistoData(name: "Тактика", values: values))
        
        // Цели
        values = []
        allEus = rootViewController.epicUserStories.count
        firstEus = rootViewController.epicUserStories.filter({$0.tfsState == "Выполнено"}).count
        secondEus = rootViewController.epicUserStories.filter({$0.tfsState == "Выполняется"}).count
        thirdEus = rootViewController.epicUserStories.filter({$0.tfsState == "Новый"}).count
        values.append(GistoData.Value(name: "Все", valuesOne: [GistoData.GistoObject(name: "Выполнено", value: Float(firstEus)),
                                                                  GistoData.GistoObject(name: "Выполняется", value: Float(secondEus)),
                                                                  GistoData.GistoObject(name: "В очереди", value: Float(thirdEus)),
                                                                  GistoData.GistoObject(name: "В работе", value: Float(allEus - firstEus - secondEus - thirdEus))], valuesTwo: []))
        for tactic in rootViewController.tactics {
            if let _ = values.filter({$0.name == tactic.strategicTarget?.name}).first { continue }
            allEus = rootViewController.epicUserStories.filter({$0.tactic?.strategicTarget == tactic.strategicTarget}).count
            firstEus = rootViewController.epicUserStories.filter({$0.tfsState == "Выполнено" && $0.tactic?.strategicTarget == tactic.strategicTarget}).count
            secondEus = rootViewController.epicUserStories.filter({$0.tfsState == "Выполняется" && $0.tactic?.strategicTarget == tactic.strategicTarget}).count
            thirdEus = rootViewController.epicUserStories.filter({$0.tfsState == "Новый" && $0.tactic?.strategicTarget == tactic.strategicTarget}).count
            values.append(GistoData.Value(name: tactic.strategicTarget?.name ?? "", valuesOne: [GistoData.GistoObject(name: "Выполнено", value: Float(firstEus)),
                                                                                                GistoData.GistoObject(name: "Выполняется", value: Float(secondEus)),
                                                                                                GistoData.GistoObject(name: "В очереди", value: Float(thirdEus)),
                                                                                                GistoData.GistoObject(name: "В работе", value: Float(allEus - firstEus - secondEus - thirdEus))], valuesTwo: []))
            
        }
        gistoData.append(GistoData(name: "Стратегическая цель", values: values))

    }
    
    
    
    func createHeader() {
        
    }
    
    
    
    
    func drawGisto(height: CGFloat, width: CGFloat) {
        guard dataView.count != 0 else { return }
        
        if height == 1 {
            allHeight = gistoView.frame.height
            allWidth = gistoView.frame.width
        } else {
            allHeight = allHeight / height
            allWidth = allWidth / width
        }
        var mv: Float =  0
        for value in dataView[0].valuesOne {
            mv += value.value
        }
        let maxValue = CGFloat(mv)
        let widthCol = (allWidth / CGFloat(dataView.count))
        for view in gistoView.subviews {
            view.removeFromSuperview()
        }
        if mv == 0 {
            showMessage(title: "Нет данных", message: "Выбирете другие настройки")
            return
        }
        var currentY = CGFloat(0)
        for x in 0..<dataView.count {
            currentY = CGFloat(0)
            for y in 0..<dataView[x].valuesOne.count {
                let newY = CGFloat(dataView[x].valuesOne[y].value) * allHeight / maxValue
                let view = UIView(frame: CGRect.init(x: CGFloat(x) * widthCol + 5,
                                                     y: allHeight - currentY - newY,
                                                     width: widthCol - CGFloat(10),
                                                     height: newY))
                currentY += newY
                view.backgroundColor = #colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1)
                view.alpha = 1 - CGFloat(y) / CGFloat(dataView[x].valuesOne.count)
                gistoView.addSubview(view)
            }
        }
        
    }
    
    func showMessage(title: String, message: String) {
        let alertData = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertData.addAction(cancelAction)
        present(alertData, animated: true, completion: nil)
    }
    
    func createFooter() {
        
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


extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}

//        let viewHeight = headerView.frame.height
//        let viewWidth  = headerView.frame.width
//        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight))
//        lbl.textAlignment = .center //For center alignment
//        lbl.translatesAutoresizingMaskIntoConstraints = false
//        lbl.textColor = .white
//        lbl.backgroundColor = .lightGray//If required
//        lbl.font = UIFont.systemFont(ofSize: 17)
//        lbl.text = gistoData[0].name
//        //To display multiple lines in label
//        lbl.numberOfLines = 0 //If you want to display only 2 lines replace 0(Zero) with 2.
//        lbl.lineBreakMode = .byWordWrapping //Word Wrap
//        // OR
//        lbl.lineBreakMode = .byCharWrapping //Charactor Wrap
//
//        lbl.sizeToFit()//If required
//        headerView.addSubview(lbl)
//        lbl.widthAnchor.constraint(equalTo: headerView.widthAnchor).isActive = true
//        lbl.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
//        lbl.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
