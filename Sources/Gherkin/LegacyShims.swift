#if !swift(>=4.1)
    extension Collection {
        func compactMap<ElementOfResult>(
            _ transform: (Element) throws -> ElementOfResult?
        ) rethrows -> [ElementOfResult] {
            try flatMap(transform)
        }
    }
#endif
