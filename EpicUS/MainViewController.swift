//
//  MainViewController.swift
//  EpicUS
//
//  Created by Denis Zubkov on 29/03/2019.
//  Copyright © 2019 TBM. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController {
    
    enum LoadType {
        case first
        case none
        case background
    }
    
    let dataProvider = DataProvider()
    let globalSettings = GlobalSettings()
    let coreDataStack = CoreDataStack()
    var context: NSManagedObjectContext!
    
    var properties: [Property] = []
    var propertyValues: [PropertyValue] = []
    var strategicTargets: [StrategicTarget] = []
    var tactics: [Tactic] = []
    var categories: [Category] = []
    var directions: [Direction] = []
    var businessValues: [BusinessValue] = []
    var depts: [Dept] = []
    var typeTeams: [TypeTeam] = []
    var teams: [Team] = []
    var users: [User] = []
    var epicUserStories: [EpicUserStory] = []
    var userStories: [UserStory] = []
    var products: [Product] = []
    var userStoryTypes: [UserStoryType] = []
    var treeWorkItems: [TreeWorkItem] = []
    var states: [State] = []
    var quotas: [Quota] = []
    
    var savedModifyDate: Date = Date() - 1000000000
    var loadType: LoadType = .first
    var date = Date()
    

    var queriesFor1C: [ODataQuery] = []
    var queriesTFS: [ODataQuery] = []
    
    @IBOutlet weak var loadProgressView: UIProgressView!
    @IBOutlet weak var loadStageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let modifyDate = UserDefaults.standard.value(forKey: "ModifyDate") as? Date {
            savedModifyDate = modifyDate
            if savedModifyDate + 100 < date {
                loadType = .background
            } else {
                loadType = .none
            }
        } else {
            loadType = .first
            //UserDefaults.standard.set(date, forKey: "ModifyDate")
        }
        
        
        //loadProgressView.transform = loadProgressView.transform.scaledBy(x: 1, y: 20)
        context = coreDataStack.persistentContainer.viewContext
        queriesFor1C = globalSettings.prepareQueryArray()
        
     }
    
    override func viewDidAppear(_ animated: Bool) {
        loadProgressView.progress = 0
        switch loadType {
        case .none:
            loadAllDataFromCoreData()
            performSegue(withIdentifier: "TabBarSegue", sender: nil)
        case .first:
            var index = 0
            //loadStageLabel.text = "Загрузка дерева EUS..."
            //getTreeWorkItems(context: context)
            loadStageLabel.text = "Загрузка данных из 1С..."
            getDataJSONFromTFS(queriesTFS: queriesFor1C, i: &index, type: .json)
//            loadAllDataFromCoreData()
        case .background:
            loadAllDataFromCoreData()
        }
        // getTreeWorkItems(context: context)

    }
    
    // MARK: COMMON METODS
    
    func loadAllDataFromCoreData() {
        directions = loadArrayFromCoreData(object: "Direction", context: context)
        directions = directions.sorted(by: {$0.ord < $1.ord} )
        depts = loadArrayFromCoreData(object: "Dept", context: context)
        teams = loadArrayFromCoreData(object: "Team", context: context)
        users = loadArrayFromCoreData(object: "User", context: context)
        tactics = loadArrayFromCoreData(object: "Tactic", context: context)
        typeTeams = loadArrayFromCoreData(object: "TypeTeam", context: context)
        categories = loadArrayFromCoreData(object: "Category", context: context)
        properties = loadArrayFromCoreData(object: "Property", context: context)
        businessValues = loadArrayFromCoreData(object: "BusinessValue", context: context)
        propertyValues = loadArrayFromCoreData(object: "PropertyValue", context: context)
        epicUserStories = loadArrayFromCoreData(object: "EpicUserStory", context: context)
        userStories = loadArrayFromCoreData(object: "UserStory", context: context)
        products = loadArrayFromCoreData(object: "Product", context: context)
        strategicTargets = loadArrayFromCoreData(object: "StrategicTarget", context: context)
        treeWorkItems = loadArrayFromCoreData(object: "TreeWorkItem", context: context)
        userStoryTypes = loadArrayFromCoreData(object: "UserStoryType", context: context)
        states = loadArrayFromCoreData(object: "State", context: context)
        states = states.sorted(by: {$0.name! < $1.name!})
        quotas = loadArrayFromCoreData(object: "Quota", context: context)
    }
    
    func convertString1cToDate(from dateString: String?) -> Date? {
        guard var str = dateString else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale.init(identifier: "ru_RU")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        str = str.replacingOccurrences(of: "T", with: " ")
        return dateFormatter.date(from: str)
    }
    
    func convertStringTFSToDate(from dateString: String?) -> Date? {
        guard let str = dateString else { return nil }
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "ru_RU")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        if let date = RFC3339DateFormatter.date(from: str) {
            return date
        } else {
             RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            let date = RFC3339DateFormatter.date(from: str)
            return date
        }
    }
    
    func getQuart(from date: Date?) -> Int {
        var quart = 0
        guard let date = date else { return quart }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: date)
        guard let month = components.month else { return (quart) }
        quart = (month - 1) / 3 + 1
        return (quart)
    }
    
    func saveDataToFile(fileName: String, fileExt: String, data: Data) -> Bool{
        let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let fileURL = DocumentDirURL.appendingPathComponent(fileName).appendingPathExtension(fileExt)
        if let dataString = String(data: data, encoding: .utf8) {
            
            do {
                try dataString.write(to: fileURL, atomically: true, encoding: .utf8)
                return true
            } catch {
                print("failed with error: \(error)")
                return false
            }
        } else {
            return false
        }
    }
    
    func printDate(dateBegin: Date, dateEnd: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm:ss"
        dateFormatter.locale = Locale.init(identifier: "ru_RU")
        let date1 = dateFormatter.string(from: dateBegin)
        let date2 = dateFormatter.string(from: dateEnd)
        let interval = dateEnd.timeIntervalSince(dateBegin)
        print("\(date1) \(date2) \(interval)")
    }
    
    func getType<T : Decodable>(from data: Data) -> T? {
        if let dataString = String(data: data, encoding: .utf8) {
            let jsonData = Data(dataString.utf8)
            do {
                let jsonObject = try JSONDecoder().decode(T.self, from: jsonData)
                return jsonObject
                
            } catch let error as NSError {
                print(error.localizedDescription)
                print(dataString)
                return nil
            }
        }
        return nil
    }
    
    func loadArrayFromCoreData<T>(object: String, context: NSManagedObjectContext) -> [T] {
        let requestSavedLevel = NSFetchRequest<NSFetchRequestResult>(entityName: object)
        do {
            if let results = try context.fetch(requestSavedLevel) as? [T] {
                return results
            } else {
                return []
            }
            
        }
        catch {
            print("\n Error on \(#function): \(error)")
            return []
        }
    }
     
    
    func loadFromFile(fileName: String, fileExtenition: String) -> Data? {
        if let path = Bundle.main.path(forResource: fileName, ofType: fileExtenition) {
            let fileManager = FileManager()
            let exists = fileManager.fileExists(atPath: path)
            if(exists){
                let content = fileManager.contents(atPath: path)
                return content
            }
        }
        return nil
    }
    
    
    
    
    
    
    func getDataJSONFromTFS(queriesTFS: [ODataQuery], i: inout Int, type: QueryResultFormat) {
        var urlComponents = self.dataProvider.getUrlComponents(server: queriesTFS[i].server, query: queriesTFS[i], format: type)
        urlComponents.user = "zubkoff"
        urlComponents.password = "!den20zu10"
        guard let url = urlComponents.url else { return }
        //        print(url)
        var index = i
        self.dataProvider.downloadDataFromTFS(url: url) { data in
            if let data = data {
                
                UserDefaults.standard.set(data, forKey: "\(index)")
                let _ = self.saveDataToFile(fileName: "\(index) \(type)", fileExt: "json", data: data)
                index += 1
                if index < queriesTFS.count {
                    DispatchQueue.main.async {
                        let progress: Float =  Float(index) / (Float(queriesTFS.count))
                        self.loadProgressView.progress = progress
                    }
                    self.getDataJSONFromTFS(queriesTFS: queriesTFS, i: &index, type: type)
                } else {
                    self.printDate(dateBegin: self.date, dateEnd: Date())
                    if type == .json {
                        self.parceJSONFrom1C(index: index)
                    } else {
                        self.parseJSONFromTFS(queries: queriesTFS)
                    }
                    self.printDate(dateBegin: self.date, dateEnd: Date())
                }
                
            }
        }
    }
    
    func parseJSONFromTFS (queries: [ODataQuery]) {
        for i in 0..<queries.count {
            if let nsData = UserDefaults.standard.value(forKey: "\(i)") as? NSData {
                let data = nsData as Data
                let result: WorkItemJSON? = self.getType(from: data)
                if let workItem = result {
                    addEUSFromTFSToCoreData(workItem: workItem)
                }
                
            }
            
        }
        performSegue(withIdentifier: "TabBarSegue", sender: nil)
    }
    

    
    func parceJSONFrom1C(index: Int) {
        
        // Шаг для ProgressView
        let step = Float(1) / (Float(queriesFor1C.count) * Float(1.5))
        
        // Parce Parameters
        if let nsData = UserDefaults.standard.value(forKey: "0") as? NSData {
            let data = nsData as Data
            let parametersJSON: ParametersJSON? = self.getType(from: data)
            if let parameters = parametersJSON?.value {
                for parameter in parameters {
                    addParameterToCoreData(parameter: parameter, context: context)
                }
                self.properties = self.loadArrayFromCoreData(object: "Property", context: self.context)
                print("Properties: \(self.properties.count)")
            }
        }
        DispatchQueue.main.async {
            let progress = self.loadProgressView.progress + step
            self.loadProgressView.progress = progress
        }
        
        
        // Parce ParameterValues
        if let nsData = UserDefaults.standard.value(forKey: "1") as? NSData {
            let data = nsData as Data
            let parameterValuesJSON: ParameterValuesJSON? = self.getType(from: data)
            if let parameterValues = parameterValuesJSON?.value {
                for parameterValue in parameterValues {
                    addParameterValueToCoreData(parameterValue: parameterValue, context: context)
                }
                self.propertyValues = self.loadArrayFromCoreData(object: "PropertyValue", context: context)
                print("PropertyValues: \(self.propertyValues.count)")
            }
        }
        DispatchQueue.main.async {
            let progress = self.loadProgressView.progress + step
            self.loadProgressView.progress = progress
        }
        
        // StrategicTargets
        addStrategicTargetsToCoreData()
        print("StrategicTargets: \(self.strategicTargets.count)")
        print("Tactics: \(self.tactics.count)")
        
        // Categories
        addCategoriesToCoreData()
        print("Categories: \(self.categories.count)")
        addBusinessValuesToCoreData()
        print("BusinessValues: \(self.businessValues.count)")
        
        // Teams
        addTypeTeamsToCoreData(context: context)
        typeTeams = loadArrayFromCoreData(object: "TypeTeam", context: context)
        print("TypeTeams: \(self.typeTeams.count)")
        

        
        
        DispatchQueue.main.async {
            let progress = self.loadProgressView.progress + step
            self.loadProgressView.progress = progress
        }
        
        
        // Parce Depts
        if let nsData = UserDefaults.standard.value(forKey: "2") as? NSData {
            let data = nsData as Data
            let deptsJSON: DeptsJSON? = self.getType(from: data)
            if let depts = deptsJSON?.value {
                for dept in depts {
                    addDeptToCoreData(dept: dept, context: context)
                }
                self.depts = self.loadArrayFromCoreData(object: "Dept", context: self.context)
                print("Depts: \(self.depts.count)")
            }
        }
        DispatchQueue.main.async {
            let progress = self.loadProgressView.progress + step
            self.loadProgressView.progress = progress
        }
        
        
        //Parse UserGroups
        if let nsData = UserDefaults.standard.value(forKey: "3") as? NSData {
            let data = nsData as Data
            let userGroupsJSON: UserGroupsJSON? = self.getType(from: data)
            if let userGroups = userGroupsJSON?.value {
                for userGroup in userGroups {
                    addTeamToCoreData(userGroup: userGroup, context: context)
                }
                self.teams = self.loadArrayFromCoreData(object: "Team", context: self.context)
                
                print("Teams: \(self.teams.count)")
            }
        }
        DispatchQueue.main.async {
            let progress = self.loadProgressView.progress + step
            self.loadProgressView.progress = progress
        }
        
        
        // Parce Users
        if let nsData = UserDefaults.standard.value(forKey: "4") as? NSData {
            let data = nsData as Data
            let usersJSON: UsersJSON? = self.getType(from: data)
            if let users = usersJSON?.value {
                addUserDataToCoreData(usersJSON: users, context: context)
                self.users = self.loadArrayFromCoreData(object: "User", context: self.context)
                print("Users: \(self.users.count)")
            }
        }
        DispatchQueue.main.async {
            let progress = self.loadProgressView.progress + step
            self.loadProgressView.progress = progress
        }
        
        // Parce Directions
        if let nsData = UserDefaults.standard.value(forKey: "6") as? NSData {
            let data = nsData as Data
            let directionsJSON: DirectionsJSON? = self.getType(from: data)
            if let directions = directionsJSON?.value {
                for direction in directions {
                    addDirectionToCoreData(direction: direction, context: context)
                }
                self.directions = self.loadArrayFromCoreData(object: "Direction", context: self.context)
                print("Directions: \(self.directions.count)")
            }
        }
        DispatchQueue.main.async {
            let progress = self.loadProgressView.progress + step
            self.loadProgressView.progress = progress
        }
        
        // Parce Quotas
        if let nsData = UserDefaults.standard.value(forKey: "7") as? NSData {
            let data = nsData as Data
            let quotasJSON: QuotasJSON? = self.getType(from: data)
            if let quotas = quotasJSON?.value {
                for quota in quotas {
                    addQuotaToCoreData(quota: quota, context: context)
                }
                self.quotas = self.loadArrayFromCoreData(object: "Quota", context: self.context)
                
                print("Quotas: \(self.quotas.count)")
            }
        }
        DispatchQueue.main.async {
            let progress = self.loadProgressView.progress + step
            self.loadProgressView.progress = progress
        }
        
        // Parce epicUserStories
        if let nsData = UserDefaults.standard.value(forKey: "5") as? NSData {
            let data = nsData as Data
            let epicUserStoriesJSON: EpicUserStoriesJSON? = self.getType(from: data)
            var i = 0
            if let epicUserStoriesJSON = epicUserStoriesJSON?.value {
                print(epicUserStoriesJSON.count)
                for epicUserStoryJSON in epicUserStoriesJSON {
                   if epicUserStoryJSON.eusType == globalSettings.eusTypeDict[.eus18] {
                        if let tfsUrl = epicUserStoryJSON.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict[.eusUrl18]}).first {
                            if tfsUrl.valueId.hasPrefix("http://tfs:8080/tfs/DIT/MAIN-BACKLOG") {
                                continue
                            }
                        } else {
                            continue
                        }
                       if let stage = epicUserStoryJSON.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict[.visa]}).first {
                            if stage.valueId == "6dd39d53-bad8-11e7-acc5-0050568d26bf" ||  stage.valueId == "73d55f9d-bad8-11e7-acc5-0050568d26bf" {
                                continue
                            }
                        } else {
                            continue
                        }
                    }
                    i += 1
                    addEpicUserStoryToCoreData(epicUserStory: epicUserStoryJSON, context: context)
                }
                print(i)
                self.epicUserStories.removeAll()
                self.epicUserStories = self.loadArrayFromCoreData(object: "EpicUserStory", context: self.context)
                epicUserStories = epicUserStories.sorted(by: {$0.dateCreate! < $1.dateCreate!})
                print("EpicUserStories: \(self.epicUserStories.count)")
            }
        }
        DispatchQueue.main.async {
            let progress = self.loadProgressView.progress + step
            self.loadProgressView.progress = progress
        }
        fillDirectionByProductOwner()
        DispatchQueue.main.async {
            let progress = self.loadProgressView.progress + step
            self.loadProgressView.progress = progress
        }
        
        addEUSFromTFS()
    }
    
    
    
    
    
    
    //MARK: TREEWORKITEM

    func getTreeWorkItems(context: NSManagedObjectContext) {
        treeWorkItems.removeAll()
        deleteTreeWorkItemsFromCoreData(context: context)
        addTreeWorkItemsRoot(context: context)
        var level: Int32 = 0
        addTreeWorkItems(level: &level, context: context)
        
    }
    
    func addTreeWorkItemsRoot(context: NSManagedObjectContext) {
        for direction in directions {
            guard let entity =  NSEntityDescription.entity(forEntityName: "TreeWorkItem", in: context) else { return }
            let workItem = NSManagedObject(entity: entity, insertInto: context)
            workItem.setValue(direction.tfsId, forKey: "id")
            workItem.setValue(0, forKey: "level")
            workItem.setValue(0, forKey: "parentId")
        }
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
    }
    
    
     func addTreeWorkItems(level: inout Int32, context: NSManagedObjectContext) {
        queriesTFS.removeAll()
        let fetchRequest: NSFetchRequest<TreeWorkItem> = TreeWorkItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "level == %i", level)
        do {
            let results = try context.fetch(fetchRequest)
            for result in results {
                let tfsId = result.id
                let query = ODataQuery.init(server: globalSettings.serverTFS,
                                            table: "workitems/\(tfsId)",
                    filter: nil,
                    select: nil,
                    orderBy: nil,
                    id: tfsId)
                queriesTFS.append(query)
            }
            var index = 0
            getTreeWorkItemsJSONFromTFS(level: level, queriesTFS: queriesTFS, i: &index, type: .tfs)
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        
    }
    
    func getTreeWorkItemsJSONFromTFS(level: Int32, queriesTFS: [ODataQuery], i: inout Int, type: QueryResultFormat) {
        var urlComponents = self.dataProvider.getUrlComponents(server: queriesTFS[i].server, query: queriesTFS[i], format: type)
        urlComponents.user = "zubkoff"
        urlComponents.password = "!den20zu10"
        guard let url = urlComponents.url else { return }
        var index = i
        var currentLevel = level
        self.dataProvider.downloadDataFromTFS(url: url) { data in
            if let data = data {
                if let id = queriesTFS[index].id {
                    UserDefaults.standard.set(data, forKey: "\(id)")
                }
                index += 1
                if index < queriesTFS.count {
                    self.getTreeWorkItemsJSONFromTFS(level: level, queriesTFS: queriesTFS, i: &index, type: type)
                } else {
                    self.printDate(dateBegin: self.date, dateEnd: Date())
                    self.parseTreeWorkItemsJSONFromTFS(level: level, queries: queriesTFS)
                    
                    self.printDate(dateBegin: self.date, dateEnd: Date())
                    self.treeWorkItems = self.loadArrayFromCoreData(object: "TreeWorkItem", context: self.context)
                    for treeWorkItem in self.treeWorkItems {
                        print("\(treeWorkItem.level) \(treeWorkItem.parentId) \(treeWorkItem.id)")
                    }
                    print(self.treeWorkItems.count)
                    currentLevel += 1
                    if currentLevel < 4 {
                        self.addTreeWorkItems(level: &currentLevel, context: self.context)
                    } else {
                        DispatchQueue.main.async {
                            let progress: Float =  0
                            self.loadProgressView.progress = progress
                            self.loadStageLabel.text = "Обработка Продуктов из TFS..."
                        }
                        self.addProductsToCoreData(context: self.context)
                        DispatchQueue.main.async {
                            let progress: Float =  0
                            self.loadProgressView.progress = progress
                            self.loadStageLabel.text = "Обработка ЭПИ из TFS..."
                        }
                        self.addEUSsFromTFSToCoreData(context: self.context)
                        
                    }
                }
                DispatchQueue.main.async {
                    switch currentLevel {
                    case 1:
                        self.loadStageLabel.text = "Загрузка Продуктов из TFS..."
                    case 2:
                        self.loadStageLabel.text = "Загрузка ЭПИ из TFS..."
                    case 3:
                        self.loadStageLabel.text = "Загрузка ПИ из TFS..."
                    default:
                         self.loadStageLabel.text = "Загрузка из TFS..."
                    }
                    let progress: Float =  Float(index) / Float(queriesTFS.count)
                    self.loadProgressView.progress = progress
                }
                
            }
        }
    }
    
    func addEUSsFromTFSToCoreData(context: NSManagedObjectContext) {
        
        
        let step: Float = Float(1.0) / Float(epicUserStories.count)
        var i = 0
        for eus in epicUserStories {
            let tfsId = eus.tfsId
            if let nsData = UserDefaults.standard.value(forKey: "\(tfsId)") as? NSData {
                let data = nsData as Data
                let result: WorkItemJSON? = self.getType(from: data)
                if let workItem = result {
                    addEUSFromTFSToCoreData(workItem: workItem)
                }
                
            }
            i += 1
            DispatchQueue.main.async {
                self.loadStageLabel.text = "Обработка ЭПИ из TFS: \(i) из \(self.epicUserStories.count)"
                let progress = self.loadProgressView.progress + step
                self.loadProgressView.progress = progress
            }
        }
        loadAllDataFromCoreData()
        performSegue(withIdentifier: "TabBarSegue", sender: nil)
    }
    
    
    func parseTreeWorkItemsJSONFromTFS (level: Int32, queries: [ODataQuery]) {
        for query in queries {
            if let id = query.id,
               let nsData = UserDefaults.standard.value(forKey: "\(id)") as? NSData {
                let data = nsData as Data
                let result: WorkItemJSON? = self.getType(from: data)
                if let workItem = result {
                    addTreeWorkItemToCoreData(level: level, workItem: workItem)
                }
                
            }
            
        }
    }
    
    
    func addTreeWorkItemToCoreData(level: Int32, workItem: WorkItemJSON) {
        let fetchRequest: NSFetchRequest<TreeWorkItem> = TreeWorkItem.fetchRequest()
        let tfsId = workItem.id
        fetchRequest.predicate = NSPredicate(format: "id == %i", tfsId)
        do {
            let results = try context.fetch(fetchRequest)
            if let result = results.first {
                if let nsData = UserDefaults.standard.value(forKey: "\(tfsId)") as? NSData {
                    let data = nsData as Data
                    result.data = data
                    for strUrl in workItem.relations {
                        if strUrl.rel == "System.LinkTypes.Hierarchy-Forward",
                            let strId = strUrl.url.components(separatedBy: "/").last,
                            let id = Int32(strId) {
                            guard let entity =  NSEntityDescription.entity(forEntityName: "TreeWorkItem", in: context) else { return }
                            let workItem = NSManagedObject(entity: entity, insertInto: context)
                            workItem.setValue(id, forKey: "id")
                            workItem.setValue(level + 1, forKey: "level") // ToDo Level
                            workItem.setValue(tfsId, forKey: "parentId")
                        }
                    }
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
    }
    

    
    func deleteTreeWorkItemsFromCoreData(context: NSManagedObjectContext) {
        treeWorkItems.removeAll()
        let fetchRequest: NSFetchRequest<TreeWorkItem> = TreeWorkItem.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            for result in results {
                context.delete(result)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
    }
    
    
    
    
    
    // MARK: PARAMETERS
    
    func addParameterToCoreData(parameter: ParametersJSON.Value, context: NSManagedObjectContext) {
        
        let fetchRequest: NSFetchRequest<Property> = Property.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", parameter.id)
        do {
            let results = try context.fetch(fetchRequest)
            if let result = results.first {
                result.name = parameter.name
                result.dataVersion = parameter.dataVersion
            } else {
                guard let entity =  NSEntityDescription.entity(forEntityName: "Property", in: context) else { return }
                let property = NSManagedObject(entity: entity, insertInto: context)
                property.setValue(parameter.id, forKey: "id")
                property.setValue(parameter.name, forKey: "name")
                property.setValue(parameter.dataVersion, forKey: "dataVersion")
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
    }
    
    
    //MARK: PARAMETERS VALUE
    
    func addParameterValueToCoreData(parameterValue: ParameterValuesJSON.Value, context: NSManagedObjectContext) {
        
        let fetchRequest: NSFetchRequest<PropertyValue> = PropertyValue.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", parameterValue.id)
        do {
            let results = try context.fetch(fetchRequest)
            if let result = results.first {
                if let property = properties.filter({$0.id == parameterValue.parameterId}).first {
                    result.property = property
                    result.dataVersion = parameterValue.dataVersion
                    result.value = parameterValue.value
                    result.isFolder = parameterValue.isFolder
                    result.parentId = parameterValue.parentId
                }
                
            } else {
                guard let entity =  NSEntityDescription.entity(forEntityName: "PropertyValue", in: context) else { return }
                let propertyValue = NSManagedObject(entity: entity, insertInto: context)
                if let property = properties.filter({$0.id == parameterValue.parameterId}).first {
                    propertyValue.setValue(parameterValue.id, forKey: "id")
                    propertyValue.setValue(parameterValue.value, forKey: "value")
                    propertyValue.setValue(property, forKey: "property")
                    propertyValue.setValue(parameterValue.parentId, forKey: "parentId")
                    
                    propertyValue.setValue(parameterValue.isFolder, forKey: "isFolder")
                    propertyValue.setValue(parameterValue.dataVersion, forKey: "dataVersion")
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
    }
    
    
    
    
    //MARK: STRATEGIC TARGETS
    
    func addStrategicTargetsToCoreData() {
        let strategicTargets = propertyValues.filter({($0.property?.name ?? "") == "Тактика"})
        for strategicTarget in strategicTargets {
            if (strategicTarget.isFolder) {
                addStrategicTargetToCoreData(strategicTarget: strategicTarget)
            }
        }
        self.strategicTargets = self.loadArrayFromCoreData(object: "StrategicTarget", context: self.context)
        for strategicTarget in strategicTargets {
            if !(strategicTarget.isFolder) {
                addTacticsToCoreData(tactic: strategicTarget)
            }
        }
        self.tactics = self.loadArrayFromCoreData(object: "Tactic", context: self.context)
    }
    

    

    
    func addStrategicTargetToCoreData(strategicTarget: PropertyValue) {
        let fetchRequest: NSFetchRequest<StrategicTarget> = StrategicTarget.fetchRequest()
        guard let strategicTargetId = strategicTarget.id else { return }
        fetchRequest.predicate = NSPredicate(format: "id == %@", strategicTargetId)
        do {
            let results = try context.fetch(fetchRequest)
            if let result = results.first {
                result.name = strategicTarget.value
            } else {
                guard let entity =  NSEntityDescription.entity(forEntityName: "StrategicTarget", in: context) else { return }
                let property = NSManagedObject(entity: entity, insertInto: context)
                property.setValue(strategicTarget.id, forKey: "id")
                property.setValue(strategicTarget.value, forKey: "name")
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
    }

    
    
    
    
    
    //MARK: TACTICS
    
    
    func addTacticsToCoreData(tactic: PropertyValue) {
        let fetchRequest: NSFetchRequest<Tactic> = Tactic.fetchRequest()
        guard let tacticId = tactic.id else { return }
        guard let parentId = tactic.parentId else { return }
        fetchRequest.predicate = NSPredicate(format: "id == %@", tacticId)
        guard let strategicTarget = strategicTargets.filter({$0.id == parentId}).first else { return }
        do {
            let results = try context.fetch(fetchRequest)
            if let result = results.first {
                result.name = tactic.value
                result.parentId = tactic.parentId
                result.strategicTarget = strategicTarget
                
            } else {
                guard let entity =  NSEntityDescription.entity(forEntityName: "Tactic", in: context) else { return }
                let property = NSManagedObject(entity: entity, insertInto: context)
                property.setValue(tactic.id, forKey: "id")
                property.setValue(tactic.value, forKey: "name")
                property.setValue(tactic.parentId, forKey: "parentId")
                property.setValue(strategicTarget, forKey: "strategicTarget")
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
    }
    
    
    
    //MARK: CATEGORIES
    
    
    func addCategoriesToCoreData() {
        let categories = propertyValues.filter({($0.property?.name ?? "") == "Категория"})
        for category in categories {
            addCategoryToCoreData(category: category)
        }
        self.categories = self.loadArrayFromCoreData(object: "Category", context: self.context)
    }
    
    func addCategoryToCoreData(category: PropertyValue) {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        guard let categoryId = category.id else { return }
        fetchRequest.predicate = NSPredicate(format: "id == %@", categoryId)
        do {
            let results = try context.fetch(fetchRequest)
            if let result = results.first {
                result.name = category.value
            } else {
                guard let entity =  NSEntityDescription.entity(forEntityName: "Category", in: context) else { return }
                let property = NSManagedObject(entity: entity, insertInto: context)
                property.setValue(category.id, forKey: "id")
                property.setValue(category.value, forKey: "name")
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
    }
    
    
    
    //MARK: DIRECTIONS
    
    
    func addDirectionToCoreData(direction: DirectionsJSON.Value, context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Direction> = Direction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", direction.id)
        do {
            let results = try context.fetch(fetchRequest)
            if let result = results.first {
                result.name = direction.name
                result.dataVersion = direction.dataVersion
                if let ord = Int32(direction.ord) {
                    result.ord = ord
                }
                result.small = direction.shortName
                if let user = self.users.filter({$0.id == direction.userId}).first {
                    result.headDirection = user
                }
                if let id = result.id, let tfsId = globalSettings.tfsDirectionDict[id] {
                    result.tfsId = tfsId
                }
            } else {
                guard let entity =  NSEntityDescription.entity(forEntityName: "Direction", in: context) else { return }
                let property = NSManagedObject(entity: entity, insertInto: context)
                property.setValue(direction.id, forKey: "id")
                property.setValue(direction.name, forKey: "name")
                property.setValue(direction.dataVersion, forKey: "dataVersion")
                if let ord = Int32(direction.ord) {
                    property.setValue(ord, forKey: "ord")
                }
                property.setValue(direction.shortName, forKey: "small")
                if let user = self.users.filter({$0.id == direction.userId}).first {
                    property.setValue(user, forKey: "headDirection")
                }
                if let tfsId = globalSettings.tfsDirectionDict[direction.id] {
                    property.setValue(tfsId, forKey: "tfsId")
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
    }
    
    // MARK: USERSTORYTYPES
    
    func addUserStoriesTypeToCoreData(context: NSManagedObjectContext) {
        deleteUserStoriesTypeFromCoreData(context: context)
        addUserStoryTypeToCoreData(id: "[ANLZ", name: "Анализ", type: "analitic", context: context)
        addUserStoryTypeToCoreData(id: "[DCMP", name: "Декомпозиция", type: "analitic", context: context)
        addUserStoryTypeToCoreData(id: "[WORK", name: "Выполнение", type: "analitic", context: context)
        addUserStoryTypeToCoreData(id: "[TEST", name: "Тестирование", type: "analitic", context: context)
        addUserStoryTypeToCoreData(id: "[ТЕСТ", name: "Тестирование", type: "analitic", context: context)
        addUserStoryTypeToCoreData(id: "[STOP", name: "Остановлено ВП", type: "analitic", context: context)
        addUserStoryTypeToCoreData(id: "[WAIT", name: "Ожидание", type: "analitic", context: context)
        addUserStoryTypeToCoreData(id: "[DOC",  name: "Документация", type: "analitic", context: context)
        addUserStoryTypeToCoreData(id: "[VND",  name: "Внедрение", type: "analitic", context: context)
        addUserStoryTypeToCoreData(id: "[VP",   name: "Ожидание ВП", type: "analitic", context: context)
        addUserStoryTypeToCoreData(id: "[K",    name: "Разработка", type: "developer", context: context)
        userStoryTypes = loadArrayFromCoreData(object: "UserStoryType", context: context)
    }
    
    func deleteUserStoriesTypeFromCoreData(context: NSManagedObjectContext) {
        userStoryTypes.removeAll()
        let fetchRequest: NSFetchRequest<UserStoryType> = UserStoryType.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            for result in results {
                context.delete(result)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
    }
    
    func addUserStoryTypeToCoreData(id: String, name: String, type: String, context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<UserStoryType> = UserStoryType.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        do {
            let results = try context.fetch(fetchRequest)
            if let result = results.first {
                result.name = name
                result.type = type
          } else {
                guard let entity =  NSEntityDescription.entity(forEntityName: "UserStoryType", in: context) else { return }
                let property = NSManagedObject(entity: entity, insertInto: context)
                property.setValue(id, forKey: "id")
                property.setValue(name, forKey: "name")
                property.setValue(type, forKey: "type")
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
    }
    
    //MARK: PRODUCTS
    
    func addProductsToCoreData(context: NSManagedObjectContext) {
        let products = treeWorkItems.filter({$0.level == Int32(1)})
        for product in products {
            if let nsData = UserDefaults.standard.value(forKey: "\(product.id)") as? NSData {
                let data = nsData as Data
                let result: WorkItemJSON? = self.getType(from: data)
                if let workItem = result,
                    let state = workItem.fields.state,
                    let productOwner = workItem.fields.productOwner {
                        addProductToCoreData(name: workItem.fields.title!,
                                             tfsId: product.id,
                                             directionId: product.parentId,
                                             state: state,
                                             productOwner: productOwner,
                                             context: context)
                    
                }
                
            }
        }
        self.products = loadArrayFromCoreData(object: "Product", context: context)
    }
    
    
    func addProductToCoreData(name: String, tfsId: Int32, directionId: Int32, state: String, productOwner: String, context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", "\(tfsId)")
        do {
            let results = try context.fetch(fetchRequest)
            if let result = results.first {
                if state != "Новый" {
                    context.delete(result)
                } else {
                    result.name = name
                    result.tfsId = tfsId
                    if let direction = directions.filter({$0.tfsId == directionId}).first {
                        result.direction = direction
                        direction.products?.adding(result)
                    }
                    if let user = users.filter({productOwner.contains($0.fio!)}).first {
                        result.user = user
                        user.products?.adding(result)
                    }
                }
                
            } else {
                guard let entity =  NSEntityDescription.entity(forEntityName: "Product", in: context) else { return }
                let property = NSManagedObject(entity: entity, insertInto: context)
                property.setValue("\(tfsId)", forKey: "id")
                property.setValue(name, forKey: "name")
                property.setValue(tfsId, forKey: "tfsId")
                if let direction = directions.filter({$0.tfsId == directionId}).first {
                    property.setValue(direction, forKey: "direction")
                    direction.products?.adding(property as! Product)
                }
                if let user = users.filter({productOwner.contains($0.fio!)}).first {
                    property.setValue(user, forKey: "user")
                    user.products?.adding(property as! Product)
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
    }
    
    
    
    //MARK: QUOTAS
    

    func addQuotaToCoreData(quota: QuotasJSON.Value, context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Quota> = Quota.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "direction.id == %@", quota.directionId)
        do {
            let results = try context.fetch(fetchRequest)
            guard let date = convertString1cToDate(from: quota.quart) else { return }
            if let result = results.filter({$0.quart == date}).first {
                result.storePointAnaliticPlan = quota.storePointAnaliticPlan
                result.storePointDevPlan = quota.storePointDevPlan
            } else {
                guard let entity =  NSEntityDescription.entity(forEntityName: "Quota", in: context) else { return }
                let property = NSManagedObject(entity: entity, insertInto: context)
                property.setValue(date, forKey: "quart")
                property.setValue(quota.storePointDevPlan, forKey: "storePointDevPlan")
                property.setValue(quota.storePointAnaliticPlan, forKey: "storePointAnaliticPlan")
                if let direction = self.directions.filter({$0.id == quota.directionId}).first {
                    property.setValue(direction, forKey: "direction")
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
    }
    
    //MARK: BUSINESS VALUES
    
    func addBusinessValuesToCoreData() {
        let businessValues = propertyValues.filter({($0.property?.name ?? "") == "Ценность"})
        for businessValue in businessValues {
            addBusinessValueToCoreData(businessValue: businessValue)
        }
        let businessValuesOld = propertyValues.filter({($0.property?.name ?? "") == "Оценка по методу Moscow"})
        for businessValue in businessValuesOld {
            addBusinessValueToCoreData(businessValue: businessValue)
        }
        self.businessValues = self.loadArrayFromCoreData(object: "BusinessValue", context: self.context)
    }
    
    func getBusinessValueInt32(value: String) -> Int32 {
        if value.contains("[08]") { return Int32(8) }
        if value.contains("[16]") { return Int32(16) }
        if value.contains("[32]") { return Int32(32) }
        if value.contains("[64]") { return Int32(64) }
        if value.contains("[008]") { return Int32(8) }
        if value.contains("[016]") { return Int32(16) }
        if value.contains("[032]") { return Int32(32) }
        if value.contains("[064]") { return Int32(64) }
        if value.contains("[128]") { return Int32(128) }
        return Int32(128)
    }
    
    func addBusinessValueToCoreData(businessValue: PropertyValue) {
        let fetchRequest: NSFetchRequest<BusinessValue> = BusinessValue.fetchRequest()
        guard let businessValueId = businessValue.id else { return }
        fetchRequest.predicate = NSPredicate(format: "id == %@", businessValueId)
        do {
            let results = try context.fetch(fetchRequest)
            if let result = results.first {
                result.name = businessValue.value
                if let value = businessValue.value {
                    result.value = getBusinessValueInt32(value: value)
                }
            } else {
                guard let entity =  NSEntityDescription.entity(forEntityName: "BusinessValue", in: context) else { return }
                let property = NSManagedObject(entity: entity, insertInto: context)
                property.setValue(businessValue.id, forKey: "id")
                property.setValue(businessValue.value, forKey: "name")
                if let value = businessValue.value {
                    property.setValue(getBusinessValueInt32(value: value), forKey: "value")
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
    }
    
   
    
    
    //MARK: DEPTS
    
    func addDeptToCoreData(dept: DeptsJSON.Value, context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Dept> = Dept.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", dept.id)
        do {
            let results = try context.fetch(fetchRequest)
            if let result = results.first {
                result.name = dept.description
                result.headId = dept.headId
                result.parentId = dept.parentId
                result.dataVersion = dept.dataVersion
                if let oracle = dept.дополнительныеРеквизиты.first {
                    result.oracleId = oracle.value
                }
            } else {
                guard let entity =  NSEntityDescription.entity(forEntityName: "Dept", in: context) else { return }
                let property = NSManagedObject(entity: entity, insertInto: context)
                property.setValue(dept.id, forKey: "id")
                property.setValue(dept.description, forKey: "name")
                property.setValue(dept.parentId, forKey: "parentId")
                property.setValue(dept.headId, forKey: "headId")
                property.setValue(dept.dataVersion, forKey: "dataVersion")
                if let oracle = dept.дополнительныеРеквизиты.first {
                    property.setValue(oracle.value, forKey: "oracleId")
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
    }
    
   
    
    
    //MARK: TYPE TEAMS
    
    func addTypeTeamsToCoreData(context: NSManagedObjectContext) {
        
        
        let fetchRequest: NSFetchRequest<TypeTeam> = TypeTeam.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            for result in results {
                context.delete(result)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        guard let entity =  NSEntityDescription.entity(forEntityName: "TypeTeam", in: context) else { return }
        for index in 0..<4 {
            let property = NSManagedObject(entity: entity, insertInto: context)
            property.setValue(String(index), forKey: "id")
            let name = globalSettings.typeTeamList[index]
            property.setValue(name.rawValue, forKey: "id")
        }
        
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
    }
    
   
    
    
    //MARK: TEAMS

    func addTeamToCoreData(userGroup: UserGroupsJSON.Value, context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Team> = Team.fetchRequest()
        let team: Team
        fetchRequest.predicate = NSPredicate(format: "id == %@", userGroup.id)
        do {
            let results = try context.fetch(fetchRequest)
            if let result = results.first {
                result.name = userGroup.description
                result.dataVersion = userGroup.dataVersion
                team = result
            } else {
                guard let entity =  NSEntityDescription.entity(forEntityName: "Team", in: context) else { return }
                let property = NSManagedObject(entity: entity, insertInto: context)
                property.setValue(userGroup.id, forKey: "id")
                property.setValue(userGroup.description, forKey: "name")
                property.setValue(userGroup.dataVersion, forKey: "dataVersion")
                guard let teamNew = property as? Team else { return }
                team = teamNew
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        for user in userGroup.content {
            addUserToCoreData(userId: user.userId, team: team, context: context)
        }
    }
    

    
  
    
    // MARK: STATES
    
    func addStateToCoreData(name: String) {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        do {
            let results = try context.fetch(fetchRequest)
            if let result = results.first {
                result.name = name
            } else {
                let id = states.count + 1
                guard let entity =  NSEntityDescription.entity(forEntityName: "State", in: context) else { return }
                let property = NSManagedObject(entity: entity, insertInto: context)
                property.setValue(id, forKey: "id")
                property.setValue(name, forKey: "name")
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
    }
    
 
    
    //MARK: USERS
    
    func addUserToCoreData(userId: String, team: Team, context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", userId)
        do {
            let results = try context.fetch(fetchRequest)
            if let result = results.first {
                result.team = team
            } else {
                guard let entity =  NSEntityDescription.entity(forEntityName: "User", in: context) else { return }
                let property = NSManagedObject(entity: entity, insertInto: context)
                property.setValue(userId, forKey: "id")
                property.setValue(team, forKey: "team")
                
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
    }
    
    func addUserDataToCoreData(usersJSON: [UsersJSON.Value], context: NSManagedObjectContext) {
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            for user in results {
                if let userJSON = usersJSON.filter({$0.id == user.id}).first {
                    user.fio = userJSON.description
                    if let email = userJSON.контактнаяИнформация.filter({$0.lineNumber == "1"}).first {
                        user.email = email.value
                    }
                    if let phone = userJSON.контактнаяИнформация.filter({$0.lineNumber == "2"}).first {
                        user.phone = phone.value
                    }
                    if let oracleId = userJSON.дополнительныеРеквизиты.first?.value {
                        user.oracleId = oracleId
                    }
                    if let dept = depts.filter({$0.id == userJSON.deptId}).first {
                        user.dept = dept
                    }
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
    }
    

    
    
    //MARK: EPIC USER STORIES
    
    func addEpicUserStoryToCoreData(epicUserStory: EpicUserStoriesJSON.Value, context: NSManagedObjectContext) {
        
        
        let fetchRequest: NSFetchRequest<EpicUserStory> = EpicUserStory.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", epicUserStory.id)
        do {
            let results = try context.fetch(fetchRequest)
            if let result = results.first {
                result.name = epicUserStory.title
                result.num = epicUserStory.num
                result.dataVersion = epicUserStory.dataVersion
                if let directionNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict[.direction19]}).first {
                    if let direction = directions.filter({$0.id == directionNew.valueId}).first {
                       result.direction = direction
                    }
                }
                if let directionNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict[.direction18]}).first {
                    if let direction = directions.filter({$0.id == directionNew.valueId}).first {
                        result.direction = direction
                    }
                }
                if let categoryNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict[.category]}).first {
                    if let category = categories.filter({$0.id == categoryNew.valueId}).first {
                        result.category = category
                    }
                }
                if let tacticNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict[.tactic]}).first {
                    if let tactic = tactics.filter({$0.id == tacticNew.valueId}).first {
                        result.tactic = tactic
                    }
                }
                if let valueNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict[.businessValue19]}).first {
                    if let valueB = businessValues.filter({$0.id == valueNew.valueId}).first {
                        result.businessValue = valueB
                    }
                }
                if let valueNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict[.businessValue18]}).first {
                    if let valueB = businessValues.filter({$0.id == valueNew.valueId}).first {
                        result.businessValue = valueB
                    }
                }
                
                if let storePointAnaliticNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict[.storePointsAnaliticPlan]}).first {
                    result.storePointsAnaliticPlane = storePointAnaliticNew.valueId
                    let storePointAnaliticNewArray = Array(storePointAnaliticNew.valueId)
                    var storePoint: String = ""
                    var inBounds = false
                    for i in (0..<storePointAnaliticNewArray.count) {
                        if storePointAnaliticNewArray[i] == "(" {
                            inBounds = true
                        } else {
                            if storePointAnaliticNewArray[i] == ")" {
                                inBounds = false
                            }
                            if inBounds {
                                storePoint = storePoint + String(storePointAnaliticNewArray[i])
                            }
                        }
                    }
                    if storePoint.count > 0 {
                        result.storePointsAnaliticPlane = storePoint
                    }
                    
                }
                if let storePointDeveloperNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict[.storePointsDevPlan]}).first {
                    result.storePointsDevPlane = storePointDeveloperNew.valueId
                }
                if let tfsUrl = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict[.eusUrl19]}).first {
                    result.tfsUrl = tfsUrl.valueId
                    let tfsUrlArray = Array(tfsUrl.valueId)
                    var tfsId: String = ""
                    for i in (0..<tfsUrlArray.count).reversed() {
                        if tfsUrlArray[i] != "/" {
                            tfsId = String(tfsUrlArray[i]) + tfsId
                        } else {
                            break
                        }
                    }
                    if tfsId.count > 10,
                        let last = tfsId.components(separatedBy: "_workitems?id=").last,
                        let first = last.components(separatedBy: "&_a=edit").first {
                        tfsId = first
                        
                        
                    }
                    if let tfsId = Int32(tfsId) {
                        result.tfsId = tfsId
                        
                    }
                }
                
                if let tfsUrl = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict[.eusUrl18]}).first {
                    result.tfsUrl = tfsUrl.valueId
                    let tfsUrlArray = Array(tfsUrl.valueId)
                    var tfsId: String = ""
                    for i in (0..<tfsUrlArray.count).reversed() {
                        if tfsUrlArray[i] != "/" {
                            tfsId = String(tfsUrlArray[i]) + tfsId
                        } else {
                            break
                        }
                    }
                    if tfsId.count > 10,
                        let last = tfsId.components(separatedBy: "_workitems?id=").last,
                        let first = last.components(separatedBy: "&_a=edit").first {
                        tfsId = first
                        
                        
                    }
                    if let tfsId = Int32(tfsId) {
                        result.tfsId = tfsId
                        
                    }
                }
                
                if let quartNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict[.quart]}).first {
                    result.quart = quartNew.valueId
                    
                }
                
                if let deathLineNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict[.deathline]}).first {
                    result.deathLine = convertString1cToDate(from: deathLineNew.valueId)
                    
                }
                
                if let priotiryNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict[.priority]}).first {
                    if let priority = Int32(priotiryNew.valueId) {
                        result.priority = priority
                    }
                }
                
                
                result.dateCreate = convertString1cToDate(from: epicUserStory.dateCreate)
                result.dateBegin = convertString1cToDate(from: epicUserStory.dateRegistration)
                result.noShow = epicUserStory.deletionMark
                
                if let productOwner = users.filter({$0.id == epicUserStory.productOwnerId}).first {
                    result.productOwner = productOwner
                }
                if let dept = depts.filter({$0.id == epicUserStory.dept}).first {
                    result.dept = dept
                }
            } else {
                guard let entity =  NSEntityDescription.entity(forEntityName: "EpicUserStory", in: context) else { return }
                let property = NSManagedObject(entity: entity, insertInto: context)
                property.setValue(epicUserStory.id, forKey: "id")
                property.setValue(epicUserStory.title, forKey: "name")
                property.setValue(epicUserStory.num, forKey: "num")
                property.setValue(epicUserStory.dataVersion, forKey: "dataVersion")
                if let directionNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict[.direction19]}).first {
                    if let direction = directions.filter({$0.id == directionNew.valueId}).first {
                        property.setValue(direction, forKey: "direction")
                    }
                }
                if let directionNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict[.direction18]}).first {
                    if let direction = directions.filter({$0.id == directionNew.valueId}).first {
                        property.setValue(direction, forKey: "direction")
                    }
                }
                if let categoryNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict[.category]}).first {
                    if let category = categories.filter({$0.id == categoryNew.valueId}).first {
                        property.setValue(category, forKey: "category")
                    }
                }
                if let tacticNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict[.tactic]}).first {
                    if let tactic = tactics.filter({$0.id == tacticNew.valueId}).first {
                        property.setValue(tactic, forKey: "tactic")
                    }
                }
                if let valueNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict[.businessValue19]}).first {
                    if let valueB = businessValues.filter({$0.id == valueNew.valueId}).first {
                        property.setValue(valueB, forKey: "businessValue")
                    }
                }
                if let valueNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict[.businessValue18]}).first {
                    if let valueB = businessValues.filter({$0.id == valueNew.valueId}).first {
                        property.setValue(valueB, forKey: "businessValue")
                    }
                }
                if let storePointAnaliticNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict[.storePointsAnaliticPlan]}).first {
                    property.setValue(storePointAnaliticNew.valueId, forKey: "storePointsAnaliticPlane")
                    let storePointAnaliticNewArray = Array(storePointAnaliticNew.valueId)
                    var storePoint: String = ""
                    var inBounds = false
                    for i in (0..<storePointAnaliticNewArray.count) {
                        if storePointAnaliticNewArray[i] == "(" {
                            inBounds = true
                        } else {
                            if storePointAnaliticNewArray[i] == ")" {
                                inBounds = false
                            }
                            if inBounds {
                                storePoint = storePoint + String(storePointAnaliticNewArray[i])
                            }
                        }
                    }
                    if storePoint.count > 0 {
                        property.setValue(storePoint, forKey: "storePointsAnaliticPlane")
                    }
                }
                
                if let storePointDeveloperNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict[.storePointsDevPlan]}).first {
                    property.setValue(storePointDeveloperNew.valueId, forKey: "storePointsDevPlane")

                }
                
                if let quartNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict[.quart]}).first {
                    property.setValue(quartNew.valueId, forKey: "quart")
                    
                }
                
                if let deathLineNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict[.deathline]}).first {
                    property.setValue(convertString1cToDate(from: deathLineNew.valueId), forKey: "deathLine")
                    
                }
                
                if let priotiryNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict[.priority]}).first {
                    if let priority = Int32(priotiryNew.valueId) {
                        property.setValue(priority, forKey: "priority")
                    }
                }
                
                if let tfsUrl = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict[.eusUrl19]}).first {
                    property.setValue(tfsUrl.valueId, forKey: "tfsUrl")
                    let tfsUrlArray = Array(tfsUrl.valueId)
                    var tfsId: String = ""
                    for i in (0..<tfsUrlArray.count).reversed() {
                        if tfsUrlArray[i] != "/" {
                            tfsId = String(tfsUrlArray[i]) + tfsId
                        } else {
                            break
                        }
                    }
                    if tfsId.count > 10,
                        let last = tfsId.components(separatedBy: "_workitems?id=").last,
                        let first = last.components(separatedBy: "&_a=edit").first {
                        tfsId = first
                    }
                    if let tfsId = Int32(tfsId) {
                        property.setValue(tfsId, forKey: "tfsId")
                    }
                    
                }
                if let tfsUrl = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict[.eusUrl18]}).first {
                    property.setValue(tfsUrl.valueId, forKey: "tfsUrl")
                    let tfsUrlArray = Array(tfsUrl.valueId)
                    var tfsId: String = ""
                    for i in (0..<tfsUrlArray.count).reversed() {
                        if tfsUrlArray[i] != "/" {
                            tfsId = String(tfsUrlArray[i]) + tfsId
                        } else {
                            break
                        }
                    }
                    if tfsId.count > 10,
                        let last = tfsId.components(separatedBy: "_workitems?id=").last,
                        let first = last.components(separatedBy: "&_a=edit").first {
                        tfsId = first
                        
                        
                    }
                    if let tfsId = Int32(tfsId) {
                        property.setValue(tfsId, forKey: "tfsId")
                        
                    }
                }
                property.setValue(convertString1cToDate(from: epicUserStory.dateCreate), forKey: "dateCreate")
                property.setValue(convertString1cToDate(from: epicUserStory.dateRegistration), forKey: "dateBegin")
                property.setValue(epicUserStory.deletionMark, forKey: "noShow")
                if let productOwner = users.filter({$0.id == epicUserStory.productOwnerId}).first {
                    property.setValue(productOwner, forKey: "productOwner")
                }
                if let dept = depts.filter({$0.id == epicUserStory.dept}).first {
                    property.setValue(dept, forKey: "dept")
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
    }

    
    
    

    
    func fillDirectionByProductOwner() {
        for eus in epicUserStories {
            if eus.productOwner?.direction == nil {
                eus.productOwner?.directionPO = eus.direction
            }
        }
    }
    
