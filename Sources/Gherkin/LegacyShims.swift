#if !swift(>=4.1)
extension Collection {
    func compactMap<ElementOfResult>(
        _ transform: (Element) throws -> ElementOfResult?
    ) rethrows -> [ElementOfResult] {
        return try flatMap(transform)
    }
}
#endif

#if !swift(>=5.0)
public enum Result<Success, Failure> where Failure : Error {

    /// A success, storing a `Success` value.
    case success(Success)

    /// A failure, storing a `Failure` value.
    case failure(Failure)
}

#endif
