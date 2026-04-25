import CollectionAdapter
import UIKit

final class VerticalLayoutListView: UIView {
    private enum Const {
        static let pageSize = 100
        static let maximumViewModelCount = 10000
    }

    private let layoutAdapter = CollectionViewLayoutAdapter()
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(layoutAdapter: layoutAdapter)
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()

    private lazy var collectionViewAdapter = CollectionViewAdapter(
        configuration: CollectionViewAdapterConfiguration(
            refreshControl: .enabled(
                tintColor: .systemGray,
                text: "새로고침 중...",
                textColor: .white
            )
        ),
        collectionView: collectionView,
        layoutAdapter: layoutAdapter
    )
    
//    private lazy var collectionViewAdapter = CollectionViewAdapter(
//        configuration: CollectionViewAdapterConfiguration(),
//        collectionView: collectionView,
//        layoutAdapter: layoutAdapter
//    )

    private var viewModels: [VerticalLayoutItemComponent.ViewModel] = [] {
        didSet {
            guard viewModels != oldValue else { return }
            applyViewModels()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        defineLayout()
        resetViewModels()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    private func defineLayout() {
        addSubview(collectionView)
    }

    private func resetViewModels() {
        viewModels = (0..<Const.pageSize).map { _ in .random() }
    }

    private func appendViewModels() {
        guard viewModels.count < Const.maximumViewModelCount else { return }
        let remainingCount = Const.maximumViewModelCount - viewModels.count
        let nextCount = min(Const.pageSize, remainingCount)
        guard nextCount > 0 else { return }
        viewModels.append(contentsOf: (0..<nextCount).map { _ in .random() })
    }

    private func applyViewModels() {
        collectionViewAdapter.apply(
            List {
                Section(id: "Section") {
                    for viewModel in viewModels {
                        Cell(
                            id: viewModel.id,
                            component: VerticalLayoutItemComponent(viewModel: viewModel)
                        )
                        .willDisplay { context in
                            let model = context.anyComponent.base.viewModel as! VerticalLayoutItemView.ViewModel
                            print("표시직전: \(model.title!)")
                        }
                        .didEndDisplay { context in
                            let model = context.anyComponent.base.viewModel as! VerticalLayoutItemView.ViewModel
                            print("사라짐:  \(model.title!)")
                        }
                        .onHighlight { context in
                            let model = context.anyComponent.base.viewModel as! VerticalLayoutItemView.ViewModel
                            print("눌림:  \(model.title!)")
                        }
                        .onUnhighlight { context in
                            let model = context.anyComponent.base.viewModel as! VerticalLayoutItemView.ViewModel
                            print("눌림취소:  \(model.title!)")
                        }
                    }
                }
                .withHeader(SectionHeaderComponent(viewModel: .init(title: "헤더 타이틀", subtitle: "헤더 서브 타이틀")))
                .withSectionLayout(
                    DefaultCompositionalLayoutSectionFactory.vertical(spacing: 0)
                        .withSectionContentInsets(.init(top: 16, leading: 20, bottom: 8, trailing: 20))
                        .withHeaderPinToVisibleBounds(true)
                )
                // .withSectionLayout(.vertical)
            }
            .onRefresh { [weak self] _ in
                self?.resetViewModels()
            }
            .onReachEnd(offsetFromEnd: .relativeToContainerSize(multiplier: 1.0)) { [weak self] _ in
                self?.appendViewModels()
            }
            .didEndDecelerating { _ in
                print("스크롤 감속 종료")
            }
//            .didScrollToTop { _ in
//                print("스크롤 최상단 이동됨")
//            }
        )
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
    }
}

#Preview {
    VerticalLayoutListView()
}
