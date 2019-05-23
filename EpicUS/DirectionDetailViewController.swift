//
//  DirectionDetailViewController.swift
//  EpicUS
//
//  Created by Denis Zubkov on 07/05/2019.
//  Copyright © 2019 TBM. All rights reserved.
//

import UIKit

class DirectionDetailViewController: UIViewController {
    
    let globalSettings = GlobalSettings()
    let rootViewController = AppDelegate.shared.rootViewController
    
    var quota: GistoData.Value?
    var direction: Direction?
    var planFactQuota: [GistoData.PlanFactData] = []
    var currentQuart = 1
    var currentState: State?

    @IBOutlet weak var quotaPlanView: UIView!
    @IBOutlet weak var quotaFactView: UIView!
    @IBOutlet weak var quotaWorkView: UIView!
    @IBOutlet weak var quotaQueueView: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let titleLabel = UILabel()
        titleLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 17) // Нужный шрифт
        titleLabel.textColor = globalSettings.firstColor
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.75 // Минимальный относительный размер шрифта
        titleLabel.text = direction?.name
        navigationItem.titleView = titleLabel
        initPlanFactQuota()
        //drawPlanFactQuota(viewContainerQuota: quotaPlanView, viewContainerFact: quotaFactView)
        drawQuarts(viewContainer: quotaPlanView, name: "Квота", dataType: "Quota", textColor: .black, backGroundColor: globalSettings.firstColor)
        drawQuarts(viewContainer: quotaFactView, name: "Факт", dataType: "Fact", textColor: .black, backGroundColor: globalSettings.thirdColor)
        
    }
    
    func initPlanFactQuota() {
        var quotas = rootViewController.quotas.filter({$0.direction == direction})
        quotas = quotas.sorted(by: {$0.quart! < $1.quart!})
        for quota in quotas {
            let quart = rootViewController.getQuart(from: quota.quart)
            let quotaValue = Float(quota.storePointAnaliticPlan) + Float(quota.storePointDevPlan)
            let facts = rootViewController.epicUserStories.filter({$0.state?.name == "Выполнено" && $0.direction == direction})
            var factValue : Float = 0
            for fact in facts {
                let quartFact = rootViewController.getQuart(from: fact.tfsEndDate)
                if quartFact == quart {
                    //factValue += Float(fact.tfsStorePointDevFact) + Float(fact.tfsStorePointAnaliticFact)
                    factValue += Float(fact.tfsStorePointFact)
                }
            }
            var workValue : Float = 0
            var queueValue : Float = 0
            if quart == rootViewController.getQuart(from: Date()) {
                let works = rootViewController.epicUserStories.filter({$0.state?.name == "Выполняется" && $0.direction == direction})
                for work in works {
                    workValue += Float(work.tfsStorePointDevPlan) + Float(work.tfsStorePointAnaliticPlan)
                    
                }
                let queues = rootViewController.epicUserStories.filter({$0.state?.name == "Новый" && $0.direction == direction})
                for queue in queues {
                    queueValue += Float(queue.tfsStorePointDevPlan) + Float(queue.tfsStorePointAnaliticPlan)
                    
                }
            }
            planFactQuota.append(GistoData.PlanFactData(quart: quart, quota: quotaValue, fact: factValue, work: workValue, queue: queueValue))
        }
        dump(planFactQuota)
    }
    
    func initQuotaSubPlan() -> [GistoData.GistoObject] {
        var values: [GistoData.GistoObject] = []
        var quarts = rootViewController.quotas.filter({$0.direction == direction})
        quarts = quarts.sorted(by: {$0.quart! < $1.quart!})
        for quart in quarts {
            let quartName = "\(rootViewController.getQuart(from: quart.quart)) квартал"
            if let quota = rootViewController.quotas.filter({$0.direction == direction && $0.quart == quart.quart}).first {
                values.append(GistoData.GistoObject(name: quartName, value: Float(quota.storePointAnaliticPlan)))
                values.append(GistoData.GistoObject(name: quartName, value: Float(quota.storePointDevPlan)))
            }
        }
        return values
    }
    
    func drawQuarts(viewContainer: UIView, name: String, dataType: String, textColor: UIColor, backGroundColor: UIColor) {
        for view in viewContainer.subviews {
            view.removeFromSuperview()
        }
        let numViews = 4
        var currentX = CGFloat(0)
        for x in 0..<numViews {
            var firstValue = planFactQuota[x].quota
            var secondValue = planFactQuota[x].quota
            var y = 0
            
            
            let newX = viewContainer.frame.width / CGFloat(numViews)
            let frame = CGRect.init(x: currentX,
                                    y: 0,
                                    width: newX + 1,
                                    height: viewContainer.frame.height)
            let view = UIView(frame: frame)
            view.layer.borderWidth = 1
            view.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            view.backgroundColor = .white
            view.alpha = 0.75
            viewContainer.addSubview(view)
            
            var width = CGFloat(0)
            switch dataType {
            case "Quota":
                firstValue = planFactQuota[x].quota
                secondValue = planFactQuota[x].fact
                if firstValue < secondValue {
                    width = CGFloat(firstValue / secondValue) * newX
                } else {
                    width = newX
                }
                y = 1
            case "Fact":
                firstValue = planFactQuota[x].fact
                secondValue = planFactQuota[x].quota
                if firstValue < secondValue {
                    width = CGFloat(firstValue / secondValue) * newX
                } else {
                    width = newX
                }
                y = 2
            default:
                firstValue = planFactQuota[x].quota
                secondValue = planFactQuota[x].quota
                y = 0
            }
            let frameValue = CGRect.init(x: 0,
                                    y: 0,
                                    width: width,
                                    height: view.frame.height)
            let viewQuart = UIView(frame: frameValue
            )
            viewQuart.backgroundColor = backGroundColor
            viewQuart.alpha = 0.75
            view.addSubview(viewQuart)
            
            let frameLabel = CGRect.init(x: 0,
                                         y: 0,
                                         width: view.frame.width,
                                         height: view.frame.height)
            
            let quartLabel = UILabel(frame: frameLabel)
            quartLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 12)
            quartLabel.textColor = .black
            quartLabel.adjustsFontSizeToFitWidth = true
            quartLabel.textAlignment = .center
            quartLabel.minimumScaleFactor = 0.75 // Минимальный относительный размер шрифта
            let value = Int(firstValue)
            var text = ""
            if value != 0 {
                text = "\(value)"
            }
            quartLabel.text = text
            view.addSubview(quartLabel)
            
            let quartButton = UIButton(frame: frameLabel)
            quartButton.tag = 10 * y + (x + 1)
            quartButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            view.addSubview(quartButton)
            
            
            currentX += newX
            
        }
    }
    
    @objc func buttonAction(sender: UIButton!) {
        print("\(sender.tag)")
        currentQuart = sender.tag % 10
        if sender.tag / 10 == 2 {
            currentState = rootViewController.states.filter({$0.name == "Выполнено"}).first
            performSegue(withIdentifier: "eusListSegue", sender: nil)
        }
    }
    
    func drawPlanFactQuota(viewContainerQuota: UIView, viewContainerFact: UIView) {
        for view in viewContainerQuota.subviews {
            view.removeFromSuperview()
        }
        for view in viewContainerFact.subviews {
            view.removeFromSuperview()
        }
        let numViews = 4
        var currentX = CGFloat(0)
        for x in 0..<numViews {
            
            let newX = viewContainerQuota.frame.width / CGFloat(numViews)
            let frame = CGRect.init(x: currentX,
                                    y: 0,
                                    width: newX + 1,
                                    height: viewContainerQuota.frame.height)
            let viewQuota = UIView(frame: frame)
            let viewFact = UIView(frame: frame)
            viewQuota.layer.borderWidth = 1
            viewQuota.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            viewFact.layer.borderWidth = 1
            viewFact.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            viewFact.backgroundColor = globalSettings.firstColor
            viewFact.alpha = 0.75
            
            viewContainerQuota.addSubview(viewQuota)
            viewContainerFact.addSubview(viewFact)
            var framePlan = CGRect()
            var frameFact = CGRect()
            if planFactQuota[x].fact < planFactQuota[x].quota {
                let width = CGFloat(planFactQuota[x].fact / planFactQuota[x].quota) * newX
                framePlan = CGRect.init(x: 0,
                                        y: 0,
                                        width: newX,
                                        height: viewQuota.frame.height)
                frameFact = CGRect.init(x: 0,
                                        y: 0,
                                        width: width,
                                        height: viewFact.frame.height)
                
            } else {
                let width = CGFloat(planFactQuota[x].quota / planFactQuota[x].fact) * newX
                framePlan = CGRect.init(x: 0,
                                        y: 0,
                                        width: width,
                                        height: viewQuota.frame.height)
                frameFact = CGRect.init(x: 0,
                                        y: 0,
                                        width: newX,
                                        height: viewFact.frame.height)
                
            }
            let viewQuartPlan = UIView(frame: framePlan)
            viewQuartPlan.backgroundColor = globalSettings.firstColor
            viewQuartPlan.alpha = 0.75
            viewQuota.addSubview(viewQuartPlan)
            let frameLabel = CGRect.init(x: 0,
                                    y: 0,
                                    width: viewQuota.frame.width,
                                    height: viewQuota.frame.height)
            let quotaLabel = UILabel(frame: frameLabel)
            quotaLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 12)
            quotaLabel.textColor = .black
            quotaLabel.adjustsFontSizeToFitWidth = true
            quotaLabel.textAlignment = .center
            quotaLabel.minimumScaleFactor = 0.75 // Минимальный относительный размер шрифта
            var value = Int(planFactQuota[x].quota)
            var text = ""
            if value != 0 {
                text = "\(value)"
            }
            quotaLabel.text = text
            viewQuota.addSubview(quotaLabel)
            let viewQuartFact = UIView(frame: frameFact)
            viewQuartFact.backgroundColor = globalSettings.thirdColor
            viewQuartFact.alpha = 1
            viewFact.addSubview(viewQuartFact)
            let factLabel = UILabel(frame: frameLabel)
            factLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 12)
            factLabel.textColor = .black
            factLabel.adjustsFontSizeToFitWidth = true
            factLabel.textAlignment = .center
            factLabel.minimumScaleFactor = 0.75 // Минимальный относительный размер шрифта
            value = Int(planFactQuota[x].fact)
            text = ""
            if value != 0 {
                text = "\(value)"
            }
            factLabel.text = text
            viewFact.addSubview(factLabel)
            currentX += newX
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "eusListSegue" {
            let dvc = segue.destination as! EUSTableViewController
            dvc.direction = direction
            dvc.quart = currentQuart
            dvc.eusState = currentState
        }
    }

}
