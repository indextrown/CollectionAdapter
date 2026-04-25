import CollectionAdapter
import UIKit

struct VerticalLayoutItemComponent: Component {
    typealias ViewModel = VerticalLayoutItemView.ViewModel

    let viewModel: ViewModel

    var layoutMode: ContentLayoutMode {
        .flexibleHeight(estimatedHeight: 54.0)
    }

    func renderContent(coordinator: Void) -> VerticalLayoutItemView {
        VerticalLayoutItemView(viewModel: viewModel)
    }

    func render(in content: VerticalLayoutItemView, coordinator: Void) {
        content.viewModel = viewModel
    }
}

final class VerticalLayoutItemView: UIView {
    private enum Layout {
        static let horizontalInset: CGFloat = 0
        static let verticalInset: CGFloat = 8
        static let spacing: CGFloat = 4
    }

    struct ViewModel: Equatable {
        let id: UUID
        var title: String?
        var subtitle: String?

        init(
            id: UUID = .init(),
            title: String? = nil,
            subtitle: String? = nil
        ) {
            self.id = id
            self.title = title
            self.subtitle = subtitle
        }

        static func random() -> Self {
            .init(
                title: String.randomWords(count: .random(in: 4...10), wordLength: 4...10),
                subtitle: Bool.random()
                    ? String.randomWords(count: .random(in: 4...10), wordLength: 4...10)
                    : nil
            )
        }
    }

    var viewModel: ViewModel {
        didSet {
            guard viewModel != oldValue else { return }
            applyViewModel()
        }
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .label
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        return label
    }()

    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        defineLayout()
        applyViewModel()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    private func defineLayout() {
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(separator)
    }

    private func applyViewModel() {
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        titleLabel.isHidden = viewModel.title == nil
        subtitleLabel.isHidden = viewModel.subtitle == nil
        setNeedsLayout()
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let contentWidth = max(size.width - (Layout.horizontalInset * 2), 0)
        var height = Layout.verticalInset * 2

        if titleLabel.isHidden == false {
            height += titleLabel.sizeThatFits(
                CGSize(width: contentWidth, height: .greatestFiniteMagnitude)
            ).height
        }

        if subtitleLabel.isHidden == false {
            if titleLabel.isHidden == false {
                height += Layout.spacing
            }

            height += subtitleLabel.sizeThatFits(
                CGSize(width: contentWidth, height: .greatestFiniteMagnitude)
            ).height
        }

        return CGSize(width: size.width, height: ceil(height))
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let contentWidth = max(bounds.width - (Layout.horizontalInset * 2), 0)
        var y = Layout.verticalInset

        if titleLabel.isHidden == false {
            let titleSize = titleLabel.sizeThatFits(
                CGSize(width: contentWidth, height: .greatestFiniteMagnitude)
            )
            titleLabel.frame = CGRect(
                x: Layout.horizontalInset,
                y: y,
                width: contentWidth,
                height: ceil(titleSize.height)
            )
            y = titleLabel.frame.maxY
        } else {
            titleLabel.frame = .zero
        }

        if subtitleLabel.isHidden == false {
            if titleLabel.isHidden == false {
                y += Layout.spacing
            }

            let subtitleSize = subtitleLabel.sizeThatFits(
                CGSize(width: contentWidth, height: .greatestFiniteMagnitude)
            )
            subtitleLabel.frame = CGRect(
                x: Layout.horizontalInset,
                y: y,
                width: contentWidth,
                height: ceil(subtitleSize.height)
            )
        } else {
            subtitleLabel.frame = .zero
        }

        separator.frame = CGRect(
            x: Layout.horizontalInset,
            y: bounds.height - (1.0 / traitCollection.displayScale),
            width: max(bounds.width - Layout.horizontalInset, 0),
            height: 1.0 / traitCollection.displayScale
        )
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            setNeedsLayout()
        }
    }
}

private extension String {
    static func randomWords(count: Int, wordLength: ClosedRange<Int>) -> String {
        (0..<count)
            .map { _ in String.randomWord(length: .random(in: wordLength)) }
            .joined(separator: " ")
    }

    static func randomWord(length: Int) -> String {
        let letters = Array("abcdefghijklmnopqrstuvwxyz")
        return String((0..<length).map { _ in letters.randomElement() ?? "a" })
    }
}
