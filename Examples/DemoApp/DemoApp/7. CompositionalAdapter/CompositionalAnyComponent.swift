import UIKit

/// `7`번 Compositional 예제 전용 최소 컴포넌트 프로토콜입니다.
///
/// `6`번 예제와 파일/타입을 공유하지 않기 위해,
/// 동일한 아이디어를 이 폴더 안에서 독립적으로 다시 정의합니다.
protocol CompositionalComponent {
    associatedtype Cell: UICollectionViewCell

    /// 예제용 아이템 식별자입니다.
    var id: AnyHashable { get }

    /// 셀 재사용 식별자입니다.
    var reuseIdentifier: String { get }

    /// 자신의 셀 타입을 컬렉션뷰에 등록합니다.
    func registerCell(on collectionView: UICollectionView)

    /// dequeue 된 실제 셀 타입을 configure 합니다.
    func configure(_ cell: Cell)
}

extension CompositionalComponent {
    /// 기본 구현은 셀 타입명을 그대로 재사용 식별자로 사용합니다.
    var reuseIdentifier: String {
        String(describing: Cell.self)
    }

    /// 기본 구현은 자신의 셀 타입을 그대로 등록합니다.
    ///
    /// - Parameter collectionView: 셀을 등록할 컬렉션뷰
    func registerCell(on collectionView: UICollectionView) {
        collectionView.register(Cell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
}

/// 타입 소거 이후 어댑터가 호출할 공통 인터페이스입니다.
private protocol CompositionalComponentBox {
    var id: AnyHashable { get }
    var reuseIdentifier: String { get }

    func registerCell(on collectionView: UICollectionView)
    func makeCell(in collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell
}

/// 구체적인 `CompositionalComponent`를 감싸는 타입 소거 박스입니다.
private struct ConcreteCompositionalComponentBox<Base: CompositionalComponent>: CompositionalComponentBox {
    let base: Base

    var id: AnyHashable { base.id }
    var reuseIdentifier: String { base.reuseIdentifier }

    func registerCell(on collectionView: UICollectionView) {
        base.registerCell(on: collectionView)
    }

    func makeCell(in collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: reuseIdentifier,
            for: indexPath
        )

        guard let typedCell = cell as? Base.Cell else {
            return cell
        }

        base.configure(typedCell)
        return typedCell
    }
}

/// Compositional 예제 전용 타입 소거 컴포넌트입니다.
struct CompositionalAnyComponent {
    private let box: any CompositionalComponentBox

    var id: AnyHashable { box.id }
    var reuseIdentifier: String { box.reuseIdentifier }

    /// 임의의 Compositional 컴포넌트를 타입 소거 래퍼로 감쌉니다.
    ///
    /// - Parameter base: 감쌀 원본 컴포넌트
    init(_ base: some CompositionalComponent) {
        self.box = ConcreteCompositionalComponentBox(base: base)
    }

    /// 원본 컴포넌트를 대신해 셀 등록을 수행합니다.
    ///
    /// - Parameter collectionView: 셀을 등록할 컬렉션뷰
    func registerCell(on collectionView: UICollectionView) {
        box.registerCell(on: collectionView)
    }

    /// 구체 타입을 몰라도 셀을 생성할 수 있게 도와줍니다.
    ///
    /// - Parameters:
    ///   - collectionView: 셀을 꺼낼 컬렉션뷰
    ///   - indexPath: 셀 위치
    /// - Returns: configure가 완료된 셀
    func makeCell(in collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        box.makeCell(in: collectionView, at: indexPath)
    }
}
