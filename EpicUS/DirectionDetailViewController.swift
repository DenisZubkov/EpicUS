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
    var quartForEusList = 1
    var currentState: State?
    var sumQuota: Float = 0

    @IBOutlet weak var quotaTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var quotaPlanView: UIView!
    @IBOutlet weak var quotaFactView: UIView!
    @IBOutlet weak var quotaWorkView: UIView!
    @IBOutlet weak var quotaQueueView: UIView!
    @IBOutlet weak var quota1cView: UIView!
    @IBOutlet weak var workTitleLabel: UILabel!
    @IBOutlet weak var queueTitleLabel: UILabel!
    @IBOutlet weak var OneCTitleLabel: UILabel!
    
    @IBAction func quotaTypeChanged(_ sender: UISegmentedControl) {
        drawAll()
    }
    
    @IBAction func refreshDataButton(_ sender: UIBarButtonItem) {
        
    }
    
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
        currentQuart = rootViewController.getQuart(from: Date()) - 1 
        initPlanFactQuota()
        drawAll()
        //drawPlanFactQuota(viewContainerQuota: quotaPlanView, viewContainerFact: quotaFactView)
        
        
    }
    
    func drawAll() {
        drawQuarts(viewContainer: quotaPlanView, name: "Квота", dataType: "Quota", textColor: .black, backGroundColor: globalSettings.firstColor)
        drawQuarts(viewContainer: quotaFactView, name: "Факт", dataType: "Fact", textColor: .black, backGroundColor: globalSettings.thirdColor)
        drawWork()
        drawQueue()
        drawEus1c()
    }
    
    func initPlanFactQuota() {
        var quotas = rootViewController.quotas.filter({$0.direction == direction})
        quotas = quotas.sorted(by: {$0.quart! < $1.quart!})
        sumQuota = 0
        for quota in quotas {
            let quart = rootViewController.getQuart(from: quota.quart)
            let quotaValue = Float(quota.storePointAnaliticPlan) + Float(quota.storePointDevPlan)
            sumQuota += quotaValue
            let quotaValueA = Float(quota.storePointAnaliticPlan)
            let quotaValueD = Float(quota.storePointDevPlan)
            let facts = rootViewController.userStories.filter({$0.state?.name == "Выполнено" && $0.epicUserStory?.direction == direction})
            var factValue : Float = 0
            var factValueA : Float = 0
            var factValueD : Float = 0
            for fact in facts {
                
                let quartFact = rootViewController.getQuart(from: fact.dateEnd)
                if quartFact == quart {
                    //factValue += Float(fact.tfsStorePointDevFact) + Float(fact.tfsStorePointAnaliticFact)
                    
                    if fact.userStoryType?.id == "[ANLZ" || fact.userStoryType?.id == "[DCMP" || fact.userStoryType?.id == "[WORK" {
                        factValue += Float(fact.storePointFact)
                        factValueA += Float(fact.storePointFact)
                    } else if fact.userStoryType?.id == "[K" || fact.userStoryType?.id == "[К" {
                        factValue += Float(fact.storePointFact)
                        factValueD += Float(fact.storePointFact)
                    }
                    
                }
            }
            var workValue : Float = 0
            var workValueA : Float = 0
            var workValueD : Float = 0
            
            var queueValue : Float = 0
            var queueValueA : Float = 0
            var queueValueD : Float = 0
            
            var eus1cValue : Float = 0
            var eus1cValueA : Float = 0
            var eus1cValueD : Float = 0
            if quart == rootViewController.getQuart(from: Date()) {
                let works = rootViewController.epicUserStories.filter({$0.state?.name == "Выполняется" && $0.direction == direction})
                for work in works {
                    workValue += Float(work.tfsStorePointDevPlan) + Float(work.tfsStorePointAnaliticPlan)
                    workValueA += Float(work.tfsStorePointAnaliticPlan)
                    workValueD += Float(work.tfsStorePointDevPlan)
                    
                }
                let queues = rootViewController.epicUserStories.filter({$0.state?.name == "Новый" && $0.tfsId != 0 && $0.direction == direction})
                for queue in queues {
                    queueValue += Float(queue.tfsStorePointDevPlan) + Float(queue.tfsStorePointAnaliticPlan)
                    queueValueA += Float(queue.tfsStorePointAnaliticPlan)
                    queueValueD += Float(queue.tfsStorePointDevPlan)
                }
                let eus1cs = rootViewController.epicUserStories.filter({$0.tfsId == 0 && $0.direction == direction})
                for eus1c in eus1cs {
                    eus1cValue += (Float(eus1c.storePointsDevPlane ?? "0") ?? Float(0)) + (Float(eus1c.storePointsAnaliticPlane ?? "0") ?? Float(0))
                    eus1cValueA += Float(eus1c.storePointsAnaliticPlane  ?? "0") ?? Float(0)
                    eus1cValueD += Float(eus1c.storePointsDevPlane ?? "0") ?? Float(0)
                }
            }
            planFactQuota.append(GistoData.PlanFactData(quart: quart,
                                                        quota: quotaValue,
                                                        quotaA: quotaValueA,
                                                        quotaD: quotaValueD,
                                                        fact: factValue,
                                                        factA: factValueA,
                                                        factD: factValueD,
                                                        work: workValue,
                                                        workA: workValueA,
                                                        workD: workValueD,
                                                        queue: queueValue,
                                                        queueA: queueValueA,
                                                        queueD: queueValueD,
                                                        eus1c: eus1cValue,
                                                        eus1cA: eus1cValueA,
                                                        eus1cD: eus1cValueD
                
            ))
        }
        //dump(planFactQuota)
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
    
    func drawWork() {
        for view in quotaWorkView.subviews {
            view.removeFromSuperview()
        }
        var work = CGFloat(planFactQuota[currentQuart].work)
        var quota = CGFloat(planFactQuota[currentQuart].quota)
        switch quotaTypeSegmentedControl.selectedSegmentIndex {
        case 0:
            work = CGFloat(planFactQuota[currentQuart].work)
            quota = CGFloat(planFactQuota[currentQuart].quota)
        case 1:
            work = CGFloat(planFactQuota[currentQuart].workA)
            quota = CGFloat(planFactQuota[currentQuart].quotaA)
        case 2:
            work = CGFloat(planFactQuota[currentQuart].workD)
            quota = CGFloat(planFactQuota[currentQuart].quotaD)
        default:
            work = CGFloat(planFactQuota[currentQuart].work)
            quota = CGFloat(planFactQuota[currentQuart].quota)
        }
        let width = ( quotaWorkView.frame.width / CGFloat(4)) / CGFloat(quota) * work
        let frame = CGRect.init(x: 0,
                                y: 0,
                                width: width,
                                height: quotaWorkView.frame.height)
        let view = UIView(frame: frame)
        quotaWorkView.layer.borderWidth = 1
        quotaWorkView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        view.layer.borderWidth = 1
        view.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        view.backgroundColor = globalSettings.thirdColor
        view.alpha = 0.75
        quotaWorkView.addSubview(view)
        let frameLabel = CGRect.init(x: 0,
                                     y: 0,
                                     width: quotaWorkView.frame.width,
                                     height: quotaWorkView.frame.height)
        let quartLabel = UILabel(frame: frameLabel)
        quartLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 12)
        quartLabel.textColor = .black
        quartLabel.adjustsFontSizeToFitWidth = true
        quartLabel.textAlignment = .center
        quartLabel.minimumScaleFactor = 0.5 // Минимальный относительный размер шрифта
        var text = ""
        if work != 0 {
            text = "\(Int(work))"
        }
        quartLabel.text = text
        view.addSubview(quartLabel)
        
        let quartButton = UIButton(frame: frameLabel)
        quartButton.tag = 31
        quartButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        quotaWorkView.addSubview(quartButton)
    }
    
    func drawQueue() {
        for view in quotaQueueView.subviews {
            view.removeFromSuperview()
        }
        var  queue = CGFloat(planFactQuota[currentQuart].queue)
        var quota = CGFloat(planFactQuota[currentQuart].quota)
        switch quotaTypeSegmentedControl.selectedSegmentIndex {
        case 0:
            queue = CGFloat(planFactQuota[currentQuart].queue)
            quota = CGFloat(planFactQuota[currentQuart].quota)
        case 1:
            queue = CGFloat(planFactQuota[currentQuart].queueA)
            quota = CGFloat(planFactQuota[currentQuart].quotaA)
        case 2:
            queue = CGFloat(planFactQuota[currentQuart].queueD)
            quota = CGFloat(planFactQuota[currentQuart].quotaD)
        default:
            queue = CGFloat(planFactQuota[currentQuart].queue)
            quota = CGFloat(planFactQuota[currentQuart].quota)
        }
        let width = ( quotaQueueView.frame.width / CGFloat(4)) / CGFloat(quota) * queue
        let frame = CGRect.init(x: 0,
                                y: 0,
                                width: width,
                                height: quotaQueueView.frame.height)
        let view = UIView(frame: frame)
        quotaQueueView.layer.borderWidth = 1
        quotaQueueView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        view.layer.borderWidth = 1
        view.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        view.backgroundColor = globalSettings.thirdColor
        view.alpha = 0.75
        quotaQueueView.addSubview(view)
        let frameLabel = CGRect.init(x: 0,
                                     y: 0,
                                     width: quotaWorkView.frame.width,
                                     height: quotaWorkView.frame.height)
        let quartLabel = UILabel(frame: frameLabel)
        quartLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 12)
        quartLabel.textColor = .black
        quartLabel.adjustsFontSizeToFitWidth = true
        quartLabel.textAlignment = .center
        quartLabel.minimumScaleFactor = 0.5 // Минимальный относительный размер шрифта
        var text = ""
        if queue != 0 {
            text = "\(Int(queue))"
        }
        quartLabel.text = text
        view.addSubview(quartLabel)
        
        let quartButton = UIButton(frame: frameLabel)
        quartButton.tag = 41
        quartButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        quotaQueueView.addSubview(quartButton)
    }
    
    func drawEus1c() {
        for view in quota1cView.subviews {
            view.removeFromSuperview()
        }
        var eus1c = CGFloat(planFactQuota[currentQuart].eus1c)
        var quota = CGFloat(planFactQuota[currentQuart].quota)
        switch quotaTypeSegmentedControl.selectedSegmentIndex {
        case 0:
            eus1c = CGFloat(planFactQuota[currentQuart].eus1c)
            quota = CGFloat(planFactQuota[currentQuart].quota)
        case 1:
            eus1c = CGFloat(planFactQuota[currentQuart].eus1cA)
            quota = CGFloat(planFactQuota[currentQuart].quotaA)
        case 2:
            eus1c = CGFloat(planFactQuota[currentQuart].eus1cD)
            quota = CGFloat(planFactQuota[currentQuart].quotaD)
        default:
            eus1c = CGFloat(planFactQuota[currentQuart].eus1c)
            quota = CGFloat(planFactQuota[currentQuart].quota)
        }
        let width = ( quota1cView.frame.width / CGFloat(4)) / CGFloat(quota) * eus1c
        let frame = CGRect.init(x: 0,
                                y: 0,
                                width: width,
                                height: quota1cView.frame.height)
        let view = UIView(frame: frame)
        quota1cView.layer.borderWidth = 1
        quota1cView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        view.layer.borderWidth = 1
        view.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        view.backgroundColor = globalSettings.thirdColor
        view.alpha = 0.75
        quota1cView.addSubview(view)
        let frameLabel = CGRect.init(x: 0,
                                     y: 0,
                                     width: quota1cView.frame.width,
                                     height: quota1cView.frame.height)
        let quartLabel = UILabel(frame: frameLabel)
        quartLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 12)
        quartLabel.textColor = .black
        quartLabel.adjustsFontSizeToFitWidth = true
        quartLabel.textAlignment = .center
        quartLabel.minimumScaleFactor = 0.5 // Минимальный относительный размер шрифта
        var text = ""
        if eus1c != 0 {
            text = "\(Int(eus1c))"
        }
        quartLabel.text = text
        view.addSubview(quartLabel)
        
        let quartButton = UIButton(frame: frameLabel)
        quartButton.tag = 51
        quartButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        quota1cView.addSubview(quartButton)
    }
    
    func drawQuarts(viewContainer: UIView, name: String, dataType: String, textColor: UIColor, backGroundColor: UIColor) {
        for view in viewContainer.subviews {
            view.removeFromSuperview()
        }
        let numViews = 4
        var currentX = CGFloat(0)
        for x in 0..<numViews {
            var quotaValue = planFactQuota[x].quota
            var factValue = planFactQuota[x].fact
            switch quotaTypeSegmentedControl.selectedSegmentIndex {
            case 0:
                quotaValue = planFactQuota[x].quota
                factValue = planFactQuota[x].fact
                
            case 1:
                quotaValue = planFactQuota[x].quotaA
                factValue = planFactQuota[x].factA
                
            case 2:
                quotaValue = planFactQuota[x].quotaD
                factValue = planFactQuota[x].factD
                
            default:
                quotaValue = planFactQuota[x].quota
                factValue = planFactQuota[x].fact
                
                
            }
            var firstValue = quotaValue
            var secondValue = quotaValue
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
                firstValue = quotaValue
                secondValue = factValue
                if firstValue < secondValue {
                    width = CGFloat(firstValue / secondValue) * newX
                } else {
                    width = newX
                }
                y = 1
            case "Fact":
                firstValue = factValue
                secondValue = quotaValue
                if firstValue < secondValue {
                    width = CGFloat(firstValue / secondValue) * newX
                } else {
                    width = newX
                }
                y = 2
            default:
                firstValue = quotaValue
                secondValue = quotaValue
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
        
        if sender.tag / 10 == 2 {
            quartForEusList = sender.tag % 10
            currentState = rootViewController.states.filter({$0.name == "Выполнено"}).first
            performSegue(withIdentifier: "eusListSegue", sender: nil)
        }
        if sender.tag == 31 {
            quartForEusList = 0
            currentState = rootViewController.states.filter({$0.name == "Выполняется"}).first
            performSegue(withIdentifier: "eusListSegue", sender: nil)
        }
        if sender.tag == 41 {
            quartForEusList = 0
            currentState = rootViewController.states.filter({$0.name == "Новый"}).first
            performSegue(withIdentifier: "eusListSegue", sender: nil)
        }
        
        if sender.tag == 51 {
            quartForEusList = 5
            currentState = rootViewController.states.filter({$0.name == "Новый"}).first
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
            let dvc = segue.destination as! EUSWorkListTableViewController
            dvc.direction = direction
            dvc.quart = quartForEusList
            dvc.eusState = currentState
        }
    }

}
