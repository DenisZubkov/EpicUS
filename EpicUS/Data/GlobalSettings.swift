//
//  GlobalSettings.swift
//  EpicUS
//
//  Created by Denis Zubkov on 29/03/2019.
//  Copyright © 2019 TBM. All rights reserved.
//

import Foundation
import UIKit

class GlobalSettings {
    let server1C = ODataServer.init(scheme: "http", host: "document.tbm.ru", port: 80, server: "/DocMng", oData: "/odata/standard.odata/")
    let serverTFS = ODataServer.init(scheme: "http", host: "tfs1.tbm.ru", port: 8080, server: "/tfs/DefaultCollection", oData: "/_apis/wit/")
    let site = "https://www.tbm.ru"
    let phoneFirst = "tel://"
    let phoneSecond = "tel://"
    let address = ""
    let email = "denzu@mac.com"
    let gpsX: Double = 55.713603
    let gpsY: Double = 37.571183
    let emptyId = "00000000-0000-0000-0000-000000000000"
    let facebook = ""
    let facebookApp = ""
    let icq = ""
    let skype = ""
    var login = "zubkoff"
    var password = "!den20zu10"
    let firstColor = #colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1)
    let firstCGColor: CGColor = #colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1)
    let secondColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    let secondCGColor: CGColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    let thirdColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
    let thirdCGColor: CGColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
    let tabBarColor = #colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1)
    let parameterDict: [TypeParameters : String] = [
        .category: "71c4c213-08c4-11e9-94b6-0050568d26bf",
        .tactic: "b01fa2f0-08c4-11e9-94b6-0050568d26bf",
        .businessValue19: "838c9a73-17b6-11e9-8e2e-0050568d26bf",
        .dept: "d342c29c-5d40-11e6-850d-0050568d26bf",
        .eusUrl19: "8815a07f-09c5-11e9-94b6-0050568d26bf",
        .eusUrl18: "19bf6ca6-bad9-11e7-acc5-0050568d26bf",
        .storePointsDevPlan: "e945dcba-08c6-11e9-94b6-0050568d26bf",
        .storePointsAnaliticPlan: "dc18d546-08c6-11e9-94b6-0050568d26bf",
        .priority: "1f3da85c-2f7b-11e9-8e2e-0050568d26bf",
        .quart: "33e47edd-2f7b-11e9-8e2e-0050568d26bf",
        .deathline: "b64ba876-7f57-11e8-8acb-0050568d26bf",
        .product: "89778d28-bad4-11e7-acc5-0050568d26bf",
        .businessValue18: "32070e46-bad8-11e7-acc5-0050568d26bf",
        .visa: "fef304c1-bad8-11e7-acc5-0050568d26bf",
        .storePointsAnaliticFact19: "71998249-67e7-11e9-afc8-0050568d26bf",
        .storePointsDevFact19: "7f9f2184-67e7-11e9-afc8-0050568d26bf",
        .storePointsAnaliticFact18: "d36bb213-6a5e-11e9-afc8-0050568d26bf",
        .storePointsDevFact18: "e098b409-6a5e-11e9-afc8-0050568d26bf",
        .direction18: "ba84e2e0-67f1-11e9-afc8-0050568d26bf",
        .direction19: "0b335ce8-6739-11e9-afc8-0050568d26bf"
    ]
    
    
    let eusTypeDict: [TypeEUS : String] = [
        .eus19 : "141daa64-08c4-11e9-94b6-0050568d26bf",
        .eus18 : "f357797e-bad3-11e7-acc5-0050568d26bf"
    ]
    
