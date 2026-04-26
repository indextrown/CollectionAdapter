import UIKit

/// `MiniList` 안에서 아이템 하나를 표현하는 최소 단위입니다.
struct MiniListCell {
    /// 셀 식별자입니다.
    let id: AnyHashable

    /// 타입 소거된 렌더링 컴포넌트입니다.
    let component: MiniListAnyComponent

    /// 원본 컴포넌트로 셀을 생성합니다.
    ///
    /// - Parameter component: 셀을 렌더링할 원본 컴포넌트
    init(_ component: some MiniListComponent) {
        self.id = component.id
        self.component = MiniListAnyComponent(component)
    }
}

/// 여러 `MiniListCell`을 한 섹션으로 묶는 타입입니다.
struct MiniListSection {
    /// 섹션 식별자입니다.
    let id: AnyHashable

    /// 섹션에 포함된 셀 목록입니다.
    let cells: [MiniListCell]

    /// 섹션별 Compositional Layout 생성 클로저입니다.
    let layoutProvider: (NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection

    /// 배열 기반 섹션 생성자입니다.
    ///
    /// - Parameters:
    ///   - id: 섹션 식별자
    ///   - cells: 섹션 셀 목록
    ///   - layoutProvider: 섹션 레이아웃 생성 클로저
    init(
        id: AnyHashable,
        cells: [MiniListCell],
        layoutProvider: @escaping (NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection
    ) {
        self.id = id
        self.cells = cells
        self.layoutProvider = layoutProvider
    }

    /// builder 문법으로 섹션 셀을 선언할 수 있는 생성자입니다.
    ///
    /// - Parameters:
    ///   - id: 섹션 식별자
    ///   - layoutProvider: 섹션 레이아웃 생성 클로저
    ///   - content: 섹션 셀 builder
    init(
        id: AnyHashable,
        layoutProvider: @escaping (NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection,
        @MiniListCellBuilder content: () -> [MiniListCell]
    ) {
        self.id = id
        self.cells = content()
        self.layoutProvider = layoutProvider
    }
}

/// 화면 전체 스냅샷을 표현하는 루트 타입입니다.
///
/// 이 타입이 생기면 어댑터 입력이 항상 `MiniList` 하나로 고정되기 때문에,
/// 추후 diff, 이벤트, 전역 옵션 같은 기능을 붙일 자리가 자연스럽게 생깁니다.
struct MiniList {
    /// 화면을 구성하는 전체 섹션 목록입니다.
    let sections: [MiniListSection]

    /// 배열 기반 루트 생성자입니다.
    ///
    /// - Parameter sections: 화면 섹션 목록
    init(sections: [MiniListSection]) {
        self.sections = sections
    }

    /// builder 문법으로 루트 섹션을 선언할 수 있는 생성자입니다.
    ///
    /// - Parameter content: 루트 섹션 builder
    init(@MiniListSectionBuilder content: () -> [MiniListSection]) {
        self.sections = content()
    }
}

/// 여러 컴포넌트를 `MiniListCell` 배열로 변환하는 builder입니다.
@resultBuilder
enum MiniListCellBuilder {
    static func buildExpression(_ expression: some MiniListComponent) -> [MiniListCell] {
        [MiniListCell(expression)]
    }

    static func buildExpression(_ expression: MiniListCell) -> [MiniListCell] {
        [expression]
    }

    static func buildBlock(_ components: [MiniListCell]...) -> [MiniListCell] {
        components.flatMap { $0 }
    }

    static func buildOptional(_ component: [MiniListCell]?) -> [MiniListCell] {
        component ?? []
    }

    static func buildEither(first component: [MiniListCell]) -> [MiniListCell] {
        component
    }

    static func buildEither(second component: [MiniListCell]) -> [MiniListCell] {
        component
    }

    static func buildArray(_ components: [[MiniListCell]]) -> [MiniListCell] {
        components.flatMap { $0 }
    }
}

/// 여러 섹션을 `MiniListSection` 배열로 변환하는 builder입니다.
@resultBuilder
enum MiniListSectionBuilder {
    static func buildExpression(_ expression: MiniListSection) -> [MiniListSection] {
        [expression]
    }

    static func buildBlock(_ components: [MiniListSection]...) -> [MiniListSection] {
        components.flatMap { $0 }
    }

    static func buildOptional(_ component: [MiniListSection]?) -> [MiniListSection] {
        component ?? []
    }

    static func buildEither(first component: [MiniListSection]) -> [MiniListSection] {
        component
    }

    static func buildEither(second component: [MiniListSection]) -> [MiniListSection] {
        component
    }

    static func buildArray(_ components: [[MiniListSection]]) -> [MiniListSection] {
        components.flatMap { $0 }
    }
}
