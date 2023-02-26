//
//  Model.swift
//  SweetsSearchApp
//
//  Created by K Barnes on 2023/01/08.
//

import Foundation

struct Okashi: Codable {
    
    let item: [Item]
    
    enum CodingKeys: String, CodingKey {
        
        case item = "item"
        
    }
    
}

struct Item: Codable {
    
    let name: String
    
    let image: String
    
    let url: String
    
    let id: String
    
    let maker: String
    
    enum CodingKeys: String, CodingKey {
        
        case name = "name"
        
        case image = "image"
        
        case url = "url"
        
        case id = "id"
        
        case maker = "maker"
        
    }
    
}


struct Count: Codable {
    
    let count: String
    
    enum CodingKeys: String, CodingKey {
        
        case count = "count"
        
    }
    
}

struct OneItem: Codable {
   
   
  let item: Item

  enum CodingKeys: String, CodingKey {
     
    case item = "item"
     
  }
}
