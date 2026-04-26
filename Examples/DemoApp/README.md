# DemoApp

`DemoApp`은 `TurboListKit`을 실제 화면에서 확인하기 위한 예제 앱입니다.

앱 시작 화면은 [ExamplesViewController.swift](/Users/kimdonghyeon/2025/개발/라이브러리/TurboListKit/Examples/DemoApp/DemoApp/ExamplesViewController.swift:1)이며, 여기서 각 `UIViewController` 예제로 이동합니다.

## 화면 구성

### `DemoViewController`

파일: [DemoViewController.swift](/Users/kimdonghyeon/2025/개발/라이브러리/TurboListKit/Examples/DemoApp/DemoApp/0.%20Demo/DemoViewController.swift:1)

라이브러리 기능을 한 화면에서 종합적으로 보여주는 데모입니다.

포함된 기능:

- `Component -> Cell -> Section -> List -> CollectionViewAdapter` 흐름
- 세로 리스트, 가로 카드, 그리드 섹션
- section header / footer
- `didSelect` 이벤트 처리
- `pull-to-refresh`
- `onReachEnd` 기반 추가 로딩
- diff 기반 화면 갱신

이럴 때 참고하면 좋습니다:

- 여러 섹션을 한 번에 구성하고 싶을 때
- 레이아웃을 섹션별로 다르게 주고 싶을 때
- 선택 이벤트나 로딩 이벤트를 같이 붙이고 싶을 때
- 데모용 쇼케이스 화면이 필요할 때

기본 패턴:

```swift
private let layoutAdapter = CollectionViewLayoutAdapter()

private lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewCompositionalLayout { [weak self] index, environment in
        self?.layoutAdapter.sectionLayout(index: index, enviroment: environment)
    }

    return UICollectionView(frame: .zero, collectionViewLayout: layout)
}()

private lazy var adapter = CollectionViewAdapter(
    configuration: .init(refreshControl: .enabled(tintColor: .systemBlue)),
    collectionView: collectionView,
    layoutAdapter: layoutAdapter
)

adapter.apply(
    List {
        // Section...
    }
)
```

### `SampleViewController`

파일: [SampleViewController.swift](/Users/kimdonghyeon/2025/개발/라이브러리/TurboListKit/Examples/DemoApp/DemoApp/1.%20Sample/SampleViewController.swift:1)

최소한의 세로 리스트 예제입니다. 참고용 샘플 코드를 이 프로젝트 스타일에 맞게 다시 옮긴 화면입니다.

포함된 기능:

- 단일 세로 섹션
- 자동 높이 셀
- 랜덤 더미 데이터
- `pull-to-refresh` 시 전체 재생성
- `onReachEnd` 시 페이지 단위 append
- `FlexLayout`, `PinLayout`, 매크로 없이 UIKit 오토레이아웃만 사용

관련 파일:

- [VerticalLayoutListView.swift](/Users/kimdonghyeon/2025/개발/라이브러리/TurboListKit/Examples/DemoApp/DemoApp/1.%20Sample/VerticalLayoutListView.swift:1)
- [VerticalLayoutItemComponent.swift](/Users/kimdonghyeon/2025/개발/라이브러리/TurboListKit/Examples/DemoApp/DemoApp/1.%20Sample/VerticalLayoutItemComponent.swift:1)

이럴 때 참고하면 좋습니다:

- 가장 단순한 `TurboListKit` 도입 예제가 필요할 때
- 셀 높이를 내용에 따라 자동 계산하고 싶을 때
- `UIViewController` 안에 리스트 하나만 빠르게 붙이고 싶을 때
- 무한 스크롤과 새로고침을 작은 예제로 보고 싶을 때

기본 패턴:

```swift
collectionViewAdapter.apply(
    List {
        Section(id: "vertical-layout-sample") {
            for viewModel in viewModels {
                Cell(
                    id: viewModel.id,
                    component: VerticalLayoutItemComponent(viewModel: viewModel)
                )
            }
        }
        .withSectionLayout(
            DefaultCompositionalLayoutSectionFactory.vertical(spacing: 0)
        )
    }
    .onRefresh { [weak self] _ in
        self?.resetViewModels()
    }
    .onReachEnd(offsetFromEnd: .relativeToContainerSize(multiplier: 1.0)) { [weak self] _ in
        self?.appendViewModels()
    }
)
```

