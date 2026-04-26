import UIKit

/// `TurboListKit` 없이도 타입 소거 기반 컬렉션 어댑터를 만들 수 있음을 보여주는 예제 화면입니다.
final class LightweightAdapterViewController: UIViewController {
    /// 단일 섹션 FlowLayout을 사용하는 컬렉션뷰입니다.
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    /// 셀 등록, dequeue, 크기 계산 연결만 담당하는 초경량 어댑터입니다.
    private lazy var adapter = LightweightCollectionAdapter(collectionView: collectionView)

    /// 화면 기본 설정과 컬렉션뷰 레이아웃을 구성한 뒤 첫 스냅샷을 적용합니다.
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Lightweight Adapter"
        view.backgroundColor = .systemGroupedBackground
        navigationItem.largeTitleDisplayMode = .never

        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        applySnapshot()
    }

    /// 서로 다른 셀 타입 컴포넌트를 하나의 배열로 섞어 화면에 반영합니다.
    private func applySnapshot() {
//        adapter.apply([
//            LightweightAnyComponent(
//                HeroCardComponent(
//                    id: "intro",
//                    title: "TurboListKit 없이도 CollectionAdapter 패턴을 작게 가져올 수 있습니다.",
//                    message: "이 화면은 라이브러리를 import 하지 않고, 셀 등록과 렌더링만 담당하는 최소 어댑터를 직접 구현한 예제입니다."
//                )
//            ),
//            LightweightAnyComponent(
//                HeroCardComponent(
//                    id: "why-any-component",
//                    title: "왜 AnyComponent가 필요한가요?",
//                    message: "어댑터는 reuseIdentifier만 알고 셀을 dequeue 합니다. 이후 실제 셀 타입으로의 guard let 캐스팅과 configure는 타입 소거 박스 내부가 맡기 때문에, 어댑터는 특정 셀 클래스를 몰라도 됩니다."
//                )
//            ),
//            LightweightAnyComponent(
//                PillComponent(id: "register", title: "셀 등록 책임은 컴포넌트가 가짐", tintColor: .systemBlue)
//            ),
//            LightweightAnyComponent(
//                PillComponent(id: "dequeue", title: "어댑터는 dequeue + reload만 담당", tintColor: .systemGreen)
//            ),
//            LightweightAnyComponent(
//                PillComponent(id: "cast", title: "구체 타입 캐스팅은 박스 내부 guard let", tintColor: .systemOrange)
//            ),
//            LightweightAnyComponent(
//                PillComponent(id: "scope", title: "섹션/디프/이벤트는 과감히 생략", tintColor: .systemPink)
//            ),
//            LightweightAnyComponent(
//                NoteComponent(
//                    id: "summary",
//                    title: "핵심 요약",
//                    lines: [
//                        "1. Component가 자기 셀 타입을 알고 등록한다.",
//                        "2. AnyComponent가 그 Component를 타입 소거한다.",
//                        "3. Adapter는 AnyComponent 배열만 받아 공통 흐름만 실행한다."
//                    ]
//                )
//            ),
//        ])

        adapter.apply {
            HeroCardComponent(
                id: "intro",
                title: "TurboListKit 없이도 CollectionAdapter 패턴을 작게 가져올 수 있습니다.",
                message: "이 화면은 라이브러리를 import 하지 않고, 셀 등록과 렌더링만 담당하는 최소 어댑터를 직접 구현한 예제입니다."
            )

            HeroCardComponent(
                id: "why-any-component",
                title: "왜 AnyComponent가 필요한가요?",
                message: "builder를 쓰면 호출부에서는 AnyComponent를 직접 안 적어도 되지만, 내부적으로는 동일한 타입 소거가 일어나기 때문에 어댑터는 여전히 구체 셀 타입을 몰라도 됩니다."
            )

            PillComponent(id: "register", title: "builder가 타입 소거를 숨김", tintColor: .systemBlue)
            PillComponent(id: "dequeue", title: "호출부는 더 간결해짐", tintColor: .systemGreen)
            PillComponent(id: "cast", title: "guard let은 여전히 박스 내부", tintColor: .systemOrange)
            PillComponent(id: "scope", title: "내부 구조는 그대로 유지", tintColor: .systemPink)

            NoteComponent(
                id: "summary",
                title: "핵심 요약",
                lines: [
                    "1. 예전 방식은 LightweightAnyComponent(...)를 직접 감쌌다.",
                    "2. builder 방식은 그 감싸기 작업을 내부로 숨긴다.",
                    "3. 결과적으로 최종 타입은 여전히 [LightweightAnyComponent] 이다."
                ]
            )
        }
    }
}

/// 큰 설명 카드 셀을 렌더링하는 컴포넌트입니다.
private struct HeroCardComponent: LightweightComponent {
    typealias Cell = HeroCardCell

    /// reload 기반 예제에서 아이템 식별에 사용하는 값입니다.
    let id: AnyHashable

    /// 카드 상단 제목입니다.
    let title: String

    /// 카드 본문 설명입니다.
    let message: String

    /// `HeroCardCell`을 현재 데이터로 채웁니다.
    ///
    /// - Parameter cell: 설정할 실제 셀
    func configure(_ cell: HeroCardCell) {
        cell.configure(title: title, message: message)
    }

