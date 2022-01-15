import Combine

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public class MappedSubject<LocalOutput,Failure>: Subject where Failure:Error {
    
    public typealias Output = LocalOutput
    
    init<Global>(passthroughSubject:PassthroughSubject<Global,Failure>, f:@escaping (LocalOutput) -> Global ,finverse:@escaping (Global) -> LocalOutput?){

        self._send = { value in
            let global = f(value)
            passthroughSubject.send(global)
        }
        
        self._sendCompletion = { completion in
            passthroughSubject.send(completion: completion)
        }
        
        self._sendSubscription = { subscription in
            passthroughSubject.send(subscription:subscription)
        }
        
        self._receive = { subscriber in
            let globalSubscriber = GlobalSubscriber<Global>(localSubscriber: subscriber, finverse: finverse)
            passthroughSubject.receive(subscriber: globalSubscriber)
        }
    }
    
    private var _send:(LocalOutput) -> Void
    
    public func send(_ value: Output) {
        _send(value)
    }
    
    private var _sendCompletion:(Subscribers.Completion<Failure>) -> Void
    
    public func send(completion: Subscribers.Completion<Failure>) {
        _sendCompletion(completion)
    }
    
    private var _sendSubscription:(Subscription)-> Void
    
    public func send(subscription: Subscription) {
        _sendSubscription(subscription)
    }
    
    private var _receive:(AnySubscriber<Output,Failure>) -> Void
    
    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, LocalOutput == S.Input{
        _receive(AnySubscriber(subscriber))
    }
        
    private class GlobalSubscriber<Input>: Subscriber {
       
        private let localSubscriber:AnySubscriber<LocalOutput,Failure>
        private let finverse:(Input) -> LocalOutput?
        
        fileprivate init(localSubscriber:AnySubscriber<LocalOutput, Failure>, finverse:@escaping (Input) -> LocalOutput?){
            self.localSubscriber = localSubscriber
            self.finverse = finverse
        }
        
        func receive(subscription: Subscription) {
            localSubscriber.receive(subscription: subscription)
        }

        func receive(_ input: Input) -> Subscribers.Demand {
            if let localInput = finverse(input) {
                return localSubscriber.receive(localInput)
            }
            return .none
        }

        func receive(completion: Subscribers.Completion<Failure>) {
            localSubscriber.receive(completion: completion)
        }
    }
}


