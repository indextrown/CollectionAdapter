import UIKit

/// 여러 종류의 경량 컴포넌트를 `LightweightAnyComponent` 배열로 자동 변환하는 Result Builder입니다.
///
/// 호출부에서는 각 컴포넌트를 그대로 나열할 수 있고,
/// 내부적으로만 `LightweightAnyComponent` 타입 소거를 수행합니다.
@resultBuilder
enum LightweightComponentBuilder {
    /// 단일 경량 컴포넌트를 타입 소거 컴포넌트 배열로 변환합니다.
    ///
    /// - Parameter expression: 원본 경량 컴포넌트
    /// - Returns: 타입 소거된 컴포넌트 하나를 담은 배열
    static func buildExpression(_ expression: some LightweightComponent) -> [LightweightAnyComponent] {
        [LightweightAnyComponent(expression)]
    }

    /// 이미 타입 소거된 컴포넌트도 그대로 사용할 수 있게 허용합니다.
    ///
    /// - Parameter expression: 이미 감싸진 컴포넌트
    /// - Returns: 입력 배열 그대로
    static func buildExpression(_ expression: LightweightAnyComponent) -> [LightweightAnyComponent] {
        [expression]
    }

    /// builder 블록의 여러 줄 결과를 하나의 배열로 합칩니다.
    ///
    /// - Parameter components: 각 줄에서 만들어진 타입 소거 배열
    /// - Returns: 최종 컴포넌트 목록
    static func buildBlock(_ components: [LightweightAnyComponent]...) -> [LightweightAnyComponent] {
        components.flatMap { $0 }
    }

    /// `if` 분기 한쪽 결과를 그대로 전달합니다.
    ///
    /// - Parameter component: 분기 결과
    /// - Returns: 최종 컴포넌트 목록
    static func buildOptional(_ component: [LightweightAnyComponent]?) -> [LightweightAnyComponent] {
        component ?? []
    }

    /// `if/else`의 첫 번째 분기 결과를 전달합니다.
    static func buildEither(first component: [LightweightAnyComponent]) -> [LightweightAnyComponent] {
        component
    }

    /// `if/else`의 두 번째 분기 결과를 전달합니다.
    static func buildEither(second component: [LightweightAnyComponent]) -> [LightweightAnyComponent] {
        component
    }

    /// `for` 루프 결과를 하나의 배열로 합칩니다.
    static func buildArray(_ components: [[LightweightAnyComponent]]) -> [LightweightAnyComponent] {
        components.flatMap { $0 }
    }
}
