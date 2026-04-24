//
//  File.swift
//  CollectionAdapter
//
//  Created by 김동현 on 4/23/26.
//

import Foundation

/// 이벤트를 저장하는 저장소
final class ListingViewEventStorage {
    
    /// 이벤트 저장용 딕셔너리(id기반)
    private var source: [AnyHashable: Any] = [:]
    
    /// 특정 타입의 이벤트 조회
    func event<E: ListingViewEvent>(for type: E.Type) -> E? {
        source[String(reflecting: type)] as? E
    }
    
    /// 이벤트 등록
    func register(_ event: some ListingViewEvent) {
        source[event.id] = event
    }
}