    let  factOA : EpicUserStoriesJSON.ДополнительныеРеквизиты =
        EpicUserStoriesJSON.ДополнительныеРеквизиты(id: "", lineNumber: "10", parameterId: "71998249-67e7-11e9-afc8-0050568d26bf", valueId: "", valueType: "Edm.Double", value: "0")
    
    
    let factORPO : EpicUserStoriesJSON.ДополнительныеРеквизиты =
        EpicUserStoriesJSON.ДополнительныеРеквизиты(id: "", lineNumber: "11", parameterId: "7f9f2184-67e7-11e9-afc8-0050568d26bf", valueId: "", valueType: "Edm.Double", value: "0")
    
    
    let status : EpicUserStoriesJSON.ДополнительныеРеквизиты =
        EpicUserStoriesJSON.ДополнительныеРеквизиты(id: "", lineNumber: "11", parameterId: "0218c7e6-683d-11e9-afc8-0050568d26bf", valueId: "", valueType: "Edm.Double", value: "Реализована")
    
            
            
//    {
//        "LineNumber": "10",
//        "Свойство_Key": "71998249-67e7-11e9-afc8-0050568d26bf",
//        "Значение": "4",
//        "Значение_Type": "Edm.Double",
//        "ТекстоваяСтрока": ""
//        },
//    {
//        "LineNumber": "11",
//        "Свойство_Key": "7f9f2184-67e7-11e9-afc8-0050568d26bf",
//        "Значение": "6",
//        "Значение_Type": "Edm.Double",
//        "ТекстоваяСтрока": ""
//        },
//    {
//        "LineNumber": "12",
//        "Свойство_Key": "0218c7e6-683d-11e9-afc8-0050568d26bf",
//        "Значение": "Реализована",
//        "Значение_Type": "UnavailableEnums.СостоянияЭПИ",
//        "ТекстоваяСтрока": ""
//        }]


   
    
//    let headDirectionDict: [String : String] = [
//        "79cb6752-08c6-11e9-94b6-0050568d26bf" : "0072350f-7e11-11e8-8acb-0050568d26bf", // Витер
//        "79cb675d-08c6-11e9-94b6-0050568d26bf" : "e11da4aa-379d-11e6-850d-0050568d26bf", // Ястребова
//        "79cb6769-08c6-11e9-94b6-0050568d26bf" : "71205074-3790-11e6-850d-0050568d26bf", // Карнаухова
//        "80f90ce0-08c6-11e9-94b6-0050568d26bf" : "3ba58d04-3793-11e6-850d-0050568d26bf", // Биджева
//        "80f90cf8-08c6-11e9-94b6-0050568d26bf" : "28e59780-3790-11e6-850d-0050568d26bf", // Тихомиров
//        "89fba132-08c6-11e9-94b6-0050568d26bf" : "3158f8ca-378f-11e6-850d-0050568d26bf", // Зубков
//        "89fba14e-08c6-11e9-94b6-0050568d26bf" : "3e76af2a-3799-11e6-850d-0050568d26bf", // Агеева
//        "89fba150-08c6-11e9-94b6-0050568d26bf" : "7d3d2f14-378e-11e6-850d-0050568d26bf"  // Мартинайтине
//    ]
    
//    let tfsDirectionDict: [String : Int32] = [
//        "79cb6752-08c6-11e9-94b6-0050568d26bf" : 4638, // Оптовые продажи
//        "79cb675d-08c6-11e9-94b6-0050568d26bf" : 4639, // Розничные продажи
//        "79cb6769-08c6-11e9-94b6-0050568d26bf" : 4637, // Логистика
//        "80f90ce0-08c6-11e9-94b6-0050568d26bf" : 4641, // Управление персоналом
//        "80f90cf8-08c6-11e9-94b6-0050568d26bf" : 4640, // Финансы
//        "89fba132-08c6-11e9-94b6-0050568d26bf" : 4644, // ДИТ
//        "89fba14e-08c6-11e9-94b6-0050568d26bf" : 4642, // КРО
//        "89fba150-08c6-11e9-94b6-0050568d26bf" : 4643  // Юристы
//    ]
    
        let headDirectionDict: [String : String] = [
            "97c38613-6712-11e9-afc8-0050568d26bf" : "0072350f-7e11-11e8-8acb-0050568d26bf", // Витер
            "535c9aa6-6711-11e9-afc8-0050568d26bf" : "e11da4aa-379d-11e6-850d-0050568d26bf", // Ястребова
            "7e8198e4-6711-11e9-afc8-0050568d26bf" : "71205074-3790-11e6-850d-0050568d26bf", // Карнаухова
            "14cfbebf-6711-11e9-afc8-0050568d26bf" : "3ba58d04-3793-11e6-850d-0050568d26bf", // Биджева
            "b7b69311-671e-11e9-afc8-0050568d26bf" : "28e59780-3790-11e6-850d-0050568d26bf", // Тихомиров
            "54f09c1d-66ad-11e9-afc8-0050568d26bf" : "3158f8ca-378f-11e6-850d-0050568d26bf", // Зубков
            "d136563d-6710-11e9-afc8-0050568d26bf" : "3e76af2a-3799-11e6-850d-0050568d26bf", // Агеева
            "eb3e9f0c-670f-11e9-afc8-0050568d26bf" : "7d3d2f14-378e-11e6-850d-0050568d26bf", // Мартинайтине
            "c7dd50e8-6721-11e9-afc8-0050568d26bf" : "28e59780-3790-11e6-850d-0050568d26bf", // Управление финансами - Парус
            "f87c5b27-6721-11e9-afc8-0050568d26bf" : "3ba58d04-3793-11e6-850d-0050568d26bf"  // Управление персоналом - Парус
        ]

    
        let tfsDirectionDict: [String : Int32] = [
            "97c38613-6712-11e9-afc8-0050568d26bf" : 4638, // Оптовые продажи
            "535c9aa6-6711-11e9-afc8-0050568d26bf" : 4639, // Розничные продажи
            "7e8198e4-6711-11e9-afc8-0050568d26bf" : 4637, // Логистика
            "14cfbebf-6711-11e9-afc8-0050568d26bf" : 4641, // Управление персоналом
            "b7b69311-671e-11e9-afc8-0050568d26bf" : 4640, // Финансы
            "54f09c1d-66ad-11e9-afc8-0050568d26bf" : 4644, // ДИТ
            "d136563d-6710-11e9-afc8-0050568d26bf" : 4642, // КРО
            "eb3e9f0c-670f-11e9-afc8-0050568d26bf" : 4643, // Юристы
            "c7dd50e8-6721-11e9-afc8-0050568d26bf" : 5547, // Управление финансами - Парус
            "f87c5b27-6721-11e9-afc8-0050568d26bf" : 5548  // Управление персоналом - Парус2222
        ]
    
