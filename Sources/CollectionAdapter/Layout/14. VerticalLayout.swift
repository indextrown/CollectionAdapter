//
//  VerticalLayout.swift
//  CollectionAdapter
//
//  Created by 김동현 on 4/23/26.
//

import UIKit

/// 세로 스크롤(vertical scrolling)을 지원하는 레이아웃.
///
/// Cell의 width는 CollectionView의 전체 width를 그대로 사용하고,
/// height는 content 크기에 맞게 자동으로 조정되는 경우에 적합하다.
/// 즉, 우리가 흔히 사용하는 "세로 리스트 UI"에 해당한다.
///
/// - Note:
/// 이 레이아웃을 사용할 때는 component의 layoutMode가
/// 반드시 flexibleHeight여야 정상 동작한다.
@MainActor
public struct VerticalLayout: @MainActor CompositionalLayoutSectionFactory {
    
    /// Cell 사이 간격
    private let spacing: CGFloat
    
    /// Section Padding
    private var sectionInsets: NSDirectionalEdgeInsets?

    /// Header sticky 여부
    private var headerPinToVisibleBounds: Bool?
    
    /// Footer sticky 여부
    private var footerPinToVisibleBounds: Bool?
    
    /// 스크롤 시 visible item 변화 감지 헨들러
    private var visibleItemsInvalidationHandler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler?
    
    /// 초기화
    ///
    /// - Parameter spacing: Cell 간 간격 (기본값 0)
    public init(spacing: CGFloat = 0.0) {
        self.spacing = spacing
    }
    
    /// Section 레이아웃 생성 (핵심)
    public func makeSectionLayout() -> SectionLayout? {
        // MARK: - 나중에 context를 받아서 section 레이아웃을 만들어주는 클로저를 반환하는 함수
        /**
         `makeSectionLayout()`은 `NSCollectionLayoutSection`을 바로 만드는 함수가 아니라,
         "나중에 `context`를 전달받으면 section layout을 만들어주는 클로저"를 반환하는 함수이다.

         즉, 아래 코드:

         `public func makeSectionLayout() -> SectionLayout? {
             { context -> NSCollectionLayoutSection? in
                 ...
             }
         }`

         는 이런 구조와 같다:

         `func makeSomething() -> (Int) -> String {
             return { number in
                 return "값은 \(number)"
             }
         }`

         `makeSomething()`을 호출하면 바로 문자열이 반환되는 것이 아니라,
         `Int`를 전달받으면 `String`을 만들어주는 "함수 자체"가 반환된다.

         예를 들어:

         `let f = makeSomething()`  // 문자열이 아니라 함수가 반환됨
         `let result = f(10)`       // 이 시점에 클로저가 실제 실행됨
         `print(result)`            // "값은 10"

         마찬가지로 `makeSectionLayout()`도 호출 즉시 layout을 만드는 것이 아니라,
         `context`를 받아 실제 `NSCollectionLayoutSection`을 생성하는 클로저를 반환한다.

         이렇게 사용하는 이유는,
         레이아웃의 공통 설정값과 실제 생성 시점에 필요한 값을 분리하기 위해서이다.

         예를 들어 `VerticalLayout`은 미리 다음과 같은 공통 설정을 가지고 있을 수 있다:
         - spacing
         - sectionInsets
         - header / footer pin 여부

         반면 실제 section layout을 만들 때는 그 순간의 정보가 추가로 필요하다:
         - 현재 section 데이터
         - 현재 section index
         - 현재 collectionView의 container 크기
         - sizeStorage
         - layout environment

         즉,
         - 미리 정할 수 있는 레이아웃 규칙은 `VerticalLayout`이 가지고 있고
         - 실행 시점에 알아야 하는 정보는 `context`로 나중에 전달받는다

         이 구조를 사용하면 레이아웃 객체는 "설계도" 역할을 하고,
         실제 section 생성은 각 section의 현재 상황에 맞게 유연하게 처리할 수 있다.

         또한 `VerticalLayout`, `HorizontalLayout`, `GridLayout`처럼
         서로 다른 레이아웃들도 모두 같은 방식으로
         "context를 받아 NSCollectionLayoutSection을 반환하는 함수" 형태로 통일할 수 있어
         프레임워크 확장성과 일관성에도 유리하다.

         정리하면:

         - `{ context -> NSCollectionLayoutSection? in ... }` 는 클로저(익명 함수)이다.
         - `makeSectionLayout()`은 이 클로저를 반환한다.
         - 실제 실행은 나중에 `builder(context)`처럼 호출되는 시점에 일어난다.
         - 따라서 `context`는 `makeSectionLayout()` 내부에서 갑자기 생기는 값이 아니라,
           이 클로저를 호출하는 외부에서 전달해주는 매개변수이다.
         - 이런 구조는 "공통 레이아웃 설정"과 "실행 시점 정보"를 분리하기 위해 사용된다.
         */
        { context -> NSCollectionLayoutSection? in
            /// 새로 그룹(리스트 형태)
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1.0), /// width는 전체 채움
                    heightDimension: .estimated(           /// height는 content 기반 (estimated)
                        context.enviroment.container.contentSize.height
                    )
                ),
                /// 각 cell들을 그대로 세로로 쌓음
                subitems: layoutCellItems(
                    cells: context.section.cells,
                    sizeStorage: context.sizeStorage
                )
            )
            
            /// cell 간 간격
            group.interItemSpacing = .fixed(spacing)
            
            /// section 생성
            let section = NSCollectionLayoutSection(group: group)
            
            /// inset 적용
            if let sectionInsets {
                section.contentInsets = sectionInsets
            }
            
            // visible item 변화 감지
            if let visibleItemsInvalidationHandler {
                section.visibleItemsInvalidationHandler = visibleItemsInvalidationHandler
            }
            
            /// header 생성
            let headerItem = layoutHeaderItem(
                section: context.section,
                sizeStorage: context.sizeStorage
            )
            
            /// header sticky
            if let headerPinToVisibleBounds {
                headerItem?.pinToVisibleBounds = headerPinToVisibleBounds
            }
            
            /// footer 생성
            let footerItem = layoutFooterItem(
                section: context.section,
                sizeStorage: context.sizeStorage
            )
            
            /// footer sticky
            if let footerPinToVisibleBounds {
                footerItem?.pinToVisibleBounds = footerPinToVisibleBounds
            }
            
            /// header + footer 등록
            section.boundarySupplementaryItems = [
                headerItem,
                footerItem
            ].compactMap { $0 }
            
            return section
        }
    }
    
    /// section inset 설정
    public func insets(_ insets: NSDirectionalEdgeInsets?) -> Self {
        var copy = self
        copy.sectionInsets = insets
        return copy
    }
    
    /// header sticky 설정
    public func headerPinToVisibleBounds(_ pinToVisibleBounds: Bool?) -> Self {
        var copy = self
        copy.headerPinToVisibleBounds = pinToVisibleBounds
        return copy
    }
    
    /// footer sticky 설정
    public func footerPinToVisibleBounds(_ pinToVisibleBounds: Bool?) -> Self {
        var copy = self
        copy.footerPinToVisibleBounds = pinToVisibleBounds
        return copy
    }
    
    /// visible item 변화 감지 핸들러 설정
    public func withVisibleItemsInvalidationHandler(
        _ handler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler?
    ) -> Self {
        var copy = self
        copy.visibleItemsInvalidationHandler = handler
        return copy
    }
}

