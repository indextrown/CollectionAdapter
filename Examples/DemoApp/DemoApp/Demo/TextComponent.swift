//
//  TextComponent.swift
//  DemoApp
//
//  Created by 김동현 on 4/25/26.
//

import CollectionAdapter
import UIKit

struct TextComponent: Component {
    //    typealias Content = UILabel
    //    typealias Coordinator = Void

    struct ViewModel: Equatable {
        let title: String
    }

    let viewModel: ViewModel

    var layoutMode: ContentLayoutMode {
        .flexibleHeight(estimatedHeight: 44)
    }

    func renderContent(coordinator: Void) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        label.backgroundColor = .secondarySystemBackground
        return label
    }

    func render(in content: UILabel, coordinator: Void) {
        content.text = viewModel.title
    }
}