### `SampleAutoLayoutViewController`

파일: [SampleAutoLayoutViewController.swift](/Users/kimdonghyeon/2025/개발/라이브러리/TurboListKit/Examples/DemoApp/DemoApp/2.%20SampleAutoLayout/SampleAutoLayoutViewController.swift:1)

`SampleViewController`와 같은 화면 구성을 오토레이아웃 기반 아이템 컴포넌트로 옮긴 버전입니다.

관련 파일:

- [SampleAutoLayoutItemComponent.swift](/Users/kimdonghyeon/2025/개발/라이브러리/TurboListKit/Examples/DemoApp/DemoApp/2.%20SampleAutoLayout/SampleAutoLayoutItemComponent.swift:1)

이럴 때 참고하면 좋습니다:

- 기존 세로 리스트 예제를 오토레이아웃 방식으로 그대로 바꿔보고 싶을 때
- 수동 `layoutSubviews` 없이 `UIStackView`와 제약만으로 셀 높이를 계산하고 싶을 때
- 같은 화면을 수동 레이아웃 버전과 오토레이아웃 버전으로 비교하고 싶을 때

### `AutoLayoutSampleViewController`

파일: [AutoLayoutSampleViewController.swift](/Users/kimdonghyeon/2025/개발/라이브러리/TurboListKit/Examples/DemoApp/DemoApp/3.%20AutoLayoutSample/AutoLayoutSampleViewController.swift:1)

컴포넌트 내부 뷰를 오토레이아웃만으로 구성한 예제입니다. 셀 내부는 `UIStackView`와 `NSLayoutConstraint`만 사용하고, 높이 계산은 `systemLayoutSizeFitting` 기반 공통 헬퍼로 처리합니다.

관련 파일:

- [AutoLayoutMessageComponent.swift](/Users/kimdonghyeon/2025/개발/라이브러리/TurboListKit/Examples/DemoApp/DemoApp/3.%20AutoLayoutSample/AutoLayoutMessageComponent.swift:1)
- [UIView+AutoLayoutFittingSize.swift](/Users/kimdonghyeon/2025/개발/라이브러리/TurboListKit/Examples/DemoApp/DemoApp/UIView+AutoLayoutFittingSize.swift:1)

이럴 때 참고하면 좋습니다:

- `layoutSubviews`로 직접 프레임을 계산하지 않고 컴포넌트를 만들고 싶을 때
- Dynamic Type 대응을 포함해 내용 길이에 따라 셀 높이를 자동으로 늘리고 싶을 때
- 기존 UIKit 오토레이아웃 패턴을 `TurboListKit` 컴포넌트에 그대로 옮기고 싶을 때
- 여러 오토레이아웃 컴포넌트에서 같은 `sizeThatFits` 계산 로직을 재사용하고 싶을 때

### `HorizontalOnlyViewController`

파일: [HorizontalOnlyViewController.swift](/Users/kimdonghyeon/2025/개발/라이브러리/TurboListKit/Examples/DemoApp/DemoApp/4.%20HorizontalOnly/HorizontalOnlyViewController.swift:1)

가로 스크롤 섹션만 따로 모아둔 예제입니다. 카드형 페이징 섹션과 태그형 연속 스크롤 섹션을 한 화면에서 확인할 수 있습니다.

관련 파일:

- [HorizontalFeatureCardComponent.swift](/Users/kimdonghyeon/2025/개발/라이브러리/TurboListKit/Examples/DemoApp/DemoApp/4.%20HorizontalOnly/Components/HorizontalFeatureCardComponent.swift:1)
- [HorizontalTagComponent.swift](/Users/kimdonghyeon/2025/개발/라이브러리/TurboListKit/Examples/DemoApp/DemoApp/4.%20HorizontalOnly/Components/HorizontalTagComponent.swift:1)
- [HorizontalSectionHeaderComponent.swift](/Users/kimdonghyeon/2025/개발/라이브러리/TurboListKit/Examples/DemoApp/DemoApp/4.%20HorizontalOnly/Components/HorizontalSectionHeaderComponent.swift:1)

이럴 때 참고하면 좋습니다:

