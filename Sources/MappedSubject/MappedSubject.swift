import Combine

@available(iOS 13.0, *)
@available(macOS 10.15, *)
class MappedSubject<Local,Global,F>: Subject  where F:Error {
    
    typealias Output = Local
    typealias Failure = F
    
    let passthroughSubject:PassthroughSubject<Global,Failure>
    let f:(Local) -> Global
    let finverse:(Global) -> Local?
    
    init(subject:PassthroughSubject<Global,Failure>, f:@escaping (Local) -> Global ,finverse:@escaping (Global) -> Local?){
        self.passthroughSubject = subject
        self.f = f
        self.finverse = finverse
    }
    
    func send(_ value: Output) {
        let global = f(value)
        passthroughSubject.send(global)
    }
    
    func send(completion: Subscribers.Completion<Failure>) {
        passthroughSubject.send(completion:completion)
    }
    
    func send(subscription: Subscription) {
        passthroughSubject.send(subscription:subscription)
    }
     
    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input{
        let globalSubscriber = GlobalSubscriber(localSubscriber: subscriber, finverse: finverse)
       passthroughSubject.receive(subscriber: globalSubscriber)
    }
    
    class GlobalSubscriber<S>: Subscriber where S : Subscriber, Failure == S.Failure, Output == S.Input{
       
        typealias Input = Global
        typealias Failure = F
        let localSubscriber:S
        let finverse:(Global) -> Local?
        
        init(localSubscriber:S, finverse:@escaping (Global) -> Local?){
            self.localSubscriber = localSubscriber
            self.finverse = finverse
        }
        
        func receive(subscription: Subscription) {
            localSubscriber.receive(subscription: subscription)
        }

        func receive(_ input: Global) -> Subscribers.Demand {
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


