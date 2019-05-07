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

    @IBOutlet weak var quotaPlanView: UIView!
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
        if let quota = quota {
            // плановые квоты
            drawQuota(viewContainer: quotaPlanView, name: quota.name, valueObjects: quota.valuesOne, textColor: globalSettings.secondColor, backGroundColor: globalSettings.firstColor)
            // очередь ЭПИ
            drawQuota(viewContainer: quotaQueueView, name: quota.name, valueObjects: quota.valuesTwo, textColor: globalSettings.secondColor, backGroundColor: globalSettings.thirdColor)
            
            
        }
        // Do any additional setup after loading the view.
    }
    
    func drawQuota(viewContainer: UIView, name: String, valueObjects: [GistoData.GistoObject], textColor: UIColor, backGroundColor: UIColor) {
        for view in viewContainer.subviews {
            view.removeFromSuperview()
        }
        var currentX = CGFloat(0)
        var mv: Float =  0
        for value in valueObjects {
            mv += value.value
        }
        let maxValue = CGFloat(mv)
        for x in 0..<valueObjects.count {
            let newX = CGFloat(valueObjects[x].value) * viewContainer.frame.width / maxValue
            let frame = CGRect.init(x: currentX,
                                    y: 0,
                                    width: newX,
                                    height: viewContainer.frame.height)
            let view = UIView(frame: frame)
            currentX += newX
            view.backgroundColor = backGroundColor
            view.alpha = 1 - CGFloat(x) / CGFloat(valueObjects.count) / 2
            let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: newX, height: viewContainer.frame.height))
            titleLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 14)
            titleLabel.text = "\(Int(valueObjects[x].value))"
            titleLabel.textColor = textColor
            titleLabel.adjustsFontSizeToFitWidth = true
            titleLabel.textAlignment = .center
            titleLabel.minimumScaleFactor = 0.75 // Минимальный относительный размер шрифта
            view.addSubview(titleLabel)
            viewContainer.addSubview(view)
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