- `groupPagingCentered`와 `continuous`를 작은 예제로 분리해서 보고 싶을 때
- `fitContent` 가로 카드와 pill 태그가 각각 어떤 방식으로 크기를 계산하는지 보고 싶을 때
- reload 이후에도 가로 섹션이 안정적으로 유지되는지 테스트하고 싶을 때

### `LightweightAdapterViewController`

파일: [LightweightAdapterViewController.swift](/Users/kimdonghyeon/2025/개발/라이브러리/TurboListKit/Examples/DemoApp/DemoApp/6.%20LightweightAdapter/LightweightAdapterViewController.swift:1)

`TurboListKit`을 import 하지 않고도, `CollectionViewAdapter`의 핵심 아이디어만 남겨 직접 구현한 초경량 예제입니다.

관련 파일:

- [LightweightAnyComponent.swift](/Users/kimdonghyeon/2025/개발/라이브러리/TurboListKit/Examples/DemoApp/DemoApp/6.%20LightweightAdapter/LightweightAnyComponent.swift:1)
- [LightweightCollectionAdapter.swift](/Users/kimdonghyeon/2025/개발/라이브러리/TurboListKit/Examples/DemoApp/DemoApp/6.%20LightweightAdapter/LightweightCollectionAdapter.swift:1)

핵심 포인트:

- 어댑터는 `reuseIdentifier`와 `LightweightAnyComponent`만 알고 동작
- 셀 등록 책임은 각 컴포넌트가 직접 가짐
- 실제 셀 타입으로의 `guard let` 캐스팅은 타입 소거 박스 내부에서만 수행
- 그래서 어댑터는 `HeroCardCell`, `PillCell`, `NoteCell` 같은 구체 타입을 몰라도 됨

이럴 때 참고하면 좋습니다:

- 라이브러리 전체를 도입하기 전에 패턴만 작게 검증하고 싶을 때
- `UICollectionViewDataSource` 반복 코드를 줄이되 구조는 직접 통제하고 싶을 때
- 셀 등록과 셀 설정 책임을 어댑터 밖으로 분리하는 방법을 보고 싶을 때
- 타입 소거(`AnyComponent`)가 왜 필요한지 아주 작은 코드로 이해하고 싶을 때

### `LightweightCompositionalAdapterViewController`

파일: [LightweightCompositionalAdapterViewController.swift](/Users/kimdonghyeon/2025/개발/라이브러리/TurboListKit/Examples/DemoApp/DemoApp/7.%20CompositionalAdapter/LightweightCompositionalAdapterViewController.swift:1)

`6`번 예제의 경량 어댑터 아이디어를 유지하면서, 레이아웃만 `FlowLayout` 대신 `UICollectionViewCompositionalLayout`으로 바꾼 예제입니다.

관련 파일:

- [LightweightCompositionalSection.swift](/Users/kimdonghyeon/2025/개발/라이브러리/TurboListKit/Examples/DemoApp/DemoApp/7.%20CompositionalAdapter/LightweightCompositionalSection.swift:1)
- [LightweightCompositionalAdapter.swift](/Users/kimdonghyeon/2025/개발/라이브러리/TurboListKit/Examples/DemoApp/DemoApp/7.%20CompositionalAdapter/LightweightCompositionalAdapter.swift:1)

핵심 포인트:

- 아이템 타입 소거 방식은 그대로 유지
- 각 섹션이 `layoutProvider`를 가져 섹션별로 다른 `NSCollectionLayoutSection`을 생성
- 세로 카드 섹션과 가로 pill 섹션을 한 화면에서 동시에 구성 가능
- FlowLayout의 `sizeForItemAt` 중심 사고에서, 섹션 레이아웃 구성 중심 사고로 이동

이럴 때 참고하면 좋습니다:

- 섹션마다 완전히 다른 스크롤/배치 규칙을 주고 싶을 때
- 가로 연속 스크롤과 세로 카드 리스트를 한 화면에 섞고 싶을 때
- 경량 어댑터 패턴을 유지하면서 Compositional Layout까지 확장하는 방법을 보고 싶을 때

### `MiniListViewController`

파일: [MiniListViewController.swift](/Users/kimdonghyeon/2025/개발/라이브러리/TurboListKit/Examples/DemoApp/DemoApp/8.%20MiniList/MiniListViewController.swift:1)

