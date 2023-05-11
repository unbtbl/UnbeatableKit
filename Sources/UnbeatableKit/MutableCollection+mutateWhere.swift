extension MutableCollection {
    /// Calls the given closure with an `inout` argument for each mathing element.
    /// - Returns: The amount of elements that were mutated.
    public mutating func mutate(where predicate: (Element) -> Bool, mutate: (inout Element) -> Void) -> Int {
        var mutated = 0
        for i in indices where predicate(self[i]) {
            mutate(&self[i])
            mutated += 1
        }
        return mutated
    }
}

extension Array {
    public mutating func upsert(_ element: Element, at: Index, where predicate: (Element) -> Bool) {
        if mutate(where: predicate, mutate: { $0 = element }) == 0 {
            insert(element, at: at)
        }
    }
}
