public struct PartialIso<A, B> {
  public let apply: (A) -> B?
  public let unapply: (B) -> A?

  public init(apply: @escaping (A) -> B?, unapply: @escaping (B) -> A?) {
    self.apply = apply
    self.unapply = unapply
  }

  /// Inverts the partial isomorphism.
  public var inverted: PartialIso<B, A> {
    return .init(apply: self.unapply, unapply: self.apply)
  }

  /// A partial isomorphism between `(A, B)` and `(B, A)`.
  public static var commute: PartialIso<(A, B), (B, A)> {
    return .init(
      apply: { ($1, $0) },
      unapply: { ($1, $0) }
    )
  }

  public static func pipe<C>(_ lhs: PartialIso<A, B>, _ rhs: PartialIso<B, C>) -> PartialIso<A, C> {
    return PartialIso<A, C>(
      apply: { a in
        lhs.apply(a).flatMap(rhs.apply)
    },
      unapply: { c in
        rhs.unapply(c).flatMap(lhs.unapply)
    })
  }

  public static func compose<C>(_ lhs: PartialIso<B, C>, _ rhs: PartialIso<A, B>) -> PartialIso<A, C> {
    return PartialIso<A, C>(
      apply: { a in
        rhs.apply(a).flatMap(lhs.apply)
    },
      unapply: { c in
        lhs.unapply(c).flatMap(rhs.unapply)
    })
  }
}

extension PartialIso where B == A {
  /// The identity partial isomorphism.
  public static var id: PartialIso {
    return .init(apply: { $0 }, unapply: { $0 })
  }
}

extension PartialIso where B == (A, ()) {
  /// An isomorphism between `A` and `(A, Unit)`.
  public static var unit: PartialIso {
    return .init(
      apply: { ($0, ()) },
      unapply: { $0.0 }
    )
  }
}

public func flatten<A, B, C>(_ tuple: (A, (B, C))) -> (A, B, C) {
  return (tuple.0, tuple.1.0, tuple.1.1)
}

public func rightParanthesize<A, B, C>(_ tuple: (A, B, C)) -> (A, (B, C)) {
  return (tuple.0, (tuple.1, tuple.2))
}

public func flatten<A, B, C, D, E>(_ tuple: (A, (B, (C, (D, E))))) -> (A, B, C, D, E) {
  return (tuple.0, tuple.1.0, tuple.1.1.0, tuple.1.1.1.0, tuple.1.1.1.1)
}

public func rightParanthesize<A, B, C, D, E>(_ tuple: (A, B, C, D, E)) -> (A, (B, (C, (D, E)))) {
  return (tuple.0, (tuple.1, (tuple.2, (tuple.3, tuple.4))))
}