    let userGroupDict: [TypeParameters: String] = [
        .ak : "317152c6-5207-11e9-878e-0050568d26bf",
        .vp : "65e70849-08df-11e9-94b6-0050568d26bf",
        .k1 : "93e81b60-577b-11e9-a906-0050568d26bf",
        .k2 : "af6bab9e-577b-11e9-a906-0050568d26bf",
        .k3 : "ca652bc6-577b-11e9-a906-0050568d26bf",
        .k4 : "ee093111-577b-11e9-a906-0050568d26bf",
        .k5 : "01de8e53-577c-11e9-a906-0050568d26bf",
        .k6 : "1aab0bdf-577c-11e9-a906-0050568d26bf",
        .rn : "89f5e9a0-2f4c-11e9-8e2e-0050568d26bf",
    ]
    
    
    let typeTeamList: [TypeTeamEnum] =
    [
    .analitics,
    .developers,
    .productOwners,
    .directionHeads
    ]

    enum TypeTeamEnum: String {
        case analitics = "АК"
        case developers = "K"
        case productOwners = "ВП"
        case directionHeads = "РН"
        
        init?(id : Int) {
            switch id {
            case 1: self = .analitics
            case 2: self = .developers
            case 3: self = .productOwners
            case 4: self = .directionHeads
            default: return nil
            }
        }
    }
    
    func createOrFilter(fieldName: String, valueDict: [TypeParameters : String]) -> String{
        var parametersArray: [String] = []
        for parameter in valueDict {
            parametersArray.append("\(fieldName) eq guid'" + parameter.value + "'")
        }
        var filter = parametersArray[0]
        for i in 1..<parametersArray.count {
            filter = parametersArray[i] + " or " + filter
        }
        return filter
    }
    
