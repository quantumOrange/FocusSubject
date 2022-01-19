import Combine

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public class FocusSubject<LocalOutput,Failure>: Subject where Failure:Error {
    
    public typealias Output = LocalOutput
    
    public convenience init() {
        self.init(subject:PassthroughSubject<LocalOutput,Failure>(), send:{$0}, receive: {$0})
    }
    
    init<Global,S>(subject:S, send:@escaping (LocalOutput) -> Global ,receive:@escaping (Global) -> LocalOutput?) where S:Subject, Failure == S.Failure, Global == S.Output {

        self._send = { value in
            let global = send(value)
            subject.send(global)
        }
        
        self._sendCompletion = { completion in
            subject.send(completion: completion)
        }
        
        self._sendSubscription = { subscription in
            subject.send(subscription:subscription)
        }
        
        self._receive = { subscriber in
            let globalSubscriber = GlobalSubscriber<Global>(localSubscriber: subscriber, receive:receive)
            subject.receive(subscriber: globalSubscriber)
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
        private let receive:(Input) -> LocalOutput?
        
        fileprivate init(localSubscriber:AnySubscriber<LocalOutput, Failure>, receive:@escaping (Input) -> LocalOutput?){
            self.localSubscriber = localSubscriber
            self.receive = receive
        }
        
        func receive(subscription: Subscription) {
            localSubscriber.receive(subscription: subscription)
        }

        func receive(_ input: Input) -> Subscribers.Demand {
            if let localInput = receive(input) {
                return localSubscriber.receive(localInput)
            }
            return .none
        }

        func receive(completion: Subscribers.Completion<Failure>) {
            localSubscriber.receive(completion: completion)
        }
    }
}


