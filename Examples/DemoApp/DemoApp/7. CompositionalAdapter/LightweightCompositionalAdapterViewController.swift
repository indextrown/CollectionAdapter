import UIKit

/// FlowLayout 대신 Compositional Layout으로 섹션별 레이아웃을 분리한 경량 어댑터 예제입니다.
final class LightweightCompositionalAdapterViewController: UIViewController {
    /// 섹션별 레이아웃을 adapter에서 꺼내오는 컬렉션뷰 레이아웃입니다.
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            MainActor.assumeIsolated {
                self?.adapter.layoutSection(at: sectionIndex, environment: environment)
            }
        }

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    /// 섹션 데이터와 셀 등록을 관리하는 Compositional 전용 경량 어댑터입니다.
    private lazy var adapter = LightweightCompositionalAdapter(collectionView: collectionView)

    /// 화면 구성과 첫 섹션 스냅샷 적용을 담당합니다.
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Compositional Adapter"
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

    /// 서로 다른 섹션 레이아웃을 한 화면에 적용해 Compositional Layout 장점을 보여줍니다.
    private func applySnapshot() {
        adapter.apply([
            LightweightCompositionalSection(
                id: "overview",
                layoutProvider: CompositionalExampleLayouts.makeVerticalCardsSectionLayout
            ) {
                CompositionalHeroCardComponent(
                    id: "intro",
                    title: "이번 예제는 FlowLayout 대신 Compositional Layout을 사용합니다.",
                    message: "아이템 타입 소거 방식은 유지하고, 레이아웃만 섹션 단위로 분리해서 더 복잡한 화면 구성을 보여줍니다."
                )

                CompositionalHeroCardComponent(
                    id: "difference",
                    title: "무엇이 달라졌나요?",
                    message: "6번은 item size를 delegate 메서드에서 계산했습니다. 7번은 섹션마다 NSCollectionLayoutSection을 직접 만들어, 세로 카드와 가로 pill 섹션을 한 어댑터에서 동시에 다룹니다."
                )
            },
            LightweightCompositionalSection(
                id: "chips",
                layoutProvider: CompositionalExampleLayouts.makeHorizontalPillsSectionLayout
            ) {
                CompositionalPillComponent(id: "chip-1", title: "section마다 layoutProvider 보유", tintColor: .systemBlue)
                CompositionalPillComponent(id: "chip-2", title: "가로 스크롤도 쉽게 구성", tintColor: .systemGreen)
                CompositionalPillComponent(id: "chip-3", title: "item 타입 소거는 동일", tintColor: .systemOrange)
                CompositionalPillComponent(id: "chip-4", title: "FlowLayout size delegate 불필요", tintColor: .systemPink)
                CompositionalPillComponent(id: "chip-5", title: "섹션별 inset과 behavior 분리", tintColor: .systemTeal)
            },
            LightweightCompositionalSection(
                id: "summary",
                layoutProvider: CompositionalExampleLayouts.makeVerticalCardsSectionLayout
            ) {
                CompositionalNoteComponent(
                    id: "summary-note",
                    title: "핵심 요약",
                    lines: [
                        "1. 어댑터는 여전히 LightweightAnyComponent만 안다.",
                        "2. 차이는 item size 계산이 아니라 section layout 생성으로 이동한 점이다.",
                        "3. 그래서 한 화면에서 서로 다른 스크롤/배치를 더 자연스럽게 섞을 수 있다."
                    ]
                )
            },
        ])
    }
}

/// `UIViewController` 밖으로 분리한 Compositional 예제 레이아웃 팩토리입니다.
private enum CompositionalExampleLayouts {
    /// 세로 카드 섹션 레이아웃을 생성합니다.
    ///
    /// - Parameter environment: 현재 레이아웃 환경
    /// - Returns: 전체 너비 카드가 세로로 쌓이는 섹션
    nonisolated static func makeVerticalCardsSectionLayout(
        environment: NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection {
        MainActor.assumeIsolated {
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(140)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(140)
            )
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 12
            section.contentInsets = .init(top: 20, leading: 20, bottom: 12, trailing: 20)
            return section
        }
    }

    /// 가로 pill 섹션 레이아웃을 생성합니다.
    ///
    /// - Parameter environment: 현재 레이아웃 환경
    /// - Returns: 연속 스크롤되는 pill 섹션
    nonisolated static func makeHorizontalPillsSectionLayout(
        environment: NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection {
        MainActor.assumeIsolated {
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .estimated(180),
                heightDimension: .absolute(36)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .estimated(180),
                heightDimension: .absolute(36)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 10
            section.contentInsets = .init(top: 4, leading: 20, bottom: 20, trailing: 20)
            return section
        }
    }
}

/// 큰 설명 카드 셀을 렌더링하는 Compositional 예제용 컴포넌트입니다.
private struct CompositionalHeroCardComponent: CompositionalComponent {
    typealias Cell = CompositionalHeroCardCell

    let id: AnyHashable
    let title: String
    let message: String

    func configure(_ cell: CompositionalHeroCardCell) {
        cell.configure(title: title, message: message)
    }

}

/// Compositional 예제의 카드형 셀입니다.
private final class CompositionalHeroCardCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let stackView = UIStackView()

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

    func configure(title: String, message: String) {
        titleLabel.text = title
        messageLabel.text = message
    }
}

/// 짧은 문장을 pill 형태로 렌더링하는 Compositional 예제용 컴포넌트입니다.
private struct CompositionalPillComponent: CompositionalComponent {
    typealias Cell = CompositionalPillCell

    let id: AnyHashable
    let title: String
    let tintColor: UIColor

    func configure(_ cell: CompositionalPillCell) {
        cell.configure(title: title, tintColor: tintColor)
    }

}

/// 가로 스크롤 섹션에서 사용할 pill 셀입니다.
private final class CompositionalPillCell: UICollectionViewCell {
    private let titleLabel = UILabel()

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

    func configure(title: String, tintColor: UIColor) {
        titleLabel.text = title
        titleLabel.textColor = tintColor
        contentView.backgroundColor = tintColor.withAlphaComponent(0.12)
    }
}

/// 여러 줄 요약 설명을 보여주는 Compositional 예제용 노트 컴포넌트입니다.
private struct CompositionalNoteComponent: CompositionalComponent {
    typealias Cell = CompositionalNoteCell

    let id: AnyHashable
    let title: String
    let lines: [String]

    func configure(_ cell: CompositionalNoteCell) {
        cell.configure(title: title, lines: lines)
    }

}

/// 요약 노트를 카드 형태로 보여주는 셀입니다.
private final class CompositionalNoteCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()

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

    func configure(title: String, lines: [String]) {
        titleLabel.text = title
        messageLabel.text = lines.joined(separator: "\n")
    }
}
