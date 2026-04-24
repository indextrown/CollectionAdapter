//
//  SupplementaryView.swift
//  CollectionAdapter
//
//  Created by 김동현 on 4/23/26.
//

import UIKit

/// UICollectionView의 보조 뷰(Supplementary View)를 표현하는 구조체
///
/// 이 프레임워크는 일반적으로 사용하는 header / footer를 지원합니다.
/// header 또는 footer를 표현하려면 Section에 withHeader, withFooter를 사용하면 됩니다.
///
/// 예:
/// ```swift
/// Section(id: UUID()) {
///   ...
/// }
/// .withHeader(MyComponent())
/// .withFooter(MyComponent())
/// ```
public struct SupplementaryView: Equatable, ListingViewEventHandler {
    
    /// 보조 뷰를 구성하는 타입 소거된 Component
    public let component: AnyComponent
    
    /// 보조 뷰의 종류(header, footer 등)
    public let kind: String
    
    /// 보조 뷰의 정렬 위치
    public let alignment: NSRectAlignment
    
    /// 이벤트 저장소
    let eventStorage = ListingViewEventStorage()
    
    /// SupplementaryView 생성자
    ///
    /// - Parameters:
    ///  - kind: 보조 뷰 종류 (header / footer)
    ///  - component: 보조 뷰를 구성하는 Component (타입 소거됨)
    ///  - alignment: 정렬 위치
    init(kind: String, component: some Component, alignment: NSRectAlignment) {
        self.kind = kind
        self.component = AnyComponent(component)
        self.alignment = alignment
    }
    
    /// 두 SupplementaryView 비교
    public static func == (lhs: SupplementaryView, rhs: SupplementaryView) -> Bool {
      lhs.component == rhs.component &&
      lhs.kind == rhs.kind &&
      lhs.alignment == rhs.alignment
    }
}

// MARK: - Event Handler
extension SupplementaryView {

  /// 화면에 표시될 때 호출되는 콜백 등록
  ///
  /// - Parameters:
  ///  - handler: 표시 이벤트 콜백
  public func willDisplay(_ handler: @escaping (WillDisplayEvent.EventContext) -> Void) -> Self {
    registerEvent(WillDisplayEvent(handler: handler))
  }

  /// 화면에서 제거될 때 호출되는 콜백 등록
  ///
  /// - Parameters:
  ///  - handler: 제거 이벤트 콜백
  public func didEndDisplaying(_ handler: @escaping (DidEndDisplayingEvent.EventContext) -> Void) -> Self {
    registerEvent(DidEndDisplayingEvent(handler: handler))
  }
}
