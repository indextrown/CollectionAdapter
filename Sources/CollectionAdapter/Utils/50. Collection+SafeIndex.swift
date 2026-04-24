//
//  Collection+SafeIndex.swift
//  CollectionAdapter
//
//  Created by 김동현 on 4/24/26.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
