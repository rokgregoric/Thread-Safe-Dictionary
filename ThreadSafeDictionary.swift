//
//  ThreadSafeDictionary.swift
//
//  Created by Shashank on 29/10/20.
//

import Foundation

class ThreadSafeDictionary<V: Hashable,T>: Collection {
  private var dictionary: [V: T]
  private let concurrentQueue = DispatchQueue(label: "Dictionary Barrier Queue", attributes: .concurrent)

  var keys: Dictionary<V, T>.Keys { concurrentQueue.sync { dictionary.keys } }
  var values: Dictionary<V, T>.Values { concurrentQueue.sync { dictionary.values } }
  var startIndex: Dictionary<V, T>.Index { concurrentQueue.sync { dictionary.startIndex } }
  var endIndex: Dictionary<V, T>.Index { concurrentQueue.sync { dictionary.endIndex } }
  var dict: Dictionary<V, T> { concurrentQueue.sync { dictionary } }

  init(dict: [V: T] = [V:T]()) { dictionary = dict }

  func index(after i: Dictionary<V, T>.Index) -> Dictionary<V, T>.Index { concurrentQueue.sync { dictionary.index(after: i) } }
  subscript(key: V) -> T? {
    set { concurrentQueue.async(flags: .barrier) { [weak self] in self?.dictionary[key] = newValue } }
    get { concurrentQueue.sync { dictionary[key] } }
  }
  subscript(index: Dictionary<V, T>.Index) -> Dictionary<V, T>.Element { concurrentQueue.sync { dictionary[index] } }
  func removeValue(forKey key: V) { concurrentQueue.async(flags: .barrier) { [weak self] in self?.dictionary.removeValue(forKey: key) } }
  func removeAll() { concurrentQueue.async(flags: .barrier) { [weak self] in self?.dictionary.removeAll() } }
}
