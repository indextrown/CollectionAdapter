//
//  File.swift
//  CollectionAdapter
//
//  Created by 김동현 on 4/22/26.
//

import Foundation

extension Equatable {
    
    /// 두 `Equatable` 값을 타입을 고려하여 비교합니다.
    ///
    /// - Parameter other: 비교할 대상 (타입이 지워진 `any Equatable`)
    /// - Returns: 같은 타입이고 값이 같으면 `true`, 아니면 `false`
    ///
    /// ## 동작 방식
    /// 1. `other`를 현재 타입(`Self`)으로 캐스팅 시도
    /// 2. 성공하면 `==`로 비교
    /// 3. 실패하면 반대로 `other` 쪽에서 다시 비교 시도
    /// 4. 그래도 실패하면 `false`
    ///
    /// ## 왜 반대로 비교하나?
    /// - 일부 타입은 **한 방향 캐스팅만 가능한 경우**가 존재합니다.
    ///
    /// ### 예시 (브릿징 케이스)
    /// ```swift
    /// let a: any Equatable = 10                  // Int
    /// let b: any Equatable = NSNumber(value: 10)
    ///
    /// // 1차 시도 (self 기준)
    /// b as? Int  // ❌ 실패
    ///
    /// // 2차 시도 (other 기준)
    /// a as? NSNumber  // ✅ 성공 (브릿징)
    ///
    /// // 결과: true
    /// ```
    ///
    /// 즉,
    /// - A → B 캐스팅은 실패할 수 있지만
    /// - B → A 캐스팅은 성공할 수 있음
    ///
    /// 따라서 양쪽 방향 모두 시도해야 정확한 비교가 가능함
    ///
    /// ## 사용 이유
    /// - `any Equatable`처럼 타입이 지워진 상태에서도 비교하기 위해 사용
    /// - Swift 기본 `==`는 서로 다른 타입 간 비교를 허용하지 않음
    ///
    /// ## Example
    /// ```swift
    /// let a: any Equatable = 10
    /// let b: any Equatable = 10
    /// a.isEqual(b) // true
    /// ```
    func isEqual(_ other: any Equatable) -> Bool {
        guard let other = other as? Self else {
            // 일부 타입(Int ↔ NSNumber 등)은 한쪽 방향 캐스팅만 가능하므로 반대로도 시도
            return other.isExactlyEqual(self)
        }
        return self == other
    }
    
    /// `isEqual` 내부에서 사용되는 보조 비교 메서드입니다.
    ///
    /// - Parameter other: 비교 대상
    /// - Returns: 같은 타입으로 캐스팅 가능하고 값이 같으면 `true`
    ///
    /// ## 설명
    /// - 타입이 다르면 바로 `false`
    /// - 타입이 같으면 `==`로 비교
    private func isExactlyEqual(_ other: any Equatable) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self == other
    }
}