    func separatedNumber(_ number: Any) -> String {
        guard let itIsANumber = number as? NSNumber else { return "Not a number" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.decimalSeparator = ","
        return formatter.string(from: itIsANumber)!
    }

    func dateToString(date: Date?) -> String {
        if let date = date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            dateFormatter.locale = Locale.init(identifier: "ru_RU")
            let dateString = dateFormatter.string(from: date)
            return dateString
        }
        return ""
    }
    func prepareQueryArray() -> [ODataQuery] {
        
        var queryArray: [ODataQuery] = []
        
        // Parameters [0]
        let filterParameters = createOrFilter(fieldName: "Ref_Key", valueDict: parameterDict)
        var query = ODataQuery.init(server: server1C,
                                    table: "ChartOfCharacteristicTypes_ДополнительныеРеквизитыИСведения/",
                                    filter: filterParameters,
                                    select: "Ref_Key, Заголовок, DataVersion",
                                    orderBy: nil,
                                    id: nil)
        queryArray.append(query)
        
        //ParameterValues [1]
        let filterParameterValues = createOrFilter(fieldName: "Owner_Key", valueDict: parameterDict)
        query = ODataQuery.init(server: server1C,
                                table: "Catalog_ЗначенияСвойствОбъектов",
                                filter: filterParameterValues,
                                select: "Ref_Key, Description, Owner_Key, Parent_Key, DataVersion, IsFolder",
                                orderBy: nil,
                                id: nil)
        queryArray.append(query)
        
        //Dept [2]
        query = ODataQuery.init(server: server1C,
                                table: "Catalog_СтруктураПредприятия",
                                filter: nil,
                                select: "Ref_Key, Description, Parent_Key, DataVersion, ДополнительныеРеквизиты, Руководитель_Key",
                                orderBy: nil,
                                id: nil)
        queryArray.append(query)
        
        
        //UserGroup [3]
        let filterUserGroups = createOrFilter(fieldName: "Ref_Key", valueDict: userGroupDict)
        query = ODataQuery.init(server: server1C,
                                table: "Catalog_РабочиеГруппы",
                                filter: filterUserGroups,
                                select: "Ref_Key, Description, DataVersion, Состав",
                                orderBy: nil,
                                id: nil)
        queryArray.append(query)
        
        
        //Users [4]
        query = ODataQuery.init(server: server1C,
                                table: "Catalog_Пользователи",
                                filter: nil,
                                select: "Ref_Key, Description, DataVersion, Подразделение_Key, КонтактнаяИнформация, ДополнительныеРеквизиты",
                                orderBy: nil,
                                id: nil)
        queryArray.append(query)
        
        
        
        //EUS 1C [5]
        if let eus18 = eusTypeDict[.eus18], let eus19 = eusTypeDict[.eus19] {
            query = ODataQuery.init(server: server1C,
                                    table: "Catalog_ВнутренниеДокументы/",
                                    filter: "ВидДокумента_Key eq guid'\(eus18)' or ВидДокумента_Key eq guid'\(eus19)'",
                select: "Ref_Key, ВидДокумента_Key, DataVersion, Description, ВопросДеятельности_Key, ДатаСоздания, ДатаРегистрации, Заголовок, Подготовил_Key, Подразделение_Key, РегистрационныйНомер, Содержание, ДополнительныеРеквизиты, DeletionMark",
                orderBy: "ДатаСоздания",
                id: nil)
            queryArray.append(query)
        }
        
        //Directions [6]
        query = ODataQuery.init(server: server1C,
                                table: "Catalog_НаправленияРазвитияПО",
                                filter: nil,
                                select: "Ref_Key, Description, DataVersion, ПорядокСортировки, КраткоеНаименование, РуководительНаправления_Key",
                                orderBy: nil,
                                id: nil)
        queryArray.append(query)
        
        //Quotas [7]
        query = ODataQuery.init(server: server1C,
                                table: "InformationRegister_КвотыПоНаправлениямРазвитияПО",
                                filter: nil,
                                select: nil,
                                orderBy: nil,
                                id: nil)
        queryArray.append(query)
        
        
//        //US TFS
//        query = ODataQuery.init(server: serverTFS,
//                                table: "Catalog_ВнутренниеДокументы/",
//                                filter: "ВидДокумента_Key eq guid'141daa64-08c4-11e9-94b6-0050568d26bf'",
//                                select: "Ref_Key, DataVersion, Description, ВопросДеятельности_Key, ДатаСоздания, ДатаРегистрации, Заголовок, Подготовил_Key, Подразделение_Key, РегистрационныйНомер, Содержание, ДополнительныеРеквизиты",
//                                orderBy: "ДатаСоздания")
//        queryArray.append(query)
        
        return queryArray
        
    }
}

enum ObjectJSON: String {
    case parameters = "Parameters"
    case paramepersValues = "ParameterValues"
}

enum TypeEUS: String {
    case eus18 = "Старая ЭПИ"
    case eus19 = "Новая ЭПИ"
}

enum TypeParameters: String {
    case direction18 = "Направление развития (OLD)"
    case direction19 = "Направление развития"
    case category = "Категория"
    case tactic = "Тактика"
    case businessValue19 = "Ценность"
    case dept = "Подразделение"
    case eusUrl19 = "Гиперссылка на журнал ЭПИ"
    case eusUrl18 = "Ссылка на ЭПИ в журнале"
    case storePointsDevPlan = "Оценка трудоемкости разработки"
    case storePointsAnaliticPlan = "Оценка трудоемкости ОА"
    case priority = "Приоритет"
    case quart = "Квартал"
    case deathline = "Дедлайн"
    case product = "Продукт"
    case businessValue18 = "Оценка по методу Moscow"
    case visa = "Решение"
    case state19 = "Состояние ЭПИ"
    case storePointsAnaliticFact19 = "ОА фактические трудозатраты"
    case storePointsDevFact19 = "ОРПО фактические трудозатраты"
    case storePointsAnaliticFact18 = "ОА фактические трудозатраты (OLD)"
    case storePointsDevFact18 = "ОРПО фактические трудозатраты (OLD)"
    case state18 = "Состояние ЭПИ (OLD)"
    case ak = "АК"
    case vp = "ВП"
    case k1 = "K1"
    case k2 = "K2"
    case k3 = "K3"
    case k4 = "K4"
    case k5 = "K5"
    case k6 = "K6"
    case rn = "РН"
}

