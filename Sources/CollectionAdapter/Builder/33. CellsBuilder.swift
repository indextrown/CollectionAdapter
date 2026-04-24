//
//  File.swift
//  CollectionAdapter
//
//  Created by 김동현 on 4/23/26.
//

import Foundation

/// 여러 Cell을 선언형 DSL로 작성해서 [Cell] 배열로 만들어주는 resultBuilder
///
/// 예:
/// ```swift
/// CellsBuilder {
///   Cell(...)
///   Cell(...)
/// }
/// → [Cell]
/// ```
@resultBuilder
public enum CellsBuilder {
    
    /// 여러 Cell을 직접 나열했을 때 처리
    /// Cell, Cell → [Cell]
    public static func buildBlock(_ components: Cell...) -> [Cell] {
        components
    }
    
    /// [Cell], [Cell] 형태를 하나로 합침
    /// → [[Cell]] → [Cell]
    public static func buildBlock(_ components: [Cell]...) -> [Cell] {
        components.flatMap { $0 }
    }
    
    /// 이미 [Cell]인 경우 그대로 반환
    public static func buildBlock(_ components: [Cell]) -> [Cell] {
        components
    }
    
    /// if 문에서 값이 nil이면 빈 배열 반환
    public static func buildOptional(_ component: [Cell]?) -> [Cell] {
        component ?? []
    }
    
    /// if-else (true branch)
    public static func buildEither(first component: [Cell]) -> [Cell] {
        component
    }
    
    /// if-else (true branch, Cell... 형태 지원)
    public static func buildEither(first component: Cell...) -> [Cell] {
        component
    }
    
    /// if-else (closure 형태 지원)
    public static func buildEither(second component: () -> [Cell]) -> [Cell] {
        component()
    }
    
    /// if-else (false branch)
    public static func buildEither(second component: [Cell]) -> [Cell] {
        component
    }
    
    /// Cell 여러 개를 표현식으로 처리
    /// Cell, Cell → [Cell]
    public static func buildExpression(_ expression: Cell...) -> [Cell] {
      expression
    }

    /// [Cell] 여러 개를 표현식으로 처리
    /// → [[Cell]] → [Cell]
    public static func buildExpression(_ expression: [Cell]...) -> [Cell] {
      expression.flatMap { $0 }
    }

    /// for문에서 생성된 [[Cell]]을 [Cell]로 평탄화
    public static func buildArray(_ components: [[Cell]]) -> [Cell] {
      components.flatMap { $0 }
    }
}
