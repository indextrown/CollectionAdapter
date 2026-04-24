//
//  File.swift
//  CollectionAdapter
//
//  Created by 김동현 on 4/22/26.
//

import Foundation
import CoreGraphics

/// 컴포넌트의 사이즈를 저장하는 기능을 정의하는 프로토콜입니다.
public protocol ComponentSizeStorage {
    
    /// CGSize와 AnyViewModel을 함께 담는 튜플 타입
    typealias SizeContext = (size: CGSize, viewModel: AnyViewModel)
    
    /// 셀의 크기를 조회합니다.
    /// - Parameter hash: 셀의 해시 값
    /// - Returns: 해당 셀의 크기 정보 (SizeContext)
    func cellSize(for hash: AnyHashable) -> SizeContext?
    
    /// 헤더의 크기를 조회합니다.
    /// - Parameter hash: 헤더의 해시 값
    /// - Returns: 해당 헤더의 크기 정보 (SizeContext)
    func headerSize(for hash: AnyHashable) -> SizeContext?
    
    /// 푸터의 크기를 조회합니다.
    /// - Parameter hash: 푸터의 해시 값
    /// - Returns: 해당 푸터의 크기 정보 (SizeContext)
    func footerSize(for hash: AnyHashable) -> SizeContext?
    
    /// 셀의 크기를 저장합니다.
    /// - Parameters:
    ///   - size: 저장할 크기 정보 (SizeContext)
    ///   - hash: 셀의 해시 값
    func setCellSize(_ size: SizeContext, for hash: AnyHashable)
    
    /// 헤더의 크기를 저장합니다.
    /// - Parameters:
    ///   - size: 저장할 크기 정보 (SizeContext)
    ///   - hash: 헤더의 해시 값
    func setHeaderSize(_ size: SizeContext, for hash: AnyHashable)
    
    /// 푸터의 크기를 저장합니다.
    /// - Parameters:
    ///   - size: 저장할 크기 정보 (SizeContext)
    ///   - hash: 푸터의 해시 값
    func setFooterSize(_ size: SizeContext, for hash: AnyHashable)
}

/// ComponentSizeStorage의 실제 구현체
final class ComponentSizeStorageImpl: ComponentSizeStorage {
    
    /// 셀 크기를 저장하는 딕셔너리
    var cellSizeStore: [AnyHashable: SizeContext] = [:]
    
    /// 헤더 크기를 저장하는 딕셔너리
    var headerSizeStore: [AnyHashable: SizeContext] = [:]
    
    /// 푸터 크기를 저장하는 딕셔너리
    var footerSizeStore: [AnyHashable: SizeContext] = [:]
    
    /// 셀 크기 조회
    func cellSize(for hash: AnyHashable) -> SizeContext? {
        cellSizeStore[hash]
    }
    
    /// 헤더 크기 조회
    func headerSize(for hash: AnyHashable) -> SizeContext? {
        headerSizeStore[hash]
    }
    
    /// 푸터 크기 조회
    func footerSize(for hash: AnyHashable) -> SizeContext? {
        footerSizeStore[hash]
    }
    
    /// 셀 크기 저장
    func setCellSize(_ size: SizeContext, for hash: AnyHashable) {
        cellSizeStore[hash] = size
    }
    
    /// 헤더 크기 저장
    func setHeaderSize(_ size: SizeContext, for hash: AnyHashable) {
        headerSizeStore[hash] = size
    }
    
    /// 푸터 크기 저장
    func setFooterSize(_ size: SizeContext, for hash: AnyHashable) {
        footerSizeStore[hash] = size
    }
}
