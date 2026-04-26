import UIKit

/// Compositional 예제 전용 Result Builder입니다.
///
/// 호출부에서는 각 컴포넌트를 그대로 나열하고,
/// 내부적으로만 `CompositionalAnyComponent` 타입 소거를 수행합니다.
@resultBuilder
enum CompositionalComponentBuilder {
    /// 단일 Compositional 컴포넌트를 타입 소거 배열로 변환합니다.
    static func buildExpression(_ expression: some CompositionalComponent) -> [CompositionalAnyComponent] {
        [CompositionalAnyComponent(expression)]
    }

    /// 이미 타입 소거된 컴포넌트도 그대로 사용할 수 있게 허용합니다.
    static func buildExpression(_ expression: CompositionalAnyComponent) -> [CompositionalAnyComponent] {
        [expression]
    }

    /// builder 블록의 여러 줄 결과를 하나의 배열로 합칩니다.
    static func buildBlock(_ components: [CompositionalAnyComponent]...) -> [CompositionalAnyComponent] {
        components.flatMap { $0 }
    }

    /// `if` 분기 한쪽 결과를 그대로 전달합니다.
    static func buildOptional(_ component: [CompositionalAnyComponent]?) -> [CompositionalAnyComponent] {
        component ?? []
    }

    /// `if/else`의 첫 번째 분기 결과를 전달합니다.
    static func buildEither(first component: [CompositionalAnyComponent]) -> [CompositionalAnyComponent] {
        component
    }

    /// `if/else`의 두 번째 분기 결과를 전달합니다.
    static func buildEither(second component: [CompositionalAnyComponent]) -> [CompositionalAnyComponent] {
        component
    }

    /// `for` 루프 결과를 하나의 배열로 합칩니다.
    static func buildArray(_ components: [[CompositionalAnyComponent]]) -> [CompositionalAnyComponent] {
        components.flatMap { $0 }
    }
}
