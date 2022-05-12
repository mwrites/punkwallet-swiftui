//
//  Network.swift
//  punkwallet
//
//  Created by mwrites on 2022/4/29.
//

import Foundation


public struct Network: Codable, Hashable {
    let chainId: Int
    let name: String
    let url: String
    
    func urlWithKey(_ key: String) -> String {
        return url + key
    }
}
