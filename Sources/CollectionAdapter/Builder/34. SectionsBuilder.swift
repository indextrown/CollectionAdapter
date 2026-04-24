//
//  File.swift
//  CollectionAdapter
//
//  Created by 김동현 on 4/23/26.
//

/// 여러 Section을 선언형 DSL로 작성해서 [Section] 배열로 만들어주는 resultBuilder
///
/// 예:
/// ```swift
/// SectionsBuilder {
///   Section(...)
///   Section(...)
/// }
/// → [Section]
/// ```
@resultBuilder
public enum SectionsBuilder {

  /// Section을 직접 나열했을 때 처리
  public static func buildBlock(_ components: Section...) -> [Section] {
    components
  }

  /// [Section], [Section] → 하나로 합침
  public static func buildBlock(_ components: [Section]...) -> [Section] {
    components.flatMap { $0 }
  }

  /// 이미 [Section]이면 그대로 반환
  public static func buildBlock(_ components: [Section]) -> [Section] {
    components
  }

  /// if 문에서 nil이면 빈 배열 반환
  public static func buildOptional(_ component: [Section]?) -> [Section] {
    component ?? []
  }

  /// if-else true branch
  public static func buildEither(first component: [Section]) -> [Section] {
    component
  }

  /// if-else false branch
  public static func buildEither(second component: [Section]) -> [Section] {
    component
  }

  /// Section 여러 개 표현식 처리
  public static func buildExpression(_ expression: Section...) -> [Section] {
    expression
  }

  /// [Section] 여러 개 → 하나로 합침
  public static func buildExpression(_ expression: [Section]...) -> [Section] {
    expression.flatMap { $0 }
  }

  /// for문에서 생성된 [[Section]] → [Section]
  public static func buildArray(_ components: [[Section]]) -> [Section] {
    components.flatMap { $0 }
  }
}

