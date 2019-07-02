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

public class SynchronizedArray<Element> {

    private let queue = DispatchQueue(label: "qa.quantum.SynchronizedSwift.SynchronizedArray", attributes: .concurrent)
    private let completionQueue = DispatchQueue(label: "qa.quantum.SynchronizedSwift.SynchronizedArray.completion", attributes: .concurrent)

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
        var capacity: Int!
        self.queue.sync { capacity = self.array.capacity}
        return capacity
    }

    // !!! Async but completion not possible for operators
    public static func + (lhs: SynchronizedArray, rhs: SynchronizedArray) -> SynchronizedArray {
        var result: SynchronizedArray!
        var rhsArray: [Element]!
        rhs.queue.sync { rhsArray = rhs.array }
        lhs.queue.sync { result = SynchronizedArray<Element>(lhs.array + rhsArray!) }
        return result
    }

    // !!! Async but completion not possible for operators
    public static func + (lhs: SynchronizedArray, rhs: [Element]) -> SynchronizedArray {
        var result: SynchronizedArray!
        lhs.queue.sync { result = SynchronizedArray<Element>(lhs.array + rhs) }
        return result
    }

    // !!! Async but completion not possible for operators
    public static func += (lhs: inout SynchronizedArray, rhs: SynchronizedArray) {
        var rhsArray: [Element] = []
        rhs.queue.sync { rhsArray = rhs.array }
        lhs.append(contentsOf: rhsArray)
    }

    // !!! Async but completion not possible for operators
    public static func += (lhs: inout SynchronizedArray, rhs: [Element]) {
        lhs.append(contentsOf: rhs)
    }

    // Needs to be defined with and without throws because rethrows is not possible in queue
    public func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<Element>) -> R) -> R {
        let function = withUnsafeBufferPointer as ((UnsafeBufferPointer<Element>) throws -> R) throws -> R
        return try! function(body)
    }

    public func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<Element>) throws -> R) throws -> R {
        var result: R!
        var queueError: Error?
        self.queue.sync {
            do {
                try result = self.array.withUnsafeBufferPointer(body)
            } catch let error {
                queueError = error
            }
        }
        if queueError != nil {
            throw queueError!
        }
        return result
    }

    // Needs to be defined with and without throws because rethrows is not possible in queue
    public func withUnsafeMutableBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<Element>) -> R) -> R {
        let function = withUnsafeMutableBufferPointer as ((inout UnsafeMutableBufferPointer<Element>) throws -> R) throws -> R
        return try! function(body)
    }

    public func withUnsafeMutableBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<Element>) throws -> R) throws -> R {
        var result: R!
        var queueError: Error?
        self.queue.sync {
            do {
                try result = self.array.withUnsafeMutableBufferPointer(body)
            } catch let error {
                queueError = error
            }
        }
        if queueError != nil {
            throw queueError!
        }
        return result
    }

    public func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: __owned C, completion: (() -> Void)? = nil) where Element == C.Element, C : Collection {
        self.queue.async(flags: .barrier) {
            self.array.replaceSubrange(subrange, with: newElements)
            self.completionQueue.async(flags: .barrier) { completion?() }
        }
    }

    // Needs to be defined with and without throws because rethrows is not possible in queue
    public func withUnsafeMutableBytes<R>(_ body: (UnsafeMutableRawBufferPointer) -> R) -> R {
        let function = withUnsafeMutableBytes as ((UnsafeMutableRawBufferPointer) throws -> R) throws -> R
        return try! function(body)
    }

    public func withUnsafeMutableBytes<R>(_ body: (UnsafeMutableRawBufferPointer) throws -> R) throws -> R {
        var result: R!
        var queueError: Error?
        self.queue.sync {
            do {
                try result = self.array.withUnsafeMutableBytes(body)
            } catch let error {
                queueError = error
            }
        }
        if queueError != nil {
            throw queueError!
        }
        return result
    }

    // Needs to be defined with and without throws because rethrows is not possible in queue
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) -> R) -> R {
        let function = withUnsafeBytes as ((UnsafeRawBufferPointer) throws -> R) throws -> R
        return try! function(body)
    }

    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) throws -> R {
        var result: R!
        var queueError: Error?
        self.queue.sync {
            do {
                try result = self.array.withUnsafeBytes(body)
            } catch let error {
                queueError = error
            }
        }
        if queueError != nil {
            throw queueError!
        }
        return result
    }

    // TODO dropLast

    // TODO suffix

    // Needs to be defined with and without throws because rethrows is not possible in queue
    public func map<T>(_ transform: (Element)-> T) -> [T] {
        let function = map as ((Element) throws -> T) throws -> [T]
        return try! function(transform)
    }

    public func map<T>(_ transform: (Element) throws -> T) throws -> [T] {
        var result: [T]!
        var queueError: Error?
        self.queue.sync {
            do {
                try result = self.array.map(transform)
            } catch let error {
                queueError = error
            }
        }
        if queueError != nil {
            throw queueError!
        }
        return result
    }

    // TODO dropFirst

    // TODO drop

    // TODO prefix

    // TODO prefix

    // TODO prefix

    // TODO suffix

    // TODO prefix

    // TODO split

    public var last: Element? {
        var last: Element?
        self.queue.sync { last = self.array.last}
        return last
    }

    // Needs to be defined with and without throws because rethrows is not possible in queue
    public func firstIndex(where predicate: (Element) -> Bool) -> Int? {
        let function = firstIndex as ((Element) throws -> Bool) throws -> Int?
        return try! function(predicate)
    }

    public func firstIndex(where predicate: (Element) throws -> Bool) throws -> Int? {
        var result: Int?
        var queueError: Error?
        self.queue.sync {
            do {
                try result = self.array.firstIndex(where: predicate)
            } catch let error {
                queueError = error
            }
        }
        if queueError != nil {
            throw queueError!
        }
        return result
    }




    public func append(_ newElement: __owned Element, completion: (() -> Void)? = nil) {
        self.queue.async(flags: .barrier) {
            self.array.append(newElement)
            self.completionQueue.async(flags: .barrier) { completion?() }
        }
    }

    public func append<S>(contentsOf newElements: __owned S, completion: (() -> Void)? = nil) where Element == S.Element, S: Sequence {
        self.queue.async(flags: .barrier) {
            self.array.append(contentsOf: newElements)
            self.completionQueue.async(flags: .barrier) { completion?() }
        }
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
        var rhsArray: [Element]?
        rhs.queue.sync { rhsArray = rhs.array }
        lhs.queue.sync { result = lhs.array == rhsArray }
        return result
    }

}
