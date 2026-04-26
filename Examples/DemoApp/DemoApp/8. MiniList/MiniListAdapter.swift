import UIKit

/// `MiniList` 루트 타입을 입력으로 받는 Compositional Layout 기반 어댑터입니다.
final class MiniListAdapter: NSObject {
    /// 실제 화면을 그리는 컬렉션뷰입니다.
    private weak var collectionView: UICollectionView?

    /// 현재 화면에 반영된 루트 스냅샷입니다.
    private var list: MiniList?

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

    /// 화면 전체 스냅샷을 루트 `MiniList` 하나로 받아 반영합니다.
    ///
    /// - Parameter list: 화면 전체 상태
    func apply(_ list: MiniList) {
        guard let collectionView else { return }

        registerIfNeeded(for: list, on: collectionView)
        self.list = list
        collectionView.reloadData()
    }

    /// 섹션 인덱스에 해당하는 Compositional Layout 섹션을 반환합니다.
    func layoutSection(
        at sectionIndex: Int,
        environment: NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection? {
        list?.sections[safe: sectionIndex]?.layoutProvider(environment)
    }

    /// indexPath에 해당하는 셀 모델을 반환합니다.
    func cell(at indexPath: IndexPath) -> MiniListCell? {
        list?.sections[safe: indexPath.section]?.cells[safe: indexPath.item]
    }

    /// 아직 등록하지 않은 셀 타입만 컬렉션뷰에 등록합니다.
    private func registerIfNeeded(
        for list: MiniList,
        on collectionView: UICollectionView
    ) {
        for section in list.sections {
            for cell in section.cells where registeredReuseIdentifiers.contains(cell.component.reuseIdentifier) == false {
                registeredReuseIdentifiers.insert(cell.component.reuseIdentifier)
                cell.component.registerCell(on: collectionView)
            }
        }
    }
}

extension MiniListAdapter: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        list?.sections.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        list?.sections[section].cells.count ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = cell(at: indexPath) else {
            return UICollectionViewCell()
        }

        return cell.component.makeCell(in: collectionView, at: indexPath)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