`List -> Section -> Cell -> Component` 구조가 왜 생기는지 보여주는 예제입니다. `6`번과 `7`번보다 한 단계 더 올라가, 어댑터 입력을 `[AnyComponent]`나 `[Section]`이 아니라 `MiniList` 하나로 고정합니다.

관련 파일:

- [MiniListAnyComponent.swift](/Users/kimdonghyeon/2025/개발/라이브러리/TurboListKit/Examples/DemoApp/DemoApp/8.%20MiniList/MiniListAnyComponent.swift:1)
- [MiniListModels.swift](/Users/kimdonghyeon/2025/개발/라이브러리/TurboListKit/Examples/DemoApp/DemoApp/8.%20MiniList/MiniListModels.swift:1)
- [MiniListAdapter.swift](/Users/kimdonghyeon/2025/개발/라이브러리/TurboListKit/Examples/DemoApp/DemoApp/8.%20MiniList/MiniListAdapter.swift:1)

핵심 포인트:

- 루트 타입이 `MiniList` 하나로 고정됨
- 그 안에서 `MiniListSection`, `MiniListCell`, `MiniListAnyComponent` 계층이 생김
- 화면 전체 상태를 하나의 스냅샷으로 다루기 쉬워짐
- 추후 diff, 전역 이벤트, refresh 상태, 공통 옵션을 붙일 자리가 자연스럽게 생김

이럴 때 참고하면 좋습니다:

- 왜 단순 배열보다 `List` 루트가 장기적으로 유리한지 보고 싶을 때
- 선언형 DSL을 `화면 전체 상태` 단위로 확장하고 싶을 때
- 섹션과 셀이 커질수록 모델 계층이 왜 필요한지 이해하고 싶을 때

## 오토레이아웃 사이즈 헬퍼

[UIView+AutoLayoutFittingSize.swift](/Users/kimdonghyeon/2025/개발/라이브러리/TurboListKit/Examples/DemoApp/DemoApp/UIView+AutoLayoutFittingSize.swift:1)의 `autoLayoutFittingSize(for:)`는 오토레이아웃 기반 컴포넌트에서 공통으로 쓰는 `sizeThatFits` 헬퍼입니다.

이 함수는:

- 컬렉션뷰가 넘겨준 폭을 기준으로
- `systemLayoutSizeFitting(...)`을 호출해
- 오토레이아웃이 계산한 최소 높이를 `CGSize`로 반환합니다

예시:

```swift
override func sizeThatFits(_ size: CGSize) -> CGSize {
    autoLayoutFittingSize(for: size)
}
```

폭 상한이나 최소 높이가 필요할 때는 인자를 추가로 넘길 수 있습니다.

```swift
override func sizeThatFits(_ size: CGSize) -> CGSize {
    autoLayoutFittingSize(
        for: size,
        targetWidth: min(size.width, 240),
        minimumHeight: 140
    )
}
```

## 진입 방식

`DemoApp`은 UIKit `UINavigationController`가 전체 네비게이션을 담당하는 구조입니다.

- [ExamplesViewController.swift](/Users/kimdonghyeon/2025/개발/라이브러리/TurboListKit/Examples/DemoApp/DemoApp/ExamplesViewController.swift:1)에서 예제 목록 표시
- 선택한 항목은 `navigationController?.pushViewController(...)`로 이동
- 앱 시작 시 `UINavigationController(rootViewController: ExamplesViewController())`를 루트로 사용

예시:

```swift
navigationController?.pushViewController(SampleViewController(), animated: true)
```

## 새 ViewController 추가 순서

1. `Examples/DemoApp/DemoApp` 아래에 새 `UIViewController` 파일을 만듭니다.
2. 예제 성격에 맞는 번호 폴더를 만들고, 전용 `Component`와 `UIView`도 같은 폴더 또는 `Components` 하위에 둡니다.
3. [ExamplesViewController.swift](/Users/kimdonghyeon/2025/개발/라이브러리/TurboListKit/Examples/DemoApp/DemoApp/ExamplesViewController.swift:1)의 `Destination`에 항목을 추가합니다.
4. `makeViewController()` 또는 `didSelectRowAt`에서 해당 `UIViewController`를 연결합니다.

## 실행

```bash
xcodebuild -project 'Examples/DemoApp/DemoApp.xcodeproj' \
  -scheme 'DemoApp' \
  -destination 'generic/platform=iOS Simulator' build
```
