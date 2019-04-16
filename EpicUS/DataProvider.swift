//
//  DataProvider.swift
//  EpicUS
//
//  Created by Denis Zubkov on 29/03/2019.
//  Copyright © 2019 TBM. All rights reserved.
//

import Foundation

class DataProvider {
    
    var dataCache = NSCache<NSString, NSData>()
    var globalSettings = GlobalSettings()
    
    func getUrlComponents(server: ODataServer, query: ODataQuery, format: queryResultFormat) -> URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = server.scheme
        urlComponents.host = server.host
        if let port = server.port {
            urlComponents.port = port
        }
        urlComponents.path = server.server + server.oData + query.table
        var queryItems: [URLQueryItem] = []
        if let filter = query.filter {
            let filterItem = URLQueryItem(name: "$filter", value: filter)
            queryItems.append(filterItem)
        }
        
        if let select = query.select {
            let selectItem = URLQueryItem(name: "$select", value: select)
            queryItems.append(selectItem)
        }
        
        if let orderBy = query.orderBy {
            let orderItem = URLQueryItem(name: "$orderby", value: orderBy)
            queryItems.append(orderItem)
        }
        
        switch format {
        case .json:
            let formatItem = URLQueryItem(name: "$format", value: format.rawValue)
            queryItems.append(formatItem)
        case .tfs:
            let expandItem = URLQueryItem(name: "$expand", value: "relations")
            queryItems.append(expandItem)
            let formatItem = URLQueryItem(name: "api-version", value: format.rawValue)
            queryItems.append(formatItem)
        default:
            break
        }
        urlComponents.queryItems = queryItems
//        urlComponents.password = "!den20zu10"
//        urlComponents.user = "zubkoff"
        return urlComponents
    }
    
    func downloadData(url: URL, completion: @escaping (Data?) -> Void) {
        if let cachedData = dataCache.object(forKey: url.absoluteString as NSString),
            let data = cachedData as Data? {
            completion(data)
        } else {
           let request = getRequest(url: url, login: globalSettings.login, password: globalSettings.password)
           let dataTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                if error != nil {
                    DispatchQueue.main.async {
                        completion(error?.localizedDescription.data(using: .utf8))
                    }
                }
                guard let data = data else { return }
                guard let response = response as? HTTPURLResponse else { return }
                if response.statusCode != 200 {
                    let statusCodeString = String(response.statusCode)
                    completion(statusCodeString.data(using: .utf8))
                    return
                }
                guard let `self` = self else { return }
                self.dataCache.setObject(data as NSData, forKey: url.absoluteString as NSString)
                DispatchQueue.main.async {
                    completion(data)
                }
            }
            
            dataTask.resume()
        }
    }
    
    func downloadDataFromTFS(url: URL, completion: @escaping (Data?) -> Void) {
        if let cachedData = dataCache.object(forKey: url.absoluteString as NSString),
            let data = cachedData as Data? {
            completion(data)
        } else {
            let request = URLRequest(url: url)
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            let task = session.dataTask(with: request)  { data, response, error in
                if error != nil {
                    DispatchQueue.main.async {
                        completion(error?.localizedDescription.data(using: .utf8))
                    }
                }
                guard let data = data else { return }
                guard let response = response as? HTTPURLResponse else { return }
                if response.statusCode != 200 {
                    let statusCodeString = String(response.statusCode)
                    completion(statusCodeString.data(using: .utf8))
                    return
                }
                //guard let `self` = self else { return }
                self.dataCache.setObject(data as NSData, forKey: url.absoluteString as NSString)
                DispatchQueue.main.async {
                    completion(data)
                }
            }
            task.resume()
        }
    }
    
    func getRequest(url: URL, login: String, password: String) -> URLRequest {
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 100)
        let loginString = NSString(format: "%@:%@", login, password)
        let loginData: NSData = loginString.data(using: String.Encoding.utf8.rawValue)! as NSData
        let base64LoginString = loginData.base64EncodedString(options: NSData.Base64EncodingOptions())
        let parameters = ["Authorization": "Basic \(base64LoginString)",
            "Accept-Encoding": "gzip, deflate", "Accept": "*/*", "Accept-Language": "ru"]
        request.httpMethod = "GET"
        request.timeoutInterval = 100
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        for parameter in parameters {
            request.addValue(parameter.value, forHTTPHeaderField: parameter.key)
        }
        return request
    }

}

	

