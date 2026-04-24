//
//  AnyComponent.swift
//  CollectionAdapter
//
//  Created by 김동현 on 4/22/26.
//

import UIKit

/// `Equatable`을 따르는 모든 `Component`의 `ViewModel`을 감싸는 타입 소거(type-erased) 래퍼입니다.
public struct AnyViewModel: Equatable {
    
    /// 진짜 ViewModel을 꺼내서 base에 저장합니다.
    private let base: any Equatable
    
    /// 주어진 `Component`의 ViewModel을 감싸서 새로운 `AnyViewModel` 인스턴스를 생성합니다.
    ///
    /// - Parameter base: 감쌀 Component
    init(_ base: some Component) {
        self.base = base.viewModel
    }
    
    /// 두 `AnyViewModel`이 같은지 비교합니다.
    ///
    /// - Returns: 같으면 true, 아니면 false
    public static func == (lhs: AnyViewModel, rhs: AnyViewModel) -> Bool {
        lhs.base.isEqual(rhs.base)
    }
}

/// 내부에서 실제 `Component`를 실행하기 위한 인터페이스
private protocol ComponentBox {
    associatedtype Base: Component
    
    var base: Base { get }
    var reuseIdentifier: String { get }
    var layoutMode: ContentLayoutMode { get }
    var viewModel: Base.ViewModel { get }
    
    func renderContent(coordinator: Any) -> UIView
    func render(in content: UIView, coordinator: Any)
    func layout(content: UIView, in container: UIView)
    func makeCoordinator() -> Any
}

/// 실제 `Component`를 감싸는 Box 구현체
private struct AnyComponentBox<Base: Component>: ComponentBox {

    /// 실제 Component
    var baseComponent: Base
    
    /// 재사용 식별자
    var reuseIdentifier: String {
        baseComponent.reuseIdentifier
    }
    
    /// ViewModel
    var viewModel: Base.ViewModel {
        baseComponent.viewModel
    }
    
    /// 레이아웃 모드
    var layoutMode: ContentLayoutMode {
        baseComponent.layoutMode
    }
    
    /// base 접근
    var base: Base {
        baseComponent
    }
    
    /// 실제 `Component`를 감싸는 Box 구현체
    init(_ base: Base) {
        self.baseComponent = base
    }
    
    /// 콘텐츠 생성 (강제 캐스팅)
    func renderContent(coordinator: Any) -> UIView {
        baseComponent.renderContent(coordinator: coordinator as! Base.Coordinator)
    }
    
    /// 콘텐츠 업데이트
    func render(in content: UIView, coordinator: Any) {
        guard let content = content as? Base.Content,
              let coordinator = coordinator as? Base.Coordinator else {
            return
        }
        baseComponent.render(in: content, coordinator: coordinator)
    }
    
    /// 레이아웃 수행
    func layout(content: UIView, in container: UIView) {
        guard let content = content as? Base.Content else { return }
        baseComponent.layout(content: content, in: container)
    }
    
    /// Coordinator 생성
    func makeCoordinator() -> Any {
        baseComponent.makeCoordinator()
    }
}

public struct AnyComponent: Component, Equatable {
    
    // AnyComponentBox
    private let box: any ComponentBox
    
    /// 내부에 담긴 실제 `Component`
    public var base: any Component {
        box.base
    }
    
    /// 컴포넌트의 레이아웃 모드
    public var layoutMode: ContentLayoutMode {
        box.layoutMode
    }
    
    /// 재사용 식별자 (reuse identifier)
    public var reuseIdentifier: String {
        box.reuseIdentifier
    }
    
    /// 컴포넌트의 `ViewModel` (타입 소거된 형태)
    public var viewModel: AnyViewModel {
        AnyViewModel(box.base)
    }
    
    /// 전달된 `Component`를 감싸서 `AnyComponent` 생성
    ///
    /// - Parameter base: 감쌀 `Component`
    public init(_ base: some Component) {
        self.box = AnyComponentBox(base)
    }
    
    /// 콘텐츠(View)를 생성하고 초기 상태를 설정합니다.
    ///
    /// - Parameter coordinator: 렌더링에 사용할 coordinator
    /// - Returns: 생성된 UIView
    public func renderContent(coordinator: Any) -> UIView {
        box.renderContent(coordinator: coordinator)
    }
    
    /// 콘텐츠(View)를 생성하고 초기 상태를 설정합니다.
    ///
    /// - Parameter coordinator: 렌더링에 사용할 coordinator
    /// - Returns: 생성된 UIView
    public func render(in content: UIView, coordinator: Any) {
        box.render(in: content, coordinator: coordinator)
    }
    
    /// 콘텐츠를 컨테이너 안에서 레이아웃합니다.
    ///
    /// - Parameters:
    ///   - content: 배치할 콘텐츠
    ///   - container: 콘텐츠를 배치할 부모 뷰
    public func layout(content: UIView, in container: UIView) {
        box.layout(content: content, in: container)
    }
    
    /// 내부 `Component`를 특정 타입으로 다운캐스팅 시도
    ///
    /// - Parameter _: 변환할 타입
    /// - Returns: 성공하면 해당 타입, 실패하면 nil
    public func `as`<T>(_: T.Type) -> T? {
        box.base as? T
    }
    
    /// SwiftUI와 통신하기 위한 Coordinator 생성
    ///
    /// (SwiftUI와 상호작용하지 않는 경우 필요 없음)
    /// - Returns: Coordinator 인스턴스
    public func makeCoordinator() -> Any {
        box.makeCoordinator()
    }
    
    /// 두 `AnyComponent`가 같은지 비교
    ///
    /// - Parameters:
    ///   - lhs: 왼쪽 값
    ///   - rhs: 오른쪽 값
    /// - Returns: 같으면 true
    public static func == (lhs: AnyComponent, rhs: AnyComponent) -> Bool {
        lhs.viewModel == rhs.viewModel
    }
}
