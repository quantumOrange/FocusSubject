# FocusSubject


Given a subject with an output of `A`, and functions `(A)->B?` and `(B)->A`, we provide a method that produces a new subject with output `B`.

```
    func focus<LocalOutput>(send:@escaping (LocalOutput) -> Output, receive:@escaping (Output)->LocalOutput?) -> FocusSubject<LocalOutput,Failure>
```

Alternatively you can provide a [case path](https://github.com/pointfreeco/swift-case-paths) :

```
     func focus<LocalOutput>(_ casePath:CasePath<Output, LocalOutput>) -> FocusSubject<LocalOutput,Failure>
```

# Motivation

Every subject has a map function because it is a publisher. If our subject has an output of type `A`, and we map a function `(A)->B`, the result is a Publisher with output of type `B`. However, we cannot call `send(_:)` on our new publisher because it is not a subject.  In fact we don't provide enough information for map to achive this. We need another contravarient function `(B)->A` to create a Subject.  With both functions, we can now focus our subject to a new subject with output `B`, and we can send values to our subject. This can be helpful to focus a subject defined on a broad domain onto something more specific.


