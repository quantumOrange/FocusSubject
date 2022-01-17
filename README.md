# PullbackSubject


Given a subject with an Output of A, and functions `(A)->B?` and `(B)->A`, we provide a method to produces a new subject with output B.

```
    func pullback<LocalOutput>(send:@escaping (LocalOutput) -> Output, receive:@escaping (Output)->LocalOutput?) -> PullbackSubject<LocalOutput,Failure>
```

# Motivation

Every Subject has a map function because it is a Publisher. If our subject has an Output of type A, and we map a function `(A)->B`, the result is a Publisher with Output of type B. However, we cannot call `send(_:)` on our new Publisher because it is not a Subject.  In fact we don't provide enough information for map to achive this. We need another contravarient `(B)->A` function to create a Subject.  We both functions, we can now pullback our subject to a new Subject with Output B, and we can send values to our subject. This can be helpful to foucus a Subject defiend on a broad domain onto something more specific.






