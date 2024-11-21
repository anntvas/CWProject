//
//  RandomFilter.swift
//  CWProject
//
//  Created by Anna on 21.11.2024.
//

import Foundation
class RandomFilter {
    static let array: [FilterType] = [FilterType.Chrome, FilterType.Fade, FilterType.Instant, FilterType.Mono, FilterType.Noir, FilterType.Process, FilterType.Tonal, FilterType.Transfer]
    
    static func random() -> FilterType {
        let randomInt = Int.random(in: 0...7)
        return array[randomInt]
    }
}
