//
//  UserGroupsJSON.swift
//  EpicUS
//
//  Created by Denis Zubkov on 04/04/2019.
//  Copyright © 2019 TBM. All rights reserved.
//

import Foundation

struct UserGroupsJSON: Codable {
    let odataMetadata: String
    let value: [Value]
    
    enum CodingKeys: String, CodingKey {
        case odataMetadata = "odata.metadata"
        case value
    }
    
    struct Value: Codable {
        let id, description, dataVersion: String
        let content: [Состав]
        
        enum CodingKeys: String, CodingKey {
            case id = "Ref_Key"
            case description = "Description"
            case dataVersion = "DataVersion"
            case content = "Состав"
        }
    }
    
    struct Состав: Codable {
        let groupId, lineNumber, userId: String
        
        enum CodingKeys: String, CodingKey {
            case groupId = "Ref_Key"
            case lineNumber = "LineNumber"
            case userId = "Пользователь_Key"
        }
    }
}