//    func addEUSFromTFS() {
//        for eus in epicUserStories {
//            let tfsId = eus.tfsId
//            if tfsId != 0 {
//                let query = ODataQuery.init(server: globalSettings.serverTFS,
//                                            table: "workitems/\(tfsId)",
//                    filter: nil,
//                    select: nil,
//                    orderBy: nil,
//                    id: tfsId)
//
//
//                queriesTFS.append(query)
//            }
//        }
//        var index = 0
//        DispatchQueue.main.async {
//            self.loadStageLabel.text = "Загрузка данных из TFS..."
//        }
//        getDataJSONFromTFS(queriesTFS: queriesTFS, i: &index, type: .tfs)
//
//    }
    
    
    func addEUSFromTFS() {
        DispatchQueue.main.async {
            self.loadStageLabel.text = "Загрузка данных из TFS..."
        }
        // Загружаем типы ПИ в CoreData
        addUserStoriesTypeToCoreData(context: context)
        
        // Загружаем дерево ЭПИ
        getTreeWorkItems(context: context)
    }
    
    
    
    func addEUSFromTFSToCoreData(workItem: WorkItemJSON) {
        let fetchRequest: NSFetchRequest<EpicUserStory> = EpicUserStory.fetchRequest()
        let tfsId = workItem.id
        fetchRequest.predicate = NSPredicate(format: "tfsId == %i", tfsId)
        do {
            let results = try context.fetch(fetchRequest)
            if let result = results.first {
                result.tfsWorkItemType = workItem.fields.workItemType
                result.tfsState = workItem.fields.state
                if let state = states.filter({$0.name == workItem.fields.state}).first {
                    
                    result.state = state
                } else {
                    if let state = workItem.fields.state {
                        addStateToCoreData(name: state)
                        self.states = self.loadArrayFromCoreData(object: "State", context: self.context)
                        if let state = states.filter({$0.name == workItem.fields.state}).first {
                            result.state = state
                        }
                    }
                }
                
                result.tfsProductOwner = workItem.fields.productOwner
                result.tfsDateCreate = convertStringTFSToDate(from: workItem.fields.createdDate)
                result.tfsTitle = workItem.fields.title
                result.tfsLastChangeDate = convertStringTFSToDate(from: workItem.fields.lastChangeDate)
                result.tfsEndDate = convertStringTFSToDate(from: workItem.fields.endDate)
                result.tfsBusinessArea = workItem.fields.businessArea
                if let businessValue = workItem.fields.businessValue {
                    result.tfsBusinessValue = Int32(businessValue)
                }
                if let priority = workItem.fields.priority {
                    result.tfsPriority = Int32(priority)
                }
                result.tfsBeginDate = convertStringTFSToDate(from: workItem.fields.beginDate)
                result.tfsAnalitic = workItem.fields.analiticName
                result.tfsCategory = workItem.fields.categoryName
                if let value = workItem.fields.storePointsFact {
                    result.tfsStorePointFact = Double(value)
                }
                if let value = workItem.fields.storePointsPlan {
                    result.tfsStorePointPlan = Double(value)
                }
                if let value = workItem.fields.storePointsAnaliticFact {
                    result.tfsStorePointAnaliticFact = Double(value)
                }
                if let value = workItem.fields.storePointsAnaliticPlan {
                    result.tfsStorePointAnaliticPlan = Double(value)
                }
                if let value = workItem.fields.storePointsDevFact {
                    result.tfsStorePointDevFact = Double(value)
                }
                if let value = workItem.fields.storePointsDevPlan {
                    result.tfsStorePointDevPlan = Double(value)
                }
                
                let dp = getDirectionFromTFS(tfsId: tfsId)
                if let direction = dp.0 {
                    result.direction = direction
                    result.direction?.addToEpicUserStories(result)
                }
                if let product = dp.1 {
                    result.product = product
                    result.product?.addToEpicUserStiories(result)
                }
                
                let userStoryIds = self.treeWorkItems.filter({$0.parentId == tfsId})
                for userStoryId in userStoryIds {
                    if let nsData = UserDefaults.standard.value(forKey: "\(userStoryId.id)") as? NSData {
                        let data = nsData as Data
                        let workItems: WorkItemJSON? = self.getType(from: data)
                        if let workItem = workItems {
                            self.addUserStoryToCoreData(eus: result, workItem: workItem, context: context)
                        }
                        
                    }
                    
                }
                
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
    }

    
    func getDirectionFromTFS(tfsId: Int) -> (Direction?, Product?) {
        guard let firstLevelId = self.treeWorkItems.filter({$0.id == tfsId && $0.level == Int32(2)}).first?.parentId else { return (nil,nil) }
        guard let zeroLevelId  = self.treeWorkItems.filter({$0.id == firstLevelId && $0.level == Int32(1)}).first?.parentId else { return (nil,nil) }
        guard let directionId = globalSettings.tfsDirectionDict.filter({$0.value == zeroLevelId}).first?.key else { return (nil,nil) }
        return (self.directions.filter({$0.id == directionId}).first, self.products.filter({$0.tfsId == firstLevelId}).first)
    }

    
    func addUserStoryToCoreData(eus: EpicUserStory, workItem: WorkItemJSON, context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<UserStory> = UserStory.fetchRequest()
        let tfsId = workItem.id
        dump(workItem)
        fetchRequest.predicate = NSPredicate(format: "tfsId == %i", tfsId)
        do {
            let results = try context.fetch(fetchRequest)
            if let result = results.first {
                if workItem.fields.state == "Удален" {
                    context.delete(result)
                } else {
                    for usType in self.userStoryTypes {
                        if let title = result.title, let id = usType.id, title.contains(id) {
                            result.userStoryType = usType
                            usType.addToUserStories(result)
                        }
                    }
                    result.tfsTeam = workItem.fields.teamName
                    result.tfsState = workItem.fields.state
                    if let state = states.filter({$0.name == workItem.fields.state}).first {
                        result.state = state
                        state.userStories?.adding(result)
                    } else {
                        if let state = workItem.fields.state {
                            addStateToCoreData(name: state)
                            self.states = self.loadArrayFromCoreData(object: "State", context: self.context)
                            if let state = states.filter({$0.name == workItem.fields.state}).first {
                                result.state = state
                                state.userStories?.adding(result)
                            }
                        }
                    }
                    
                    if let productOwner = workItem.fields.productOwner,
                        let user = users.filter({productOwner.contains($0.fio!)}).first {
                        result.productOwner = user
                        user.productOwnersUS?.adding(result)
                    }
                    
                    result.dateCreate = convertStringTFSToDate(from: workItem.fields.createdDate)
                    result.title = workItem.fields.title
                    result.tfsLastChangeDate = convertStringTFSToDate(from: workItem.fields.lastChangeDate)
                    result.dateEnd = convertStringTFSToDate(from: workItem.fields.endDate)
                    result.dateBegin = convertStringTFSToDate(from: workItem.fields.beginDate)
                    if let businessValue = workItem.fields.businessValue {
                        result.businessValue = Int32(businessValue)
                    }
                    if let priority = workItem.fields.priority {
                        result.priority = Int32(priority)
                    }
                    if let analitic = workItem.fields.analiticName,
                        let user = users.filter({analitic.contains($0.fio!)}).first {
                        result.analitic = user
                        user.analiticsUS?.adding(result)
                    }
                    
                    if let value = workItem.fields.storePointsFact {
                        result.storePointFact = Double(value)
                    }
                    if let value = workItem.fields.storePointsPlan {
                        result.storePointPlan = Double(value)
                    }
                    result.epicUserStory = eus
                    eus.userStories?.adding(result)
                }
            } else {
                guard let entity =  NSEntityDescription.entity(forEntityName: "UserStory", in: context) else { return }
                let property = NSManagedObject(entity: entity, insertInto: context)
                property.setValue(workItem.id, forKey: "id")
                for usType in self.userStoryTypes {
                    if let title = workItem.fields.title, let id = usType.id, title.contains(id) {
                        property.setValue(usType, forKey: "userStoryType")
                        usType.addToUserStories(property as! UserStory)
                    }
                }
                property.setValue(workItem.fields.teamName, forKey: "tfsTeam")
                property.setValue(workItem.fields.state, forKey: "tfsState")
                if let state = states.filter({$0.name == workItem.fields.state}).first {
                    property.setValue(state, forKey: "state")
                    state.addToUserStories(property as! UserStory)
                } else {
                    if let state = workItem.fields.state {
                        addStateToCoreData(name: state)
                        self.states = self.loadArrayFromCoreData(object: "State", context: self.context)
                        if let state = states.filter({$0.name == workItem.fields.state}).first {
                            property.setValue(state, forKey: "state")
                            state.addToUserStories(property as! UserStory)
                        }
                    }
                }
                
                if let productOwner = workItem.fields.productOwner,
                    let user = users.filter({productOwner.contains($0.fio!)}).first {
                    property.setValue(user, forKey: "productOwner")
                    user.productOwnersUS?.adding(property as! UserStory)
                }
                property.setValue(convertStringTFSToDate(from: workItem.fields.createdDate), forKey: "dateCreate")
                property.setValue(workItem.fields.title, forKey: "title")
                property.setValue(convertStringTFSToDate(from: workItem.fields.lastChangeDate), forKey: "tfsLastChangeDate")
                property.setValue(convertStringTFSToDate(from: workItem.fields.beginDate), forKey: "dateBegin")
                property.setValue(convertStringTFSToDate(from: workItem.fields.endDate), forKey: "dateEnd")
                if let businessValue = workItem.fields.businessValue {
                    property.setValue(Int32(businessValue), forKey: "businessValue")
                }
                if let priority = workItem.fields.priority {
                    property.setValue(Int32(priority), forKey: "priority")
                }
                if let analitic = workItem.fields.analiticName,
                    let user = users.filter({analitic.contains($0.fio!)}).first {
                    property.setValue(user, forKey: "analitic")
                    user.analiticsUS?.adding(property as! UserStory)
                }
                
                if let value = workItem.fields.storePointsFact {
                    property.setValue(Double(value), forKey: "storePointFact")
                }
                if let value = workItem.fields.storePointsPlan {
                    property.setValue(Double(value), forKey: "storePointPlan")
                }
                property.setValue(eus, forKey: "epicUserStory")
                eus.userStories?.adding(property as! UserStory)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
            return
        }
    }
    
    func createPatchQuery(eus: EpicUserStory) {
        guard let eusId = eus.id else { return }
        let query = ODataQuery.init(server: globalSettings.server1C,
                                table: "Catalog_ВнутренниеДокументы/",
                                filter: "Ref_Key eq guid'\(eusId)'",
                                select: "Ref_Key, ВидДокумента_Key, DataVersion, Description, ВопросДеятельности_Key, ДатаСоздания, ДатаРегистрации, Заголовок, Подготовил_Key, Подразделение_Key, РегистрационныйНомер, Содержание, ДополнительныеРеквизиты, DeletionMark",
                                orderBy: nil,
                                id: nil)
        var urlComponents = self.dataProvider.getUrlComponents(server: query.server, query: query, format: .json)
        urlComponents.user = "zubkoff"
        urlComponents.password = "!den20zu10"
        guard let url = urlComponents.url else { return }

        self.dataProvider.downloadDataFromTFS(url: url) { data in
            if let data = data {
                let dataStr1 = String(decoding: data, as: UTF8.self)
                print(dataStr1)
                var epicUserStoriesJSON: EpicUserStoriesJSON? = self.getType(from: data)
                if let epicUserStoryJSON = epicUserStoriesJSON?.value.first {
                    let parameters = epicUserStoryJSON.дополнительныеРеквизиты
                    let currentType = epicUserStoryJSON.eusType ==  self.globalSettings.eusTypeDict[.eus19]
                    let storePointsAnaliticFact: TypeParameters = currentType ? .storePointsAnaliticFact19 : .storePointsAnaliticFact18
                    guard let pIdOA = self.globalSettings.parameterDict[storePointsAnaliticFact] else { return }
                    let storePointsDevFact: TypeParameters = currentType ? .storePointsDevFact19 : .storePointsDevFact18
                    guard let pIdORPO = self.globalSettings.parameterDict[storePointsDevFact] else { return }
                    guard let pIdStatus = self.globalSettings.parameterDict[.visa] else { return }
                    var haveParemeter = [pIdOA : false, pIdORPO : false, pIdStatus : false]
                    guard let id = parameters.first?.id else { return }
                    var lineNumber: Int = 0
                    for i in 0..<parameters.count {
                        if let ln = Int(parameters[i].lineNumber), ln > lineNumber {
                            lineNumber = ln
                        }
                        if parameters[i].parameterId == pIdOA {
                            epicUserStoriesJSON?.value[0].дополнительныеРеквизиты[i].valueId = String(eus.tfsStorePointAnaliticFact)
                            haveParemeter[pIdOA] = true
                        }
                        if parameters[i].parameterId == pIdORPO {
                            epicUserStoriesJSON?.value[0].дополнительныеРеквизиты[i].valueId = String(eus.tfsStorePointDevFact)
                            haveParemeter[pIdORPO] = true
                        }
                        if parameters[i].parameterId == pIdStatus && eus.state?.name == "Выполнено" {
                            epicUserStoriesJSON?.value[0].дополнительныеРеквизиты[i].valueId = "Реализована"
                            haveParemeter[pIdStatus] = true
                        }
                    }
                    if !haveParemeter[pIdOA]! {
                        lineNumber += 1
                        let lnString = String(lineNumber)
                        epicUserStoriesJSON?.value[0].дополнительныеРеквизиты.append(EpicUserStoriesJSON.ДополнительныеРеквизиты(id: id, lineNumber: lnString, parameterId: pIdOA, valueId: String(eus.tfsStorePointAnaliticFact), valueType: "Edm.Double", value: ""))
                    }
                    if !haveParemeter[pIdORPO]! {
                        lineNumber += 1
                        let lnString = String(lineNumber)
                        epicUserStoriesJSON?.value[0].дополнительныеРеквизиты.append(EpicUserStoriesJSON.ДополнительныеРеквизиты(id: id, lineNumber: lnString, parameterId: pIdORPO, valueId: String(eus.tfsStorePointDevFact), valueType: "Edm.Double", value: ""))
                    }
                    if !haveParemeter[pIdStatus]! {
                        lineNumber += 1
                        let lnString = String(lineNumber)
                        epicUserStoriesJSON?.value[0].дополнительныеРеквизиты.append(EpicUserStoriesJSON.ДополнительныеРеквизиты(id: id, lineNumber: lnString, parameterId: pIdStatus, valueId: "Реализована", valueType: "StandardODATA.СостоянияЭПИ", value: ""))
                    }
                    let query = ODataQuery.init(server: self.globalSettings.server1C,
                                                table: "Catalog_ВнутренниеДокументы('\(eusId)')",
                                                filter: nil,
                        select: nil,
                        orderBy: nil,
                        id: nil)
                    var urlComponents = self.dataProvider.getUrlComponents(server: query.server, query: query, format: .json)
                    urlComponents.user = "zubkoff"
                    urlComponents.password = "!den20zu10"
                    guard let url = urlComponents.url else { return }
                    var request = URLRequest(url: url)
                    request.httpMethod = "PATCH"
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    let encoder = JSONEncoder()
                    guard let httpBody = try? encoder.encode(epicUserStoriesJSON?.value[0]) else { return }
                    let dataStr = String(decoding: httpBody, as: UTF8.self)
                    print(dataStr)
                    
                    request.httpBody = httpBody
                    let session = URLSession.shared
                    session.dataTask(with: request) { (data, response, error) in
                        
                        guard let response = response, let data = data else { return }
                        
                        print(response)
                        
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                            print(json)
                        } catch {
                            print(error)
                        }
                    }.resume()
                }
            }
        }
    }
    
   
}