    /// 카드 셀의 고정 높이를 반환합니다.
    ///
    /// - Parameter containerSize: 배치 가능한 최대 크기
    /// - Returns: 카드 크기
    func sizeThatFits(in containerSize: CGSize) -> CGSize {
        CGSize(width: containerSize.width, height: 140)
    }
}

/// 제목과 설명을 세로로 쌓아 보여주는 카드형 셀입니다.
private final class HeroCardCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let stackView = UIStackView()

    /// 셀 내부 스택뷰와 레이블을 초기화합니다.
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .secondarySystemGroupedBackground
        contentView.layer.cornerRadius = 20

        titleLabel.font = .preferredFont(forTextStyle: .title3)
        titleLabel.numberOfLines = 0

        messageLabel.font = .preferredFont(forTextStyle: .body)
        messageLabel.textColor = .secondaryLabel
        messageLabel.numberOfLines = 0

        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(messageLabel)
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -18),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    /// 카드 제목과 설명을 셀에 반영합니다.
    ///
    /// - Parameters:
    ///   - title: 상단 제목
    ///   - message: 본문 설명
    func configure(title: String, message: String) {
        titleLabel.text = title
        messageLabel.text = message
    }
}

/// 짧은 키워드 문장을 pill 형태 셀로 렌더링하는 컴포넌트입니다.
private struct PillComponent: LightweightComponent {
    typealias Cell = PillCell

    /// reload 기반 예제에서 아이템 식별에 사용하는 값입니다.
    let id: AnyHashable

    /// pill 내부에 표시할 텍스트입니다.
    let title: String

    /// 텍스트와 배경에 함께 반영할 강조 색상입니다.
    let tintColor: UIColor

    /// `PillCell`을 현재 데이터로 채웁니다.
    ///
    /// - Parameter cell: 설정할 실제 셀
    func configure(_ cell: PillCell) {
        cell.configure(title: title, tintColor: tintColor)
    }

    /// 텍스트 길이에 맞춰 pill 폭을 계산합니다.
    ///
    /// - Parameter containerSize: 배치 가능한 최대 크기
    /// - Returns: pill 셀 크기
    func sizeThatFits(in containerSize: CGSize) -> CGSize {
        let font = UIFont.preferredFont(forTextStyle: .subheadline)
        let textWidth = (title as NSString).size(withAttributes: [.font: font]).width
        let width = min(containerSize.width, ceil(textWidth) + 32)
        return CGSize(width: width, height: 36)
    }
}

/// 짧은 텍스트를 둥근 pill 모양으로 보여주는 셀입니다.
private final class PillCell: UICollectionViewCell {
    private let titleLabel = UILabel()

    /// pill 스타일 라벨과 여백을 초기화합니다.
    override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel.font = .preferredFont(forTextStyle: .subheadline)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.layer.cornerRadius = 18
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    /// pill 텍스트와 색상을 셀에 반영합니다.
    ///
    /// - Parameters:
    ///   - title: 표시할 문구
    ///   - tintColor: 강조 색상
    func configure(title: String, tintColor: UIColor) {
        titleLabel.text = title
        titleLabel.textColor = tintColor
        contentView.backgroundColor = tintColor.withAlphaComponent(0.12)
    }
}

/// 여러 줄 요약 설명을 하단 노트 셀로 렌더링하는 컴포넌트입니다.
private struct NoteComponent: LightweightComponent {
    typealias Cell = NoteCell

    /// reload 기반 예제에서 아이템 식별에 사용하는 값입니다.
    let id: AnyHashable

    /// 노트 제목입니다.
    let title: String

    /// 줄 단위로 표시할 설명 목록입니다.
    let lines: [String]

    /// `NoteCell`을 현재 데이터로 채웁니다.
    ///
    /// - Parameter cell: 설정할 실제 셀
    func configure(_ cell: NoteCell) {
        cell.configure(title: title, lines: lines)
    }

    /// 노트 셀의 고정 높이를 반환합니다.
    ///
    /// - Parameter containerSize: 배치 가능한 최대 크기
    /// - Returns: 노트 셀 크기
    func sizeThatFits(in containerSize: CGSize) -> CGSize {
        CGSize(width: containerSize.width, height: 170)
    }
}

/// 모노스페이스 본문으로 구조 요약을 보여주는 셀입니다.
private final class NoteCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()

    /// 노트형 배경과 텍스트 레이아웃을 초기화합니다.
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .tertiarySystemGroupedBackground
        contentView.layer.cornerRadius = 18
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.separator.cgColor

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        messageLabel.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        messageLabel.textColor = .secondaryLabel
        messageLabel.numberOfLines = 0

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(titleLabel)
        contentView.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),

            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            messageLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -18),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    /// 제목과 여러 줄 설명을 셀에 반영합니다.
    ///
    /// - Parameters:
    ///   - title: 상단 제목
    ///   - lines: 줄 단위 설명 목록
    func configure(title: String, lines: [String]) {
        titleLabel.text = title
        messageLabel.text = lines.joined(separator: "\n")
    }
}
