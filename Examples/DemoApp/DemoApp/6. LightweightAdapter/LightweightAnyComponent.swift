import UIKit

/// 경량 어댑터에서 사용할 최소 단위 컴포넌트입니다.
///
/// `TurboListKit.Component`와 비슷하게 "셀 타입 + 데이터 + 설정 방법"을 하나로 묶되,
/// 이 예제에서는 컬렉션뷰 셀만 다루는 가장 작은 인터페이스만 남겼습니다.
protocol LightweightComponent {
    associatedtype Cell: UICollectionViewCell

    /// diff 대신 reload 기반으로만 갱신하므로, 예제에서는 식별자도 간단히 들고 갑니다.
    var id: AnyHashable { get }

    /// 어댑터는 이 문자열만 알고 셀을 dequeue 합니다.
    var reuseIdentifier: String { get }

    /// 셀 타입을 직접 몰라도 등록할 수 있도록 컴포넌트가 등록 책임을 가집니다.
    func registerCell(on collectionView: UICollectionView)

    /// dequeue 된 셀을 자신의 타입으로 해석해서 내용을 채웁니다.
    func configure(_ cell: Cell)

    /// 레이아웃 계산도 각 컴포넌트가 스스로 결정합니다.
    func sizeThatFits(in containerSize: CGSize) -> CGSize
}

extension LightweightComponent {
    /// 기본 구현은 셀 타입명을 그대로 재사용 식별자로 사용합니다.
    var reuseIdentifier: String {
        String(describing: Cell.self)
    }

    /// 기본 구현은 자신의 셀 타입을 컬렉션뷰에 그대로 등록합니다.
    ///
    /// - Parameter collectionView: 셀을 등록할 컬렉션뷰
    /// - LightweightComponent가 들고 있는 Cell 타입을 등록합니다.
    func registerCell(on collectionView: UICollectionView) {
        collectionView.register(Cell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
}

/// 타입 소거 이후 어댑터가 호출할 공통 인터페이스입니다.
private protocol LightweightComponentBox {
    /// diff나 선택 처리 대신, 예제에서는 데이터 식별 용도로만 사용합니다.
    var id: AnyHashable { get }

    /// 어댑터가 셀 등록/재사용에 사용하는 식별자입니다.
    var reuseIdentifier: String { get }

    /// 셀 타입을 모르는 어댑터를 대신해, 실제 셀 등록을 수행합니다.
    ///
    /// - Parameter collectionView: 셀을 등록할 컬렉션뷰
    func registerCell(on collectionView: UICollectionView)

    /// 셀 dequeue와 실제 타입 캐스팅, configure를 한 번에 처리합니다.
    ///
    /// - Parameters:
    ///   - collectionView: 셀을 꺼낼 컬렉션뷰
    ///   - indexPath: 셀 위치
    /// - Returns: configure가 끝난 셀
    func makeCell(in collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell

    /// 셀의 목표 크기를 계산합니다.
    ///
    /// - Parameter containerSize: 아이템이 배치될 수 있는 최대 크기
    /// - Returns: 셀이 원하는 최종 크기
    func sizeThatFits(in containerSize: CGSize) -> CGSize
}

/// 구체적인 `LightweightComponent`를 감싸 타입 소거 프로토콜로 노출합니다.
private struct ConcreteLightweightComponentBox<Base: LightweightComponent>: LightweightComponentBox {
    /// 실제 셀 타입과 configure 로직을 알고 있는 원본 컴포넌트입니다.
    let base: Base

    var id: AnyHashable { base.id }
    var reuseIdentifier: String { base.reuseIdentifier }

    /// 원본 컴포넌트에 셀 등록 책임을 그대로 위임합니다.
    ///
    /// - Parameter collectionView: 셀을 등록할 컬렉션뷰
    func registerCell(on collectionView: UICollectionView) {
        base.registerCell(on: collectionView)
    }

    /// dequeue 한 셀을 원본 셀 타입으로 해석한 뒤 configure 합니다.
    ///
    /// - Parameters:
    ///   - collectionView: 셀을 꺼낼 컬렉션뷰
    ///   - indexPath: 셀 위치
    /// - Returns: 원본 타입으로 설정된 셀
    func makeCell(in collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: reuseIdentifier,
            for: indexPath
        )

        // 중요한 포인트:
        // 어댑터는 "이 셀이 HeroCell인지 PillCell인지" 몰라도 됩니다.
        // 실제 타입 캐스팅은 타입 소거 박스 내부에서만 수행합니다.
        guard let typedCell = cell as? Base.Cell else {
            return cell
        }

        base.configure(typedCell)
        return typedCell
    }

    /// 실제 크기 계산은 원본 컴포넌트가 가장 잘 알고 있으므로 그대로 위임합니다.
    ///
    /// - Parameter containerSize: 아이템이 배치될 수 있는 최대 크기
    /// - Returns: 원본 컴포넌트가 계산한 크기
    func sizeThatFits(in containerSize: CGSize) -> CGSize {
        base.sizeThatFits(in: containerSize)
    }
}

/// 어댑터가 이 타입 하나만 들고 다양한 셀을 섞어 렌더링합니다.
struct LightweightAnyComponent {
    /// 타입 소거된 실제 컴포넌트 저장소입니다.
    private let box: any LightweightComponentBox

    /// 원본 컴포넌트의 식별자입니다.
    var id: AnyHashable { box.id }

    /// 어댑터가 셀 재사용에 사용하는 식별자입니다.
    var reuseIdentifier: String { box.reuseIdentifier }

    /// 임의의 경량 컴포넌트를 타입 소거 래퍼로 감쌉니다.
    ///
    /// - Parameter base: 감쌀 원본 컴포넌트
    init(_ base: some LightweightComponent) {
        self.box = ConcreteLightweightComponentBox(base: base)
    }

    /// 원본 컴포넌트를 대신해 셀 등록을 수행합니다.
    ///
    /// - Parameter collectionView: 셀을 등록할 컬렉션뷰
    func registerCell(on collectionView: UICollectionView) {
        box.registerCell(on: collectionView)
    }

    /// 어댑터가 구체 타입을 몰라도 셀을 생성할 수 있게 도와줍니다.
    ///
    /// - Parameters:
    ///   - collectionView: 셀을 꺼낼 컬렉션뷰
    ///   - indexPath: 셀 위치
    /// - Returns: configure가 완료된 셀
    func makeCell(in collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        box.makeCell(in: collectionView, at: indexPath)
    }

    /// 원본 컴포넌트의 크기 계산 결과를 그대로 노출합니다.
    ///
    /// - Parameter containerSize: 아이템이 배치될 수 있는 최대 크기
    /// - Returns: 최종 셀 크기
    func sizeThatFits(in containerSize: CGSize) -> CGSize {
        box.sizeThatFits(in: containerSize)
    }
}
