import UIKit

final class ExamplesViewController: UITableViewController {
    private enum Destination: String, CaseIterable {
        case demo
        case sample
        case sampleAutoLayout
        case autoLayoutSample
        case horizontalOnly
        case square
        case lightweightAdapter
        case compositionalAdapter
        case miniList

        var title: String {
            switch self {
            case .demo:
                return "DemoViewController"
            case .horizontalOnly:
                return "HorizontalOnlyViewController"
            case .square:
                return "SquareViewController"
            case .sample:
                return "SampleViewController"
            case .sampleAutoLayout:
                return "SampleAutoLayoutViewController"
            case .autoLayoutSample:
                return "AutoLayoutSampleViewController"
            case .lightweightAdapter:
                return "LightweightAdapterViewController"
            case .compositionalAdapter:
                return "LightweightCompositionalAdapterViewController"
            case .miniList:
                return "MiniListViewController"
            }
        }

        var subtitle: String {
            switch self {
            case .demo:
                return "TurboListKit 데모 화면"
            case .horizontalOnly:
                return "가로 스크롤 레이아웃만 모아둔 예제"
            case .square:
                return "정사각형 셀만 모아둔 예제"
            case .sample:
                return "새 화면 작업용 기본 틀"
            case .sampleAutoLayout:
                return "SampleViewController를 오토레이아웃 컴포넌트로 옮긴 버전"
            case .autoLayoutSample:
                return "컴포넌트 내부를 오토레이아웃으로 구성한 예제"
            case .lightweightAdapter:
                return "TurboListKit import 없이 초경량 CollectionAdapter를 직접 만드는 예제"
            case .compositionalAdapter:
                return "CompositionalLayout 기반 초경량 어댑터 예제"
            case .miniList:
                return "MiniList -> MiniSection -> MiniCell 구조로 List가 왜 필요한지 보여주는 예제"
            }
        }

        func makeViewController() -> UIViewController {
            switch self {
            case .demo:
                return DemoViewController()
            case .horizontalOnly:
                return HorizontalOnlyViewController()
            case .square:
                return SquareViewController()
            case .sample:
                return SampleViewController()
            case .sampleAutoLayout:
                return SampleAutoLayoutViewController()
            case .autoLayoutSample:
                return AutoLayoutSampleViewController()
            case .lightweightAdapter:
                return LightweightAdapterViewController()
            case .compositionalAdapter:
                return LightweightCompositionalAdapterViewController()
            case .miniList:
                return MiniListViewController()
            }
        }
    }

    init() {
        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Demo App"
        navigationItem.largeTitleDisplayMode = .always
        tableView.backgroundColor = .systemGroupedBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = 72
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Destination.allCases.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let destination = Destination.allCases[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = destination.title
        content.secondaryText = destination.subtitle
        content.secondaryTextProperties.color = .secondaryLabel

        cell.accessoryType = .disclosureIndicator
        cell.contentConfiguration = content
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let destination = Destination.allCases[indexPath.row]
        navigationController?.pushViewController(destination.makeViewController(), animated: true)
    }
}
