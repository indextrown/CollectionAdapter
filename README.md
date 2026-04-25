# CollectionAdapter

`CollectionAdapter`는 `UICollectionView`를 `Component -> Cell -> Section -> List` 구조로 선언형에 가깝게 구성할 수 있게 도와주는 UIKit 리스트 어댑터입니다.

DifferenceKit 기반 diff 업데이트, compositional layout 연결, 이벤트 modifier, prefetching plugin 구성을 한 곳에 묶어 `UICollectionView` 보일러플레이트를 줄이는 것이 목적입니다.

## 목차

- [목적](#목적)
- [사용법](#사용법)
- [핵심 타입](#핵심-타입)
- [기능](#기능)
- [전체 파이프라인](#전체-파이프라인)
- [동작 파이프라인](#동작-파이프라인)

## 목적

- `UICollectionViewDataSource`, `UICollectionViewDelegate`, 셀 등록, diff 계산, 이벤트 라우팅을 adapter 내부로 캡슐화합니다.
- `List`, `Section`, `Cell`, `Component` 조합으로 화면 구조를 데이터처럼 표현합니다.
- 섹션 단위 compositional layout을 붙여 세로 리스트, 가로 리스트, 그리드 같은 레이아웃을 섞어 구성할 수 있게 합니다.
- `didSelect`, `onRefresh`, `onReachEnd` 같은 이벤트를 modifier 스타일로 선언할 수 있게 합니다.
- 필요 시 prefetching plugin을 연결해 리소스 로딩 성능을 보완할 수 있게 합니다.

## 사용법

### 1. Adapter 준비

```swift
import CollectionAdapter
import UIKit

private let layoutAdapter = CollectionViewLayoutAdapter()

private lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewCompositionalLayout { [weak self] index, environment in
        self?.layoutAdapter.sectionLayout(index: index, enviroment: environment)
    }

    return UICollectionView(frame: .zero, collectionViewLayout: layout)
}()

private lazy var adapter = CollectionViewAdapter(
    configuration: .init(
        refreshControl: .enabled(tintColor: .systemBlue)
    ),
    collectionView: collectionView,
    layoutAdapter: layoutAdapter
)
```

### 2. List 구성

```swift
let list = List {
    Section(id: "feed") {
        for item in items {
            Cell(
                id: item.id,
                component: FeedItemComponent(viewModel: item)
            )
            .didSelect { context in
                print("selected:", context.id)
            }
        }
    }
    .withHeader(FeedHeaderComponent(title: "Feed"))
    .withSectionLayout(
        DefaultCompositionalLayoutSectionFactory.vertical(spacing: 12)
            .withSectionContentInsets(.init(top: 16, leading: 20, bottom: 16, trailing: 20))
    )
}
.onRefresh { [weak self] _ in
    self?.reloadItems()
}
.onReachEnd(offsetFromEnd: .relativeToContainerSize(multiplier: 1.0)) { [weak self] _ in
    self?.loadNextPage()
}
```

### 3. 화면 반영

```swift
adapter.apply(
    list,
    updateStrategy: .animatedBatchUpdates
)
```

### 4. 상태 변경 후 다시 apply

```swift
func render() {
    adapter.apply(makeList())
}
```

`CollectionAdapter`는 상태를 직접 보관하지 않으므로, 데이터가 바뀌면 새 `List`를 다시 만들어 `apply(...)`하는 방식으로 갱신합니다.

## 핵심 타입

| 타입 | 역할 | 주로 언제 쓰는가 |
| --- | --- | --- |
| `Component` | 셀/보조뷰를 그리는 최소 단위 | 실제 UI와 view model을 묶을 때 |
| `AnyComponent` | `Component` 타입 소거 래퍼 | 내부 저장 및 diff 비교 시 |
| `IdentifiableComponent` | `id`를 가진 `Component` | `Cell(component:)` 형태로 간단히 만들 때 |
| `Cell` | 컬렉션 뷰 셀 모델 | 아이템 단위 UI를 선언할 때 |
| `Section` | 셀 배열 + header/footer + layout 모델 | 섹션 단위 구성과 레이아웃을 묶을 때 |
| `SupplementaryView` | header/footer 표현 모델 | 섹션 보조 뷰를 붙일 때 |
| `List` | 화면 전체 리스트 모델 | 여러 섹션과 리스트 이벤트를 묶을 때 |
| `CollectionViewAdapter` | `UICollectionView`와 `List`를 연결하는 핵심 어댑터 | 실제 화면에 리스트를 반영할 때 |
| `CollectionViewAdapterConfiguration` | adapter 동작 옵션 | refresh, batch update, reconfigure 옵션을 설정할 때 |
| `CollectionViewAdapterUpdateStrategy` | 업데이트 방식 enum | animated batch, non-animated batch, reloadData를 고를 때 |
| `CollectionViewLayoutAdapter` | compositional layout과 section 데이터를 연결 | `UICollectionViewCompositionalLayout`의 section provider를 붙일 때 |
| `CompositionalLayoutSectionFactory` | 섹션 레이아웃 생성 프로토콜 | 커스텀 `NSCollectionLayoutSection`을 만들 때 |
| `DefaultCompositionalLayoutSectionFactory` | 기본 제공 레이아웃 팩토리 | 빠르게 vertical/horizontal/grid 레이아웃을 붙일 때 |
| `VerticalLayout` | 세로 리스트 레이아웃 팩토리 | 일반 피드/리스트 섹션 구성 시 |
| `HorizontalLayout` | 가로 스크롤 레이아웃 팩토리 | 카드 캐러셀 구성 시 |
| `VerticalGridLayout` | 그리드 레이아웃 팩토리 | 2열 이상 그리드 구성 시 |
| `CollectionViewPrefetchingPlugin` | prefetch 확장 포인트 | 이미지 등 리소스 prefetch를 붙일 때 |
| `ComponentRemoteImagePrefetchable` | 원격 이미지 prefetch 대상 프로토콜 | 컴포넌트가 미리 받아둘 URL을 제공할 때 |

## 기능

### Modifier / Event 기능

| 대상 | API | 설명 |
| --- | --- | --- |
| `List` | `didScroll` | 스크롤 중 이벤트를 받습니다. |
| `List` | `onRefresh` | pull-to-refresh 이벤트를 받습니다. |
| `List` | `onReachEnd` | 리스트 끝 근처 도달 시 추가 로딩 이벤트를 받습니다. |
| `List` | `willBeginDragging` | 드래그 시작 직전 이벤트를 받습니다. |
| `List` | `willEndDragging` | 드래그 종료 직전 이벤트를 받습니다. |
| `List` | `didEndDragging` | 드래그 종료 이벤트를 받습니다. |
| `List` | `didScrollToTop` | 맨 위로 이동했을 때 이벤트를 받습니다. |
| `List` | `willBeginDecelerating` | 감속 시작 이벤트를 받습니다. |
| `List` | `didEndDecelerating` | 감속 종료 이벤트를 받습니다. |
| `List` | `shouldScrollToTop` | 탭 시 상단 이동 허용 여부를 제어합니다. |
| `Section` | `withSectionLayout` | 섹션 레이아웃을 지정합니다. |
| `Section` | `withHeader` | 섹션 헤더를 붙입니다. |
| `Section` | `withFooter` | 섹션 푸터를 붙입니다. |
| `Section` | `willDisplayHeader` | 헤더 표시 직전 이벤트를 받습니다. |
| `Section` | `willDisplayFooter` | 푸터 표시 직전 이벤트를 받습니다. |
| `Section` | `didEndDisplayHeader` | 헤더 제거 이벤트를 받습니다. |
| `Section` | `didEndDisplayFooter` | 푸터 제거 이벤트를 받습니다. |
| `Cell` | `didSelect` | 셀 선택 이벤트를 받습니다. |
| `Cell` | `willDisplay` | 셀 표시 직전 이벤트를 받습니다. |
| `Cell` | `didEndDisplay` | 셀 제거 이벤트를 받습니다. |
| `Cell` | `onHighlight` | 셀 눌림 상태 이벤트를 받습니다. |
| `Cell` | `onUnhighlight` | 셀 눌림 해제 이벤트를 받습니다. |
| `SupplementaryView` | `willDisplay` | 보조 뷰 표시 직전 이벤트를 받습니다. |
| `SupplementaryView` | `didEndDisplaying` | 보조 뷰 제거 이벤트를 받습니다. |

### Adapter / Update 기능

| 기능 | API | 설명 |
| --- | --- | --- |
| 데이터 반영 | `apply(_:updateStrategy:completion:)` | 새 `List`를 `UICollectionView`에 반영합니다. |
| 현재 상태 조회 | `snapshot()` | 현재 adapter가 보유한 `List` 스냅샷을 반환합니다. |
| animated diff update | `.animatedBatchUpdates` | DifferenceKit 기반 애니메이션 갱신을 수행합니다. |
| non-animated diff update | `.nonanimatedBatchUpdates` | 애니메이션 없이 변경분만 갱신합니다. |
| full reload | `.reloadData` | 전체 `reloadData()`를 수행합니다. |
| refresh control | `CollectionViewAdapterConfiguration.RefreshControl` | 시스템 `UIRefreshControl` 연결 여부와 tint를 설정합니다. |
| queued update | adapter 내부 큐 | 업데이트 중 들어온 새 요청을 마지막 요청 기준으로 이어서 처리합니다. |
| reconfigure items | `enablesReconfigureItems` | 가능하면 셀 재생성 대신 reconfigure 경로를 사용합니다. |
| prefetching plugin | `CollectionViewPrefetchingPlugin` | prefetch lifecycle을 확장합니다. |

## 전체 파이프라인

```mermaid
flowchart LR
    A[ViewController or UIView] --> B[State or ViewModel]
    B --> C[Component]
    C --> D[Cell]
    D --> E[Section]
    E --> F[List]
    F --> G[CollectionViewAdapter.apply]
    G --> H[DifferenceKit]
    G --> I[CollectionViewLayoutAdapter]
    I --> J[Compositional Layout]
    H --> K[UICollectionView]
    J --> K
    K --> L[Cell / Header / Footer Rendering]
```

## 동작 파이프라인

```mermaid
flowchart TD
    A[User Action or State Change] --> B{어떤 경로인가}
    B -->|Initial render| C[make List]
    B -->|Data changed| C
    B -->|Pull to refresh| D[onRefresh handler]
    B -->|Reach end| E[onReachEnd handler]
    D --> F[update state]
    E --> F
    F --> C
    C --> G[adapter.apply]
    G --> H[register reuse identifiers]
    G --> I[diff or reload]
    I --> J[UICollectionView update]
    J --> K[event callbacks]
    J --> L[visible UI updated]
```
