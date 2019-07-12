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

/// An ordered, random-access collection.
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

    // Sync because reading
    public var capacity: Int {
        var capacity: Int!
        self.queue.sync { capacity = self.array.capacity}
        return capacity
    }

    // Sync because reading
    // Barrier because mutating
    public static func + (lhs: SynchronizedArray, rhs: SynchronizedArray) -> SynchronizedArray {
        var result: SynchronizedArray!
        var rhsArray: [Element]!
        rhs.queue.sync { rhsArray = rhs.array }
        lhs.queue.sync(flags: .barrier) { result = SynchronizedArray<Element>(lhs.array + rhsArray!) }
        return result
    }

    // Sync because reading
    // Barrier because mutating
    public static func + (lhs: SynchronizedArray, rhs: [Element]) -> SynchronizedArray {
        var result: SynchronizedArray!
        lhs.queue.sync(flags: .barrier) { result = SynchronizedArray<Element>(lhs.array + rhs) }
        return result
    }

    // Sync because reading
    // Barrier because mutating
    public static func += (lhs: inout SynchronizedArray, rhs: SynchronizedArray) {
        var rhsArray: [Element] = []
        rhs.queue.sync { rhsArray = rhs.array }
        lhs.queue.sync(flags: .barrier) {
            lhs.array += rhsArray
        }
    }

    // Sync because reading
    // Barrier because mutating
    public static func += (lhs: inout SynchronizedArray, rhs: [Element]) {
        lhs.queue.sync(flags: .barrier) {
            lhs.array += rhs
        }
    }

    // Needs to be defined with and without throws because rethrows is not possible in queue
    public func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<Element>) -> R) -> R {
        let function = withUnsafeBufferPointer as ((UnsafeBufferPointer<Element>) throws -> R) throws -> R
        return try! function(body)
    }

    // Sync because reading
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
    // Sync because reading
    // Barrier because mutating
    public func withUnsafeMutableBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<Element>) throws -> R) throws -> R {
        var result: R!
        var queueError: Error?
        self.queue.sync(flags: .barrier) {
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

    // Async because writing only
    // Barrier because mutating
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

    // Sync because reading
    // Barrier because mutating
    public func withUnsafeMutableBytes<R>(_ body: (UnsafeMutableRawBufferPointer) throws -> R) throws -> R {
        var result: R!
        var queueError: Error?
        self.queue.sync(flags: .barrier) {
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

    // Sync because reading
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
    public func map<T>(_ transform: (Element)-> T) -> SynchronizedArray<T> {
        let function = map as ((Element) throws -> T) throws -> SynchronizedArray<T>
        return try! function(transform)
    }

    // Sync because reading
    public func map<T>(_ transform: (Element) throws -> T) throws -> SynchronizedArray<T> {
        var result: SynchronizedArray<T>!
        var queueError: Error?
        self.queue.sync {
            do {
                try result = SynchronizedArray<T>(self.array.map(transform))
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

    // Sync because reading
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

    // Needs to be defined with and without throws because rethrows is not possible in queue
    public func last(where predicate: (Element) -> Bool) -> Element? {
        let function = last as ((Element) throws -> Bool) throws -> Element?
        return try! function(predicate)
    }

    // Sync because reading
    public func last(where predicate: (Element) throws -> Bool) throws -> Element? {
        var result: Element?
        var queueError: Error?
        self.queue.sync {
            do {
                try result = self.array.last(where: predicate)
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
    public func lastIndex(where predicate: (Element) -> Bool) -> Int? {
        let function = lastIndex as ((Element) throws -> Bool) throws -> Int?
        return try! function(predicate)
    }

    // Sync because reading
    public func lastIndex(where predicate: (Element) throws -> Bool) throws -> Int? {
        var result: Int?
        var queueError: Error?
        self.queue.sync {
            do {
                try result = self.array.lastIndex(where: predicate)
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
    public func partition(by belongsInSecondPartition: (Element) -> Bool) -> Int {
        let function = partition as ((Element) throws -> Bool) throws -> Int
        return try! function(belongsInSecondPartition)
    }

    // Sync because reading
    public func partition(by belongsInSecondPartition: (Element) throws -> Bool) throws -> Int {
        var result: Int!
        var queueError: Error?
        self.queue.sync {
            do {
                try result = self.array.partition(by: belongsInSecondPartition)
            } catch let error {
                queueError = error
            }
        }
        if queueError != nil {
            throw queueError!
        }
        return result
    }

    // Sync because reading
    public func shuffled<T>(using generator: inout T) -> SynchronizedArray where T : RandomNumberGenerator {
        var result: SynchronizedArray!
        self.queue.sync { result = SynchronizedArray(self.array.shuffled(using: &generator)) }
        return result
    }

    // Sync because reading
    public func shuffled() -> SynchronizedArray {
        var result: SynchronizedArray!
        self.queue.sync { result = SynchronizedArray(self.array.shuffled()) }
        return result
    }

    // Sync because reading
    // Barrier because mutating
    public func shuffle<T>(using generator: inout T) where T : RandomNumberGenerator {
        self.queue.sync(flags: .barrier) { self.array.shuffle(using: &generator) }
    }

    // Async because writing only
    // Barrier because mutating
    public func shuffle(completion: (() -> Void)? = nil) {
        self.queue.async(flags: .barrier) {
            self.array.shuffle()
            self.completionQueue.async(flags: .barrier) { completion?() }
        }
    }

    // TODO public var lazy: LazySequence<Array<Element>> { get }

    // Needs to be defined with and without throws because rethrows is not possible in queue
    @available(swift, deprecated: 4.1, renamed: "compactMap(_:)", message: "Please use compactMap(_:) for the case where closure returns an optional value")
    public func flatMap<ElementOfResult>(_ transform: (Element) -> ElementOfResult?) -> SynchronizedArray<ElementOfResult> {
        let function = flatMap as ((Element) throws -> ElementOfResult?) throws -> SynchronizedArray<ElementOfResult>
        return try! function(transform)
    }

    // Sync because reading
    @available(swift, deprecated: 4.1, renamed: "compactMap(_:)", message: "Please use compactMap(_:) for the case where closure returns an optional value")
    public func flatMap<ElementOfResult>(_ transform: (Element) throws -> ElementOfResult?) throws -> SynchronizedArray<ElementOfResult> {
        var result: SynchronizedArray<ElementOfResult>!
        var queueError: Error?
        self.queue.sync {
            do {
                try result = SynchronizedArray<ElementOfResult>(self.array.compactMap(transform))
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
    public func withContiguousMutableStorageIfAvailable<R>(_ body: (inout UnsafeMutableBufferPointer<Element>) -> R) -> R? {
        let function = withContiguousMutableStorageIfAvailable as ((inout UnsafeMutableBufferPointer<Element>) throws -> R) throws -> R?
        return try! function(body)
    }

    // Sync because reading
    // Barrier because mutating
    public func withContiguousMutableStorageIfAvailable<R>(_ body: (inout UnsafeMutableBufferPointer<Element>) throws -> R) throws -> R? {
        var result: R?
        var queueError: Error?
        self.queue.sync(flags: .barrier) {
            do {
                try result = self.array.withContiguousMutableStorageIfAvailable(body)
            } catch let error {
                queueError = error
            }
        }
        if queueError != nil {
            throw queueError!
        }
        return result
    }

    // TODO public subscript(bounds: Range<Int>) -> Slice<Array<Element>> {

    // Async because writing only
    // Barrier because mutating
    public func swapAt(_ i: Int, _ j: Int, completion: (() -> Void)? = nil) {
        self.queue.async(flags: .barrier) {
            self.array.swapAt(i, j)
            self.completionQueue.async(flags: .barrier) { completion?() }
        }
    }

    // Sync because reading
    public var indices: Range<Int> {
        var result: Range<Int>!
        self.queue.sync { result = self.array.indices }
        return result
    }

    // TODO public subscript<R>(r: R) -> ArraySlice<Element> where R : RangeExpression, Self.Index == R.Bound { get }

    // TODO public subscript(x: (UnboundedRange_) -> ()) -> ArraySlice<Element> { get }

    // TODO public subscript<R>(r: R) -> ArraySlice<Element> where R : RangeExpression, Self.Index == R.Bound

    // TODO public subscript(x: (UnboundedRange_) -> ()) -> ArraySlice<Element>

    public convenience init(repeating repeatedValue: Element, count: Int) {
        self.init()
        self.array = Array(repeating: repeatedValue, count: count)
    }

    public convenience init<S>(_ elements: S) where S : Sequence, Element == S.Element {
        self.init()
        self.array = Array(elements)
    }

    // Async because writing only
    // Barrier because mutating
    public func append(_ newElement: __owned Element, completion: (() -> Void)? = nil) {
        self.queue.async(flags: .barrier) {
            self.array.append(newElement)
            self.completionQueue.async(flags: .barrier) { completion?() }
        }
    }

    // Async because writing only
    // Barrier because mutating
    public func append(contentsOf newElements: SynchronizedArray, completion: (() -> Void)? = nil) {
        var newElementsArray: [Element] = []
        newElements.queue.sync { newElementsArray = newElements.array }
        self.queue.async(flags: .barrier) {
            self.array.append(contentsOf: newElementsArray)
            self.completionQueue.async(flags: .barrier) { completion?() }
        }
    }

    // Async because writing only
    // Barrier because mutating
    public func append<S>(contentsOf newElements: __owned S, completion: (() -> Void)? = nil) where S : Sequence, Element == S.Element {
        self.queue.async(flags: .barrier) {
            self.array.append(contentsOf: newElements)
            self.completionQueue.async(flags: .barrier) { completion?() }
        }
    }

    // Async because writing only
    // Barrier because mutating
    public func insert(_ newElement: __owned Element, at i: Int, completion: (() -> Void)? = nil) {
        self.queue.async(flags: .barrier) {
            self.array.insert(newElement, at: i)
            self.completionQueue.async(flags: .barrier) { completion?() }
        }
    }

    // Async because writing only
    // Barrier because mutating
    public func insert<C>(contentsOf newElements: __owned C, at i: Int, completion: (() -> Void)? = nil) where C : Collection, Element == C.Element {
        self.queue.async(flags: .barrier) {
            self.array.insert(contentsOf: newElements, at: i)
            self.completionQueue.async(flags: .barrier) { completion?() }
        }
    }

    // Sync because reading
    // Barrier because mutating
    public func remove(at position: Int, completion: (() -> Void)? = nil) -> Element {
        var result: Element!
        self.queue.sync { result = self.array.remove(at: position) }
        return result
    }

    //########################
    public func removeSubrange(_ bounds: Range<Int>) {
    }

    public func removeFirst(_ k: Int) {
    }

    public func removeFirst() -> Element {
        return self.array[0]
    }

    public func removeAll(keepingCapacity keepCapacity: Bool = false) {
    }

    public func reserveCapacity(_ n: Int) {
    }

    // TODO public func replaceSubrange<C, R>(_ subrange: R, with newElements: __owned C) where C : Collection, R : RangeExpression, Element == C.Element, Self.Index == R.Bound {

    // TODO public func removeSubrange<R>(_ bounds: R) where R : RangeExpression, Self.Index == R.Bound {

    public func popLast() -> Element? {
        return self.array[0]
    }

    public func removeLast() -> Element {
        return self.array[0]
    }

    public func removeLast(_ k: Int) {
    }

    // TODO  public static func + <Other>(lhs: Array<Element>, rhs: Other) -> Array<Element> where Other : Sequence, Self.Element == Other.Element {

    // TODO  public static func + <Other>(lhs: Other, rhs: Array<Element>) -> Array<Element> where Other : Sequence, Self.Element == Other.Element {

    // TODO  public static func += <Other>(lhs: inout Array<Element>, rhs: Other) where Other : Sequence, Self.Element == Other.Element {

    // TODO  public static func + <Other>(lhs: Array<Element>, rhs: Other) -> Array<Element> where Other : RangeReplaceableCollection, Self.Element == Other.Element {

    public func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
    }

    public func reverse() {
    }

    // TODO public __consuming func reversed() -> ReversedCollection<Array<Element>>

    public var underestimatedCount: Int {
        return 0
    }

    public func forEach(_ body: (Element) throws -> Void) rethrows {
    }

    public func first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
        return self.array[0]
    }

    public func withContiguousStorageIfAvailable<R>(_ body: (UnsafeBufferPointer<Element>) throws -> R) rethrows -> R? {
        return try self.array.withContiguousStorageIfAvailable(body)
    }

    // TODO public func enumerated() -> EnumeratedSequence<Array<Element>>

    @warn_unqualified_access
    public func min(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> Element? {
        return self.array[0]
    }

    public func max(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> Element? {
        return self.array[0]
    }

    public func starts<PossiblePrefix>(with possiblePrefix: PossiblePrefix, by areEquivalent: (Element, PossiblePrefix.Element) throws -> Bool) rethrows -> Bool where PossiblePrefix : Sequence {
        return false
    }

    public func elementsEqual<OtherSequence>(_ other: OtherSequence, by areEquivalent: (Element, OtherSequence.Element) throws -> Bool) rethrows -> Bool where OtherSequence : Sequence {
        return false
    }

    // TODO public func lexicographicallyPrecedes<OtherSequence>(_ other: OtherSequence, by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> Bool where OtherSequence : Sequence, Self.Element == OtherSequence.Element {

    public func contains(where predicate: (Element) throws -> Bool) rethrows -> Bool {
        return false
    }

    public func allSatisfy(_ predicate: (Element) throws -> Bool) rethrows -> Bool {
        return false
    }

    func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) throws -> Result) rethrows -> Result {
        return initialResult
    }

    func reduce<Result>(into initialResult: __owned Result, _ updateAccumulatingResult: (inout Result, Element) throws -> ()) rethrows -> Result {
        return initialResult
    }

    // TODO public func flatMap<SegmentOfResult>(_ transform: (Element) throws -> SegmentOfResult) rethrows -> [SegmentOfResult.Element] where SegmentOfResult : Sequence {

    // TODO public func compactMap<ElementOfResult>(_ transform: (Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {

    public func sorted(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> [Element] {
        return []
    }

    public func sort(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows {
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

// MARK: - Comparable element

public extension SynchronizedArray where Element : Comparable {

    func sorted() -> SynchronizedArray {
        var result: SynchronizedArray!
        self.queue.sync { result = SynchronizedArray(self.array.sorted()) }
        return result
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
