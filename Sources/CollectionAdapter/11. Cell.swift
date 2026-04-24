//
//  File.swift
//  CollectionAdapter
//
//  Created by 김동현 on 4/23/26.
//

import DifferenceKit
import UIKit

/// UICollectionViewCell을 표현하는 Cell 구조체
public struct Cell: Identifiable, ListingViewEventHandler {
    
    /// Cell을 식별하기 위한 ID
    public let id: AnyHashable
    
    /// 셀을 구성하는 타입 소거된 Component
    public let component: AnyComponent
    
    /// 이벤트 저장소
    let eventStorage = ListingViewEventStorage()
    
    /// Cell을 생성하는 초기화 메서드
    ///
    /// - Parameters:
    ///  - id: Cell을 식별하기 위한 ID
    /// - component: 셀을 구성하는 Component (내부에서 AnyComponent로 타입 소거되어 저장됨)
    init(id: some Hashable, component: some Component) {
        self.id = id
        self.component = AnyComponent(component)
    }
    
    /// Cell을 생성하는 초기화 메서드 (IdentifiableComponent 사용)
    ///
    /// - Parameters:
    ///  - component: id를 포함한 Component
    public init(component: some IdentifiableComponent) {
        self.id = component.id
        self.component = AnyComponent(component)
    }
}

// MARK: - Hashable
extension Cell: Hashable {
    
    /// Cell의 해시 값을 생성 (id 기준)
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    /// 두 Cell이 동일한지 비교
    public static func == (lhs: Cell, rhs: Cell) -> Bool {
      lhs.id == rhs.id && lhs.component == rhs.component
    }
}

// MARK: - Differentiable
extension Cell: Differentiable {
    /// diff 비교를 위한 식별자
    public var differenceIdentifier: AnyHashable {
        id
    }
    
    /// 내용이 같은지 비교(reload 여부 판단)
    public func isContentEqual(to source: Cell) -> Bool {
        self == source
    }
}

// MARK: - Event Handler
extension Cell {

  /// 셀이 선택되었을 때 호출되는 콜백을 등록합니다.
  ///
  /// - Parameters:
  ///  - handler: 선택 이벤트 콜백
  public func didSelect(_ handler: @escaping (DidSelectEvent.EventContext) -> Void) -> Self {
    registerEvent(DidSelectEvent(handler: handler))
  }

  /// 셀이 화면에 표시되기 직전에 호출되는 콜백을 등록합니다.
  ///
  /// - Parameters:
  ///  - handler: willDisplay 이벤트 콜백
  public func willDisplay(_ handler: @escaping (WillDisplayEvent.EventContext) -> Void) -> Self {
    registerEvent(WillDisplayEvent(handler: handler))
  }

  /// 셀이 화면에서 제거(사라짐)되었을 때 호출되는 콜백을 등록합니다.
  ///
  /// - Parameters:
  ///  - handler: didEndDisplay 이벤트 콜백
  public func didEndDisplay(_ handler: @escaping (DidEndDisplayingEvent.EventContext) -> Void) -> Self {
    registerEvent(DidEndDisplayingEvent(handler: handler))
  }

  /// 셀이 하이라이트(눌림 상태) 되었을 때 호출되는 콜백을 등록합니다.
  ///
  /// - Parameters:
  ///  - handler: highlight 이벤트 콜백
  public func onHighlight(_ handler: @escaping (HighlightEvent.EventContext) -> Void) -> Self {
    registerEvent(HighlightEvent(handler: handler))
  }

  /// 셀이 하이라이트 해제되었을 때 호출되는 콜백을 등록합니다.
  ///
  /// - Parameters:
  ///  - handler: unhighlight 이벤트 콜백
  public func onUnhighlight(_ handler: @escaping (UnhighlightEvent.EventContext) -> Void) -> Self {
    registerEvent(UnhighlightEvent(handler: handler))
  }
}
