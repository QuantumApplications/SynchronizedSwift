//
//  SynchronizedArray.swift
//  SynchronizedSwift
//
//  Created by Christian Oberdörfer on 24.06.19.
//  Copyright © 2019 Christian Oberdörfer. All rights reserved.
//

import Foundation

public extension Collection {

    subscript(safe index: Index) -> Element? {
        return self.indices.contains(index) ? self[index] : nil
    }

}

fileprivate let synchronizedArrayQueue = DispatchQueue(label: "qa.quantum.SynchronizedSwift.SynchronizedArray", attributes: .concurrent)

public class SynchronizedArray<Element> {

    private let queue = DispatchQueue(label: "qa.quantum.SynchronizedSwift.SynchronizedArray", attributes: .concurrent)

    private var array: [Element] = [Element]()

    // MARK: - init

    public init() {
    }

    public convenience init(_ array: [Element]) {
        self.init()
        self.array = array
    }

    // MARK: - Array

    public var capacity: Int {
        var capacity = 0
        self.queue.sync { capacity = self.array.capacity}
        return capacity
    }

    public static func + (lhs: SynchronizedArray, rhs: SynchronizedArray) -> SynchronizedArray? {
        var result: SynchronizedArray?
        synchronizedArrayQueue.sync { result = SynchronizedArray<Element>(lhs.array + rhs.array) }
        return result
    }

    public static func += (lhs: inout SynchronizedArray, rhs: [Element]) {
        lhs.append(contentsOf: rhs)
    }




    public func append(_ newElement: __owned Element) {
        self.queue.async(flags: .barrier) { self.array.append(newElement) }
    }

    public func append<S>(contentsOf newElements: __owned S) where Element == S.Element, S: Sequence {
        synchronizedArrayQueue.async(flags: .barrier) { self.array.append(contentsOf: newElements) }
    }

    

    // MARK: - Helper

    subscript(index: Int) -> Element? {
        get {
            var result: Element?
            queue.sync { result = self.array[safe: index] }
            return result
        }

        set {
            guard let newValue = newValue else { return }

            self.queue.async(flags: .barrier) {
                self.array[index] = newValue
            }
        }
    }
}

// MARK: - Equatable element

public extension SynchronizedArray where Element: Equatable {

    func elementsEqual<OtherSequence>(_ other: OtherSequence) -> Bool where OtherSequence: Sequence, Element == OtherSequence.Element {
        var result = false
        self.queue.sync { result = self.array.elementsEqual(other) }
        return result
    }

}

// MARK: - Equatable

extension SynchronizedArray: Equatable where Element: Equatable {

    public static func == (lhs: SynchronizedArray<Element>, rhs: SynchronizedArray<Element>) -> Bool {
        var result = false
        synchronizedArrayQueue.sync { result = lhs.array == rhs.array }
        return result
    }

}
