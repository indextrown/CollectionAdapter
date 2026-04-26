import UIKit

/// `UICollectionViewCompositionalLayout` 전용 경량 어댑터입니다.
///
/// `6`번 예제가 한 섹션 FlowLayout 중심이라면,
/// 이 어댑터는 섹션별로 서로 다른 레이아웃을 적용하는 예제에 초점을 둡니다.
final class LightweightCompositionalAdapter: NSObject {
    /// 실제 화면을 그리는 컬렉션뷰입니다.
    private weak var collectionView: UICollectionView?

    /// 현재 화면에 반영된 섹션 목록입니다.
    private var sections: [LightweightCompositionalSection] = []

    /// 중복 셀 등록을 막기 위한 재사용 식별자 저장소입니다.
    private var registeredReuseIdentifiers = Set<String>()

    /// 컬렉션뷰의 dataSource를 연결하며 어댑터를 초기화합니다.
    ///
    /// - Parameter collectionView: 어댑터가 제어할 컬렉션뷰
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        collectionView.dataSource = self
    }

    /// 전체 섹션 스냅샷을 한 번에 교체합니다.
    ///
    /// - Parameter sections: 화면에 표시할 섹션 목록
    func apply(_ sections: [LightweightCompositionalSection]) {
        guard let collectionView else { return }

        registerIfNeeded(for: sections, on: collectionView)
        self.sections = sections
        collectionView.reloadData()
    }

    /// 특정 섹션 인덱스에 해당하는 Compositional Layout 섹션을 반환합니다.
    ///
    /// - Parameters:
    ///   - sectionIndex: 요청된 섹션 인덱스
    ///   - environment: 현재 레이아웃 환경
    /// - Returns: 섹션 레이아웃. 범위를 벗어나면 `nil`
    func layoutSection(
        at sectionIndex: Int,
        environment: NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection? {
        sections[safe: sectionIndex]?.layoutProvider(environment)
    }

    /// indexPath에 해당하는 타입 소거 컴포넌트를 반환합니다.
    ///
    /// - Parameter indexPath: 요청된 아이템 위치
    /// - Returns: 해당 위치의 컴포넌트. 범위를 벗어나면 `nil`
    func component(at indexPath: IndexPath) -> CompositionalAnyComponent? {
        sections[safe: indexPath.section]?.components[safe: indexPath.item]
    }

    /// 아직 등록하지 않은 셀 타입만 골라 컬렉션뷰에 등록합니다.
    ///
    /// - Parameters:
    ///   - sections: 등록 후보 섹션 목록
    ///   - collectionView: 셀을 등록할 컬렉션뷰
    private func registerIfNeeded(
        for sections: [LightweightCompositionalSection],
        on collectionView: UICollectionView
    ) {
        for section in sections {
            for component in section.components where registeredReuseIdentifiers.contains(component.reuseIdentifier) == false {
                registeredReuseIdentifiers.insert(component.reuseIdentifier)
                component.registerCell(on: collectionView)
            }
        }
    }
}

extension LightweightCompositionalAdapter: UICollectionViewDataSource {
    /// 현재 섹션 수를 반환합니다.
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }

    /// 각 섹션의 아이템 수를 반환합니다.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sections[section].components.count
    }

    /// 타입 소거 컴포넌트에게 셀 생성과 configure를 위임합니다.
    ///
    /// - Parameters:
    ///   - collectionView: 셀을 표시할 컬렉션뷰
    ///   - indexPath: 요청된 셀 위치
    /// - Returns: configure가 끝난 셀
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let component = component(at: indexPath) else {
            return UICollectionViewCell()
        }

        return component.makeCell(in: collectionView, at: indexPath)
    }
}

private extension Array {
    /// 안전한 인덱스 접근을 제공합니다.
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
