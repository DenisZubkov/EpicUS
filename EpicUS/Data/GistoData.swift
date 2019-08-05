//
//  GistoData.swift
//  EpicUS
//
//  Created by Denis Zubkov on 18/04/2019.
//  Copyright © 2019 TBM. All rights reserved.
//

import Foundation

struct GistoData {
    var name: String
    var values: [Value]
    
    struct Value {
        var name: String
        var valuesOne: [GistoObject]
        var valuesTwo: [GistoObject]
    }
    
    struct GistoObject {
        var name: String
        var value: Float
    }
    
    struct PlanFactData {
        var quart: Int
        var quota: Float
        var quotaA: Float
        var quotaD: Float
        var fact: Float
        var factA: Float
        var factD: Float
        var work: Float
        var workA: Float
        var workD: Float
        var queue: Float
        var queueA: Float
        var queueD: Float
        var eus1c: Float
        var eus1cA: Float
        var eus1cD: Float
    }
}




