//
//  QuotasListViewController.swift
//  EpicUS
//
//  Created by Denis Zubkov on 26/04/2019.
//  Copyright © 2019 TBM. All rights reserved.
//

import UIKit

class QuotasListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let globalSettings = GlobalSettings()
    let rootViewController = AppDelegate.shared.rootViewController
    
    var gistoData: [GistoData] = []
    var dataView: [GistoData.Value] = []
    var index: Int = 0

    
    
    
    
    @IBOutlet weak var legendaView: UIView!
    @IBOutlet weak var gistoView: UIView!
    @IBOutlet weak var directionListTableView: UITableView!
    
    @IBAction func refreshDataButton(_ sender: UIBarButtonItem) {
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initGistoData()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        dataView = gistoData[0].values
        drawGisto()
        drawLegenda()
        directionListTableView.reloadData()
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataView.count == 0 {
            return 0
        }
        return dataView[0].valuesOne.count > dataView[0].valuesTwo.count ? dataView[0].valuesOne.count : dataView[0].valuesTwo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuotasListCell", for: indexPath) as! QuotasListTableViewCell
        let index = indexPath.row
        if dataView[0].valuesOne.count > index {
            cell.valueOneColorLabel.backgroundColor = globalSettings.firstColor
            cell.valueOneColorLabel.alpha = 1 - CGFloat(index) / CGFloat(dataView[0].valuesOne.count)
            cell.valueOneLabel.text = dataView[0].valuesOne[index].name
        } else {
            cell.valueOneColorLabel.isHidden = true
            cell.valueOneLabel.isHidden = true
        }
        if dataView[0].valuesTwo.count > index {
            cell.valueTwoColorLabel.backgroundColor = globalSettings.thirdColor
            cell.valueTwoColorLabel.alpha = 1 - CGFloat(index) / CGFloat(dataView[0].valuesTwo.count)
            cell.valueTwoLabel.text = dataView[0].valuesTwo[index].name
            
        } else {
            cell.valueTwoColorLabel.isHidden = true
            cell.valueTwoLabel.isHidden = true
        }
        
        return cell
    }

    func initGistoData() {
        
        //Quotas
        var values: [GistoData.Value] = []
        for direction in rootViewController.directions {
            var quarts = rootViewController.quotas.filter({$0.direction == direction})
            quarts = quarts.sorted(by: {$0.quart! < $1.quart!})
            var value = GistoData.Value(name: direction.small ?? "None", valuesOne: [], valuesTwo: [])
            for quart in quarts {
                let quartName = "\(rootViewController.getQuart(from: quart.quart)) квартал"
                if let quota = rootViewController.quotas.filter({$0.direction == direction && $0.quart == quart.quart}).first {
                    value.valuesOne.append(GistoData.GistoObject(name: quartName, value: Float(quota.storePointAnaliticPlan) + Float(quota.storePointDevPlan)))
                }
            }
            for state in rootViewController.states {
               let euses = rootViewController.epicUserStories.filter({$0.state == state && $0.direction == direction})
                var sumFact: Float = 0
                var sumPlan: Float = 0
                for eus in euses {
                    sumFact = sumFact + Float(eus.tfsStorePointDevFact) + Float(eus.tfsStorePointAnaliticFact)
                    if let spa = Float(eus.storePointsDevPlane ?? "0") {
                        sumPlan = sumPlan + spa
                    }
                    if let spd = Float(eus.storePointsAnaliticPlane ?? "0") {
                        sumPlan = sumPlan + spd
                    }
                }
                value.valuesTwo.append(GistoData.GistoObject(name: state.name ?? "", value: sumFact == 0 ? sumPlan : sumFact))
            }
            
            values.append(value)
        }
        gistoData.append(GistoData(name: "Квоты", values: values))
    }
    
    func drawGisto() {
        
        guard dataView.count != 0 else { return }
        let isTwoValues = dataView[0].valuesTwo.count != 0
        var mv: Float =  0
        for value in dataView[0].valuesOne {
            mv += value.value
        }
        var maxValue = CGFloat(mv)
        mv = 0
        if isTwoValues {
            for value in dataView[0].valuesTwo {
                mv += value.value
            }
            if maxValue < CGFloat(mv) {
                maxValue = CGFloat(mv)
            }
        }
        let widthCol = (gistoView.frame.width / CGFloat(dataView.count)) / CGFloat((isTwoValues ? 2 : 1))
        for view in gistoView.subviews {
            view.removeFromSuperview()
        }
        if maxValue == 0 {
            showMessage(title: "Нет данных", message: "Выбирете другие настройки")
            return
        }
        var currentY = CGFloat(0)
        for x in 0..<dataView.count {
            currentY = CGFloat(0)
            for y in 0..<dataView[x].valuesOne.count {
                let newY = CGFloat(dataView[x].valuesOne[y].value) * gistoView.frame.height / maxValue
                let view = UIView(frame: CGRect.init(x: CGFloat(x) * widthCol * 2 + 5,
                                                     y: gistoView.frame.height - currentY - newY,
                                                     width: widthCol,
                                                     height: newY))
                currentY += newY
                view.backgroundColor = globalSettings.firstColor
                view.alpha = 1 - CGFloat(y) / CGFloat(dataView[x].valuesOne.count)
                gistoView.addSubview(view)
            }
        }
        for x in 0..<dataView.count {
            currentY = CGFloat(0)
            for y in 0..<dataView[x].valuesTwo.count {
                let newY = CGFloat(dataView[x].valuesTwo[y].value) * gistoView.frame.height / maxValue
                let view = UIView(frame: CGRect.init(x: widthCol + CGFloat(x) * widthCol * 2 + 5,
                                                     y: gistoView.frame.height - currentY - newY,
                                                     width: widthCol - CGFloat(10),
                                                     height: newY))
                currentY += newY
                view.backgroundColor = globalSettings.thirdColor
                view.alpha = 1 - CGFloat(y) / CGFloat(dataView[x].valuesTwo.count)
                gistoView.addSubview(view)
            }
        }
        
    }
    
    func drawLegenda() {
        
        guard dataView.count != 0 else { return }
       
        
        let widthCol = (legendaView.frame.width / CGFloat(dataView.count))
        for view in legendaView.subviews {
            view.removeFromSuperview()
        }
        for x in 0..<dataView.count {
            let view = UIView(frame: CGRect.init(x: CGFloat(x) * widthCol + 5,
                                                     y: 0,
                                                     width: widthCol - CGFloat(10),
                                                     height: legendaView.frame.height-10))
            view.backgroundColor = globalSettings.secondColor
            view.layer.borderWidth = 1
            view.layer.borderColor = globalSettings.firstCGColor
            view.layer.cornerRadius = 2
            let frame = CGRect(x: 0, y: 0, width: widthCol - CGFloat(10), height: legendaView.frame.height - 10)
            let titleLabel = UILabel(frame: frame)
            titleLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 11)
            titleLabel.text = dataView[x].name
            titleLabel.textColor = globalSettings.firstColor
            titleLabel.adjustsFontSizeToFitWidth = true
            titleLabel.textAlignment = .center
            titleLabel.minimumScaleFactor = 0.75 // Минимальный относительный размер шрифта
            view.addSubview(titleLabel)
            
            let directionButton = UIButton(frame: frame)
            directionButton.addTarget(self, action: #selector(directionSelect), for: .touchUpInside)
            directionButton.tag = x
            view.addSubview(directionButton)
            legendaView.addSubview(view)
        }
        
    }
    
    @objc func directionSelect(sender: UIButton!) {
        print("Button tapped \(dataView[sender.tag].name)")
        index = sender.tag
        performSegue(withIdentifier: "DirectionDetailSegue", sender: nil)
    }
    
    
    
    
    func showMessage(title: String, message: String) {
        let alertData = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertData.addAction(cancelAction)
        present(alertData, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DirectionDetailSegue" {
            let dvc = segue.destination as! DirectionDetailViewController
            dvc.direction = rootViewController.directions[index]
            dvc.quota = gistoData[0].values[index]
        }
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
