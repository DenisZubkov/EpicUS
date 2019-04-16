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
    var treeWorkItems: [TreeWorkItem] = []
    var savedModifyDate: Date = Date() - 1000000000
    var loadType: LoadType = .first
    
    
    var date = Date()
    
    
    var queries: [ODataQuery] = []
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
        queries = globalSettings.prepareQueryArray()
        
     }
    
    override func viewDidAppear(_ animated: Bool) {
        var index = 0
        loadProgressView.progress = 0
        switch loadType {
        case .none:
            loadAllDataFromCoreData()
            performSegue(withIdentifier: "TabBarSegue", sender: nil)
        case .first:
            //getTreeWorkItems(context: context)
            loadStageLabel.text = "Загрузка данных из 1С..."
            getDataJSONFromTFS(queriesTFS: queries, i: &index, type: .json)
            loadAllDataFromCoreData()
        case .background:
            loadAllDataFromCoreData()
        }
        // getTreeWorkItems(context: context)

    }
    
    // MARK: COMMON METODS
    
    func loadAllDataFromCoreData() {
        loadDirectionsFromCoreData(to: &directions, context: context)
        loadDeptsFromCoreData(to: &depts, context: context)
        loadTeamsFromCoreData(to: &teams, context: context)
        loadUsersFromCoreData(to: &users, context: context)
        loadTacticsFromCoreData(to: &tactics, context: context)
        loadTypeTeamsFromCoreData(to: &typeTeams, context: context)
        loadCategoriesFromCoreData(to: &categories, context: context)
        loadPropertiesFromCoreData(to: &properties, context: context)
        loadBusinessValuesFromCoreData(to: &businessValues, context: context)
        loadPropertyValuesFromCoreData(to: &propertyValues, context: context)
        loadEpicUserStoriesFromCoreData(to: &epicUserStories, context: context)
        loadStrategicTargetsFromCoreData(to: &strategicTargets, context: context)
        loadTreeWorkItemsFromCoreData(to: &treeWorkItems, context: context)
    }
    
    func convertString1cToDate(from dateString: String?) -> Date? {
        guard var str = dateString else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale.init(identifier: "ru_RU")
        str = str.replacingOccurrences(of: "T", with: " ")
        return dateFormatter.date(from: str)
    }
    
    func convertStringTFSToDate(from dateString: String?) -> Date? {
        guard let str = dateString else { return nil }
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "ru_RU")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let date = RFC3339DateFormatter.date(from: str)
        return date
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
    
    
    func getDataJSON(queries: [ODataQuery], i: inout Int) {
        let urlComponents = self.dataProvider.getUrlComponents(server: queries[i].server, query: queries[i], format: .json)
        guard let url = urlComponents.url else { return }
        var index = i
        self.dataProvider.downloadData(url: url) { data in
            if let data = data {
                //                print(data)
                //                print(self.queries[index].table)
                UserDefaults.standard.set(data, forKey: "\(index)")
                index += 1
                if index < queries.count {
                    DispatchQueue.main.async {
                        let progress: Float =  Float(index) / (Float(queries.count) * Float(1.5))
                        self.loadProgressView.progress = progress
                    }
                    self.getDataJSON(queries: queries, i: &index)
                } else {
                    self.printDate(dateBegin: self.date, dateEnd: Date())
                    self.ParseJSON(index: index)
                    self.printDate(dateBegin: self.date, dateEnd: Date())
                }
                
            }
        }
    }
    
    
    
    func getDataJSONFromTFS(queriesTFS: [ODataQuery], i: inout Int, type: queryResultFormat) {
        var urlComponents = self.dataProvider.getUrlComponents(server: queriesTFS[i].server, query: queriesTFS[i], format: type)
        urlComponents.user = "zubkoff"
        urlComponents.password = "!den20zu10"
        guard let url = urlComponents.url else { return }
        //        print(url)
        var index = i
        self.dataProvider.downloadDataFromTFS(url: url) { data in
            if let data = data {
                
                UserDefaults.standard.set(data, forKey: "\(index)")
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
                        self.ParseJSON(index: index)
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
                    addWorkItemToCoreData(workItem: workItem)
                }
                
            }
            
        }
        performSegue(withIdentifier: "TabBarSegue", sender: nil)
    }
    
    func ParseJSON(index: Int) {
        let step = Float(1) / (Float(queries.count) * Float(1.5))
        if let nsData = UserDefaults.standard.value(forKey: "0") as? NSData {
            let data = nsData as Data
            let parametersJSON: ParametersJSON? = self.getType(from: data)
            if let parameters = parametersJSON?.value {
                for parameter in parameters {
                    addParameterToCoreData(parameter: parameter, context: context)
                }
                loadPropertiesFromCoreData(to: &properties, context: context)
                print("Properties: \(self.properties.count)")
            }
        }
        DispatchQueue.main.async {
            let progress = self.loadProgressView.progress + step
            self.loadProgressView.progress = progress
        }
        
        if let nsData = UserDefaults.standard.value(forKey: "1") as? NSData {
            let data = nsData as Data
            let parameterValuesJSON: ParameterValuesJSON? = self.getType(from: data)
            if let parameterValues = parameterValuesJSON?.value {
                for parameterValue in parameterValues {
                    addParameterValueToCoreData(parameterValue: parameterValue, context: context)
                }
                loadPropertyValuesFromCoreData(to: &propertyValues, context: context)
                print("PropertyValues: \(self.propertyValues.count)")
            }
        }
        
        DispatchQueue.main.async {
            let progress = self.loadProgressView.progress + step
            self.loadProgressView.progress = progress
        }
        
        
        addStrategicTargetsToCoreData()
        print("StrategicTargets: \(self.strategicTargets.count)")
        print("Tactics: \(self.tactics.count)")
        
        addCategoriesToCoreData()
        print("Categories: \(self.categories.count)")
        addBusinessValuesToCoreData()
        print("BusinessValues: \(self.businessValues.count)")
        
        addTypeTeamsToCoreData(context: context)
        loadTypeTeamsFromCoreData(to: &typeTeams, context: context)
        print("TypeTeams: \(self.typeTeams.count)")
        
        DispatchQueue.main.async {
            let progress = self.loadProgressView.progress + step
            self.loadProgressView.progress = progress
        }
        
        if let nsData = UserDefaults.standard.value(forKey: "2") as? NSData {
            let data = nsData as Data
            let deptsJSON: DeptsJSON? = self.getType(from: data)
            if let depts = deptsJSON?.value {
                for dept in depts {
                    addDeptToCoreData(dept: dept, context: context)
                }
                loadDeptsFromCoreData(to: &self.depts, context: context)
                print("Depts: \(self.depts.count)")
            }
        }
        
        DispatchQueue.main.async {
            let progress = self.loadProgressView.progress + step
            self.loadProgressView.progress = progress
        }
        
        if let nsData = UserDefaults.standard.value(forKey: "3") as? NSData {
            let data = nsData as Data
            let userGroupsJSON: UserGroupsJSON? = self.getType(from: data)
            if let userGroups = userGroupsJSON?.value {
                for userGroup in userGroups {
                    addTeamToCoreData(userGroup: userGroup, context: context)
                }
                loadTeamsFromCoreData(to: &self.teams, context: context)
                
                print("Teams: \(self.teams.count)")
            }
        }
        
        DispatchQueue.main.async {
            let progress = self.loadProgressView.progress + step
            self.loadProgressView.progress = progress
        }
        
        
        if let nsData = UserDefaults.standard.value(forKey: "4") as? NSData {
            let data = nsData as Data
            let usersJSON: UsersJSON? = self.getType(from: data)
            if let users = usersJSON?.value {
                addUserDataToCoreData(usersJSON: users, context: context)
                loadUsersFromCoreData(to: &self.users, context: context)
                print("Users: \(self.users.count)")
            }
        }
        
        DispatchQueue.main.async {
            let progress = self.loadProgressView.progress + step
            self.loadProgressView.progress = progress
        }
        
        addDirectionsToCoreData()
        print("Directions: \(self.directions.count)")
        
        if let nsData = UserDefaults.standard.value(forKey: "5") as? NSData {
            let data = nsData as Data
            let epicUserStoriesJSON: EpicUserStoriesJSON? = self.getType(from: data)
            var i = 0
            if let epicUserStoriesJSON = epicUserStoriesJSON?.value {
                print(epicUserStoriesJSON.count)
                for epicUserStoryJSON in epicUserStoriesJSON {
                                        if epicUserStoryJSON.id == "b39bd526-be33-11e7-a051-0050568d26bf" {
                                            print(epicUserStoryJSON.title)
                                        }
                    
                    if let tfsUrl = epicUserStoryJSON.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict["Ссылка на ЭПИ в журнале"]}).first {
                        if tfsUrl.valueId.hasPrefix("http://tfs:8080/tfs/DIT/MAIN-BACKLOG") {
                            continue
                        }
                    } else {
                        if epicUserStoryJSON.eusType == "f357797e-bad3-11e7-acc5-0050568d26bf" {
                            continue
                        }
                    }
                    
                    i += 1
                    addEpicUserStoryToCoreData(epicUserStory: epicUserStoryJSON, context: context)
                }
                print(i)
                self.epicUserStories.removeAll()
                loadEpicUserStoriesFromCoreData(to: &self.epicUserStories, context: context)
                //                for eus in self.epicUserStories {
                //                    print(eus.name)
                //                    print(" id:        \(eus.id)")
                //                    print(" tactic:    \(eus.tactic?.name)")
                //                    print(" category:  \(eus.category?.name)")
                //                    print(" Value:     \(eus.businessValue?.name)")
                //                    print(" direction: \(eus.direction?.name)")
                //                    print(" dept:      \(eus.dept?.name)")
                //                    print(" priority:  \(eus.priority)")
                //                    print(" deathLine: \(eus.deathLine)")
                //                    print(" productOw: \(eus.productOwner?.fio)")
                //                    print(" tfs:       \(eus.tfsUrl)")
                //                    print(" tfsId:     \(eus.tfsId)")
                //                    print(" quart:     \(eus.quart)")
                //                    print(" OA:        \(eus.storePointsAnaliticPlane)")
                //                    print(" Dev:       \(eus.storePointsDevPlane)")
                //                    print("")
                //                }
                print("EUS: \(self.epicUserStories.count)")
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
        for direction in globalSettings.tfsDirectionDict {
            guard let entity =  NSEntityDescription.entity(forEntityName: "TreeWorkItem", in: context) else { return }
            let workItem = NSManagedObject(entity: entity, insertInto: context)
            workItem.setValue(direction.value, forKey: "id")
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
    
    func getTreeWorkItemsJSONFromTFS(level: Int32, queriesTFS: [ODataQuery], i: inout Int, type: queryResultFormat) {
        var urlComponents = self.dataProvider.getUrlComponents(server: queriesTFS[i].server, query: queriesTFS[i], format: type)
        urlComponents.user = "zubkoff"
        urlComponents.password = "!den20zu10"
        guard let url = urlComponents.url else { return }
        //        print(url)
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
                    self.loadTreeWorkItemsFromCoreData(to: &self.treeWorkItems, context: self.context)
                    for treeWorkItem in self.treeWorkItems {
                        print("\(treeWorkItem.level) \(treeWorkItem.parentId) \(treeWorkItem.id)")
                    }
                    print(self.treeWorkItems.count)
                    currentLevel += 1
                    if currentLevel < 3 {
                        self.addTreeWorkItems(level: &currentLevel, context: self.context)
                    }
                }
                DispatchQueue.main.async {
                    let progress: Float =  Float(index) / Float(queriesTFS.count)
                    self.loadProgressView.progress = progress
                }
                
            }
        }
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
    
    func loadTreeWorkItemsFromCoreData(to treeWorkItems: inout [TreeWorkItem], context: NSManagedObjectContext) {
        
        let fetchRequest: NSFetchRequest<TreeWorkItem> = TreeWorkItem.fetchRequest()
        do {
            treeWorkItems = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
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
    
    func loadPropertiesFromCoreData(to properties: inout [Property], context: NSManagedObjectContext) {
       
        let fetchRequest: NSFetchRequest<Property> = Property.fetchRequest()
        do {
            properties = try context.fetch(fetchRequest)
        } catch let error as NSError {
             print(error.localizedDescription)
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
    
    func loadPropertyValuesFromCoreData(to propertyValues: inout [PropertyValue], context: NSManagedObjectContext) {
        
        let fetchRequest: NSFetchRequest<PropertyValue> = PropertyValue.fetchRequest()
        do {
            propertyValues = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
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
        loadStrategicTargetsFromCoreData(to: &self.strategicTargets, context: context)
        for strategicTarget in strategicTargets {
            if !(strategicTarget.isFolder) {
                addTacticsToCoreData(tactic: strategicTarget)
            }
        }
        loadTacticsFromCoreData(to: &self.tactics, context: context)
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

    func loadStrategicTargetsFromCoreData(to strategicTargets: inout [StrategicTarget], context: NSManagedObjectContext) {
        
        let fetchRequest: NSFetchRequest<StrategicTarget> = StrategicTarget.fetchRequest()
        do {
            strategicTargets = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
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
    
    func loadTacticsFromCoreData(to tactics: inout [Tactic], context: NSManagedObjectContext) {
        
        let fetchRequest: NSFetchRequest<Tactic> = Tactic.fetchRequest()
        do {
            tactics = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    //MARK: CATEGORIES
    
    
    func addCategoriesToCoreData() {
        let categories = propertyValues.filter({($0.property?.name ?? "") == "Категория"})
        for category in categories {
            addCategoryToCoreData(category: category)
        }
        loadCategoriesFromCoreData(to: &self.categories, context: context)
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
    
    func loadCategoriesFromCoreData(to categories: inout [Category], context: NSManagedObjectContext) {
        
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        do {
            categories = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    //MARK: DIRECTIONS
    
    func addDirectionsToCoreData() {
        let directions = propertyValues.filter({($0.property?.name ?? "") == "Направление"})
        for direction in directions {
            addDirectionToCoreData(direction: direction)
        }
        loadDirectionsFromCoreData(to: &self.directions, context: context)
    }
    
    func addDirectionToCoreData(direction: PropertyValue) {
        let fetchRequest: NSFetchRequest<Direction> = Direction.fetchRequest()
        guard let directionId = direction.id else { return }
        fetchRequest.predicate = NSPredicate(format: "id == %@", directionId)
        do {
            let results = try context.fetch(fetchRequest)
            if let result = results.first {
                result.name = direction.value
                if let userId = globalSettings.headDirectionDict[directionId],
                    let user = self.users.filter({$0.id == userId}).first {
                        result.headDirection = user
                }
                if let tfsId = globalSettings.tfsDirectionDict[directionId] {
                    result.tfsId = tfsId
                }
                
            } else {
                guard let entity =  NSEntityDescription.entity(forEntityName: "Direction", in: context) else { return }
                let property = NSManagedObject(entity: entity, insertInto: context)
                property.setValue(direction.id, forKey: "id")
                property.setValue(direction.value, forKey: "name")
                if let userId = globalSettings.headDirectionDict[directionId],
                    let user = self.users.filter({$0.id == userId}).first {
                        property.setValue(user, forKey: "headDirection")
                }
                if let tfsId = globalSettings.tfsDirectionDict[directionId] {
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
    
    func loadDirectionsFromCoreData(to directions: inout [Direction], context: NSManagedObjectContext) {
        
        let fetchRequest: NSFetchRequest<Direction> = Direction.fetchRequest()
        do {
            directions = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    
    //MARK: BUSINESS VALUES
    
    func addBusinessValuesToCoreData() {
        let businessValues = propertyValues.filter({($0.property?.name ?? "") == "Ценность"})
        for businessValue in businessValues {
            addBusinessValueToCoreData(businessValue: businessValue)
        }
        loadBusinessValuesFromCoreData(to: &self.businessValues, context: context)
    }
    
    func getBusinessValueInt32(value: String) -> Int32 {
        if value.contains("[08]") { return Int32(8) }
        if value.contains("[16]") { return Int32(16) }
        if value.contains("[32]") { return Int32(32) }
        if value.contains("[64]") { return Int32(64) }
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
    
    func loadBusinessValuesFromCoreData(to businessValues: inout [BusinessValue], context: NSManagedObjectContext) {
        
        let fetchRequest: NSFetchRequest<BusinessValue> = BusinessValue.fetchRequest()
        do {
            businessValues = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
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
    
    func loadDeptsFromCoreData(to depts: inout [Dept], context: NSManagedObjectContext) {
        
        let fetchRequest: NSFetchRequest<Dept> = Dept.fetchRequest()
        do {
            depts = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
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
    
    func loadTypeTeamsFromCoreData(to typeTeams: inout [TypeTeam], context: NSManagedObjectContext) {
        
        let fetchRequest: NSFetchRequest<TypeTeam> = TypeTeam.fetchRequest()
        do {
            typeTeams = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
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
    
    func loadTeamsFromCoreData(to teams: inout [Team], context: NSManagedObjectContext) {
        
        let fetchRequest: NSFetchRequest<Team> = Team.fetchRequest()
        do {
            teams = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
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
    
    func loadUsersFromCoreData(to users: inout [User], context: NSManagedObjectContext) {
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        do {
            users = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
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
                if let directionNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict["Направление"]}).first {
                    if let direction = directions.filter({$0.id == directionNew.valueId}).first {
                       result.direction = direction
                    }
                }
                if let categoryNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict["Категория"]}).first {
                    if let category = categories.filter({$0.id == categoryNew.valueId}).first {
                        result.category = category
                    }
                }
                if let tacticNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict["Тактика"]}).first {
                    if let tactic = tactics.filter({$0.id == tacticNew.valueId}).first {
                        result.tactic = tactic
                    }
                }
                if let valueNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict["Ценность"]}).first {
                    if let valueB = businessValues.filter({$0.id == valueNew.valueId}).first {
                        result.businessValue = valueB
                    }
                }
                if let storePointAnaliticNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict["Оценка трудоемкости ОА"]}).first {
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
                if let storePointDeveloperNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict["Оценка трудоемкости разработки"]}).first {
                    result.storePointsDevPlane = storePointDeveloperNew.valueId
                }
                if let tfsUrl = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict["Гиперссылка на журнал ЭПИ"]}).first {
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
                
                if let quartNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict["Квартал"]}).first {
                    result.quart = quartNew.valueId
                    
                }
                
                if let deathLineNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict["Дедлайн"]}).first {
                    result.deathLine = convertString1cToDate(from: deathLineNew.valueId)
                    
                }
                
                if let priotiryNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict["Приоритет"]}).first {
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
                if let directionNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict["Направление"]}).first {
                    if let direction = directions.filter({$0.id == directionNew.valueId}).first {
                        property.setValue(direction, forKey: "direction")
                    }
                }
                if let categoryNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict["Категория"]}).first {
                    if let category = categories.filter({$0.id == categoryNew.valueId}).first {
                        property.setValue(category, forKey: "category")
                    }
                }
                if let tacticNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict["Тактика"]}).first {
                    if let tactic = tactics.filter({$0.id == tacticNew.valueId}).first {
                        property.setValue(tactic, forKey: "tactic")
                    }
                }
                if let valueNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict["Ценность"]}).first {
                    if let valueB = businessValues.filter({$0.id == valueNew.valueId}).first {
                        property.setValue(valueB, forKey: "businessValue")
                    }
                }
                if let storePointAnaliticNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict["Оценка трудоемкости ОА"]}).first {
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
                
                if let storePointDeveloperNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict["Оценка трудоемкости разработки"]}).first {
                    property.setValue(storePointDeveloperNew.valueId, forKey: "storePointsDevPlane")

                }
                
                if let quartNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict["Квартал"]}).first {
                    property.setValue(quartNew.valueId, forKey: "quart")
                    
                }
                
                if let deathLineNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict["Дедлайн"]}).first {
                    property.setValue(convertString1cToDate(from: deathLineNew.valueId), forKey: "deathLine")
                    
                }
                
                if let priotiryNew = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict["Приоритет"]}).first {
                    if let priority = Int32(priotiryNew.valueId) {
                        property.setValue(priority, forKey: "priority")
                    }
                }
                
                if let tfsUrl = epicUserStory.дополнительныеРеквизиты.filter({$0.parameterId == globalSettings.parameterDict["Гиперссылка на журнал ЭПИ"]}).first {
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

    
    
    
    func loadEpicUserStoriesFromCoreData(to epicUserStories: inout [EpicUserStory], context: NSManagedObjectContext) {
        
        let fetchRequest: NSFetchRequest<EpicUserStory> = EpicUserStory.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "noShow = FALSE")
        do {
            epicUserStories = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func fillDirectionByProductOwner() {
        for eus in epicUserStories {
            if eus.productOwner?.direction == nil {
                eus.productOwner?.directionPO = eus.direction
            }
        }
    }
    
    func addEUSFromTFS() {
        for eus in epicUserStories {
            let tfsId = eus.tfsId
            if tfsId != 0 {
                let query = ODataQuery.init(server: globalSettings.serverTFS,
                                            table: "workitems/\(tfsId)",
                    filter: nil,
                    select: nil,
                    orderBy: nil,
                    id: tfsId)
                
                
                queriesTFS.append(query)
            }
        }
        var index = 0
        DispatchQueue.main.async {
            self.loadStageLabel.text = "Загрузка данных из TFS..."
        }
        getDataJSONFromTFS(queriesTFS: queriesTFS, i: &index, type: .tfs)
        
    }
    
    
    
    
    func addWorkItemToCoreData(workItem: WorkItemJSON) {
        let fetchRequest: NSFetchRequest<EpicUserStory> = EpicUserStory.fetchRequest()
        let tfsId = workItem.id
        fetchRequest.predicate = NSPredicate(format: "tfsId == %i", tfsId)
        do {
            let results = try context.fetch(fetchRequest)
            if let result = results.first {
                result.tfsWorkItemType = workItem.fields.workItemType
                result.tfsState = workItem.fields.state
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
                print(result.tfsId)
                for strUrl in workItem.relations {
                    if strUrl.rel == "System.LinkTypes.Hierarchy-Reverse" {
                        addProductToCoreData(context: context)
                    }
                    if strUrl.rel == "System.LinkTypes.Hierarchy-Forward" {
                        addUserStoryUrlToCoreData(context: context)
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
    
    func addProductToCoreData(context: NSManagedObjectContext) {
        print("addProduct")
    }
    
    func addUserStoryUrlToCoreData(context: NSManagedObjectContext) {
        print("addUserStoryUrl")
    }
}
