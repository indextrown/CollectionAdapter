//
//  File.swift
//  CollectionAdapter
//
//  Created by 김동현 on 4/22/26.
//

import UIKit

/// Component는 이 프레임워크에서 가장 작은 단위입니다.
/// 화면에 표시될 데이터와 동작을 선언형(declarative)으로 표현할 수 있게 합니다.
///
/// 이 인터페이스는 UIViewRepresentable과 매우 유사하게 설계되어 있습니다.
/// 이러한 유사성 덕분에, 향후 SwiftUI로 전환할 때 마이그레이션 비용을 줄일 수 있습니다.
public protocol Component {
    
    /// Component에 연결된 ViewModel 타입입니다.
    /// ViewModel은 반드시 Equatable을 준수해야 합니다.
    associatedtype ViewModel: Equatable
    
    /// Component가 표현하는 실제 UI 타입입니다.
    associatedtype Content: UIView
    
    /// Component와 연결된 Coordinator 타입입니다.
    /// 기본값은 Void 입니다.
    associatedtype Coordinator = Void
    
    /// Component가 가지고 있는 데이터(ViewModel)
    var viewModel: ViewModel { get }
    
    /// Component를 식별하기 위한 재사용 식별자
    var reuseIdentifier: String { get }
    
    /// Content의 레이아웃 방식
    var layoutMode: ContentLayoutMode { get }
    
    /// Content를 생성하고 초기 상태를 설정합니다.
    ///
    /// - Parameter coordinator: 렌더링에 사용할 Coordinator
    /// - Returns: 생성된 Content(View)
    func renderContent(coordinator: Coordinator) -> Content
    
    /// 기존 Content에 새로운 데이터를 반영하여 업데이트합니다.
    ///
    /// - Parameters:
    ///   - content: 업데이트할 Content
    ///   - coordinator: 렌더링에 사용할 Coordinator
    func render(in content: Content, coordinator: Coordinator)
    
    /// Content를 container 뷰 안에 배치(layout)합니다.
    ///
    /// - Parameters:
    ///   - content: 배치할 Content
    ///   - container: Content를 담을 부모 뷰
    func layout(content: Content, in container: UIView)
    
    /// SwiftUI에서 View → 외부와 통신하기 위한 Coordinator를 생성합니다.
    ///
    /// 만약 View가 외부와 상호작용하지 않는다면 Coordinator는 필요 없습니다.
    /// - Returns: 새로운 Coordinator 인스턴스
    func makeCoordinator() -> Coordinator
}

extension Component {
    /// 기본적으로 reuseIdentifier는 클래스 이름을 사용합니다.
    public var reuseIdentifier: String {
        String(reflecting: Self.self)
    }
}

extension Component where Coordinator == Void {
    /// Coordinator를 사용하지 않는 경우, 기본적으로 빈 값(Void)을 반환합니다.
    public func makeCoordinator() -> Coordinator {
        return ()
    }
}

extension Component where Content: UIView {
    /// 기본 layout 구현: content를 container에 추가하고, 오토레이아웃으로 전체 꽉 채우도록 설정합니다.
    @MainActor public func layout(content: Content, in container: UIView) {
        content.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(content)
        
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: container.topAnchor),
            content.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            content.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            content.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])
    }
}
