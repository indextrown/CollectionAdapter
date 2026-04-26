import UIKit

/// Compositional Layout 기반 경량 어댑터가 사용하는 섹션 모델입니다.
///
/// 섹션마다:
/// - 어떤 아이템을 보여줄지
/// - 어떤 `NSCollectionLayoutSection`을 쓸지
/// 를 함께 묶어둡니다.
struct LightweightCompositionalSection {
    /// 섹션 식별자입니다.
    let id: AnyHashable

    /// 섹션에 포함된 타입 소거 컴포넌트 목록입니다.
    let components: [CompositionalAnyComponent]

    /// Compositional Layout이 이 섹션을 그릴 때 사용할 레이아웃 생성 클로저입니다.
    let layoutProvider: (NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection

    /// 배열 기반으로 섹션을 만드는 기본 생성자입니다.
    ///
    /// - Parameters:
    ///   - id: 섹션 식별자
    ///   - components: 섹션 아이템 목록
    ///   - layoutProvider: 섹션 레이아웃 생성 클로저
    init(
        id: AnyHashable,
        components: [CompositionalAnyComponent],
        layoutProvider: @escaping (NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection
    ) {
        self.id = id
        self.components = components
        self.layoutProvider = layoutProvider
    }

    /// builder 문법으로 섹션 아이템을 더 간결하게 선언할 수 있는 생성자입니다.
    ///
    /// - Parameters:
    ///   - id: 섹션 식별자
    ///   - layoutProvider: 섹션 레이아웃 생성 클로저
    ///   - content: 섹션 아이템 builder
    init(
        id: AnyHashable,
        layoutProvider: @escaping (NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection,
        @CompositionalComponentBuilder content: () -> [CompositionalAnyComponent]
    ) {
        self.id = id
        self.components = content()
        self.layoutProvider = layoutProvider
    }
}
