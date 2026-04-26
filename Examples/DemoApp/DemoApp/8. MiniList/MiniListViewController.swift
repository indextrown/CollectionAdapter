import UIKit

/// `List -> Section -> Cell -> Component` 계층이 왜 생기는지 보여주는 예제 화면입니다.
final class MiniListViewController: UIViewController {
    /// 루트 `MiniList`에서 섹션 레이아웃을 꺼내오는 컬렉션뷰입니다.
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

    /// 루트 `MiniList` 하나를 입력으로 받아 전체 화면을 갱신하는 어댑터입니다.
    private lazy var adapter = MiniListAdapter(collectionView: collectionView)

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Mini List"
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

    /// 어댑터에 배열 여러 개 대신 `MiniList` 하나만 넘겨 전체 상태를 반영합니다.
    private func applySnapshot() {
        adapter.apply(
            MiniList {
                MiniListSection(
                    id: "overview",
                    layoutProvider: MiniListExampleLayouts.makeVerticalCardsSectionLayout
                ) {
                    MiniListHeroComponent(
                        id: "why-list",
                        title: "왜 List 타입이 필요한가요?",
                        message: "컴포넌트 배열만 바로 어댑터에 넘기면 화면 전체 상태를 묶는 루트 타입이 없습니다. List가 생기면 어댑터 입력이 항상 하나로 고정되고, 그 안에 섹션과 셀 구조를 담을 수 있습니다."
                    )

                    MiniListHeroComponent(
                        id: "benefit",
                        title: "그래서 무엇이 좋아지나요?",
                        message: "diff, 전역 이벤트, refresh 상태, header/footer, 화면 단위 옵션처럼 '전체 스냅샷' 기준으로 다뤄야 하는 기능을 List 루트에 자연스럽게 붙일 수 있습니다."
                    )
                }

                MiniListSection(
                    id: "chips",
                    layoutProvider: MiniListExampleLayouts.makeHorizontalPillsSectionLayout
                ) {
                    MiniListPillComponent(id: "chip-1", title: "입력이 항상 MiniList 하나", tintColor: .systemBlue)
                    MiniListPillComponent(id: "chip-2", title: "섹션 구조가 명확해짐", tintColor: .systemGreen)
                    MiniListPillComponent(id: "chip-3", title: "셀도 명시적 모델이 생김", tintColor: .systemOrange)
                    MiniListPillComponent(id: "chip-4", title: "전역 기능 추가 위치 확보", tintColor: .systemPink)
                    MiniListPillComponent(id: "chip-5", title: "DSL 확장이 쉬움", tintColor: .systemTeal)
                }

                MiniListSection(
                    id: "summary",
                    layoutProvider: MiniListExampleLayouts.makeVerticalCardsSectionLayout
                ) {
                    MiniListNoteComponent(
                        id: "summary-note",
                        title: "핵심 비교",
                        lines: [
                            "1. 6번: 어댑터 입력이 [AnyComponent] 중심",
                            "2. 7번: 어댑터 입력이 [Section] 중심",
                            "3. 8번: 어댑터 입력이 MiniList 하나로 고정",
                            "4. 그래서 화면 전체 상태를 다루는 기능이 붙기 쉬워진다."
                        ]
                    )
                }
            }
        )
    }
}

/// `UIViewController` 밖으로 분리한 MiniList 예제 레이아웃 팩토리입니다.
private enum MiniListExampleLayouts {
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

    nonisolated static func makeHorizontalPillsSectionLayout(
        environment: NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection {
        MainActor.assumeIsolated {
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .estimated(190),
                heightDimension: .absolute(36)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .estimated(190),
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

private struct MiniListHeroComponent: MiniListComponent {
    typealias Cell = MiniListHeroCell

    let id: AnyHashable
    let title: String
    let message: String

    func configure(_ cell: MiniListHeroCell) {
        cell.configure(title: title, message: message)
    }
}

private final class MiniListHeroCell: UICollectionViewCell {
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

private struct MiniListPillComponent: MiniListComponent {
    typealias Cell = MiniListPillCell

    let id: AnyHashable
    let title: String
    let tintColor: UIColor

    func configure(_ cell: MiniListPillCell) {
        cell.configure(title: title, tintColor: tintColor)
    }
}

private final class MiniListPillCell: UICollectionViewCell {
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

private struct MiniListNoteComponent: MiniListComponent {
    typealias Cell = MiniListNoteCell

    let id: AnyHashable
    let title: String
    let lines: [String]

    func configure(_ cell: MiniListNoteCell) {
        cell.configure(title: title, lines: lines)
    }
}

private final class MiniListNoteCell: UICollectionViewCell {
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
