//
//  Bundle-Decodable.swift
//  BucketList
//
//  Created by Jules Lee on 1/14/20.
//  Copyright © 2020 Jules Lee. All rights reserved.
//

import SwiftUI

extension FileManager {
    func decode<T: Codable>(_ file: String) -> T {
        guard let url = try? FileManager.default.url(for: .documentDirectory, in: .localDomainMask, appropriateFor: URL(fileURLWithPath: file), create: true) else {
            fatalError("Failed to locate \(file) in bundle.")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to return \(file) from bundle.")
        }
        
        let decoder = JSONDecoder()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "y-MM-dd"
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        guard let loaded = try? decoder.decode(T.self, from: data) else {
            fatalError("Failed to decode \(file) from bundle")
        }
        
        return loaded
    }
}
