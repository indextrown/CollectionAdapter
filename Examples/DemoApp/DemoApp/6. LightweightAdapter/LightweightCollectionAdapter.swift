import UIKit

/// `TurboListKit.CollectionViewAdapter` 아이디어만 남긴 초경량 버전입니다.
///
/// 남겨둔 기능:
/// - 셀 등록
/// - 데이터 보관
/// - dequeue / configure
/// - item size 계산
///
/// 뺀 기능:
/// - diff update
/// - section / supplementary view
/// - event plugin
/// - prefetch
/// - refresh control
final class LightweightCollectionAdapter: NSObject {
    /// 실제 화면을 그리는 컬렉션뷰입니다.
    private weak var collectionView: UICollectionView?

    /// 현재 화면에 렌더링할 타입 소거 컴포넌트 목록입니다.
    private var components: [LightweightAnyComponent] = []

    /// 이미 등록한 셀 타입을 추적해 중복 등록을 피합니다.
    private var registeredReuseIdentifiers = Set<String>()

    /// 단일 섹션의 바깥 여백입니다.
    let sectionInsets = UIEdgeInsets(top: 20, left: 20, bottom: 32, right: 20)

    /// 세로 방향 셀 간격입니다.
    let minimumLineSpacing: CGFloat = 12

    /// 가로 방향 셀 간격입니다.
    let minimumInteritemSpacing: CGFloat = 10

    /// 컬렉션뷰에 dataSource / delegate를 연결한 뒤 어댑터를 초기화합니다.
    ///
    /// - Parameter collectionView: 어댑터가 제어할 컬렉션뷰
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    /// 예제에서는 한 섹션, reload 기반 갱신만 지원합니다.
    ///
    /// - Parameter components: 화면에 표시할 컴포넌트 목록
    func apply(_ components: [LightweightAnyComponent]) {
        guard let collectionView else { return }

        registerIfNeeded(for: components, on: collectionView)
        self.components = components
        collectionView.reloadData()
    }

    /// `ResultBuilder` 문법으로 컴포넌트 목록을 만들고 화면에 반영합니다.
    ///
    /// 호출부에서는 `LightweightAnyComponent(...)`를 직접 적지 않아도 되지만,
    /// 내부적으로는 builder가 동일한 타입 소거 배열을 만들어 기존 `apply(_:)`로 넘깁니다.
    ///
    /// - Parameter content: 여러 컴포넌트를 선언형으로 만드는 builder 클로저
//    func apply(_ content: () -> [LightweightAnyComponent]) {
//        apply(content())
//    }

//    위 코드는 Result Builder 없이 "배열을 직접 반환하는 클로저" 버전입니다.
//    아래 구현은 같은 흐름에 `@LightweightComponentBuilder`만 추가해서,
//    호출부에서 `LightweightAnyComponent(...)` 감싸기를 숨긴 버전입니다.
    func apply(
        @LightweightComponentBuilder _ content: () -> [LightweightAnyComponent]
    ) {
        apply(content())
    }

    /// 아직 등록하지 않은 셀 타입만 골라 컬렉션뷰에 등록합니다.
    ///
    /// - Parameters:
    ///   - components: 등록 후보 컴포넌트 목록
    ///   - collectionView: 셀을 등록할 컬렉션뷰
    private func registerIfNeeded(
        for components: [LightweightAnyComponent],
        on collectionView: UICollectionView
    ) {
        for component in components where registeredReuseIdentifiers.contains(component.reuseIdentifier) == false {
            registeredReuseIdentifiers.insert(component.reuseIdentifier)
            component.registerCell(on: collectionView)
        }
    }
}

extension LightweightCollectionAdapter: UICollectionViewDataSource {
    /// 단일 섹션에 표시할 아이템 수를 반환합니다.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        components.count
    }

    /// 예제 단순화를 위해 섹션 수는 항상 1개입니다.
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    /// 타입 소거 컴포넌트에게 셀 생성과 설정을 위임합니다.
    ///
    /// - Parameters:
    ///   - collectionView: 셀을 표시할 컬렉션뷰
    ///   - indexPath: 요청된 셀 위치
    /// - Returns: configure가 끝난 셀
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        components[indexPath.item].makeCell(in: collectionView, at: indexPath)
    }
}

extension LightweightCollectionAdapter: UICollectionViewDelegateFlowLayout {
    /// 각 컴포넌트가 스스로 계산한 크기를 FlowLayout에 전달합니다.
    ///
    /// - Parameters:
    ///   - collectionView: 셀이 배치될 컬렉션뷰
    ///   - collectionViewLayout: 사용 중인 레이아웃
    ///   - indexPath: 요청된 셀 위치
    /// - Returns: 최종 셀 크기
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let availableWidth = collectionView.bounds.width - sectionInsets.left - sectionInsets.right
        return components[indexPath.item].sizeThatFits(
            in: CGSize(width: max(availableWidth, 1), height: collectionView.bounds.height)
        )
    }

    /// 섹션 바깥 여백을 반환합니다.
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        sectionInsets
    }

    /// 세로 방향 셀 간격을 반환합니다.
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        minimumLineSpacing
    }

    /// 가로 방향 셀 간격을 반환합니다.
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        minimumInteritemSpacing
    }
}
