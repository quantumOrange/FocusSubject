import XCTest
@testable import PullbackSubject
import Combine

final class PullbackSubjectTests: XCTestCase {
    
    enum GlobalAction {
        case local(LocalAction)
        case two
    }
    
    enum LocalAction {
        case one
        case two
    }
    
    @available(iOS 13.0, *)
    func testExample() throws {
        
        let globalSubject = PassthroughSubject<GlobalAction,Never>()
        
        let localSubject = globalSubject.pullback(send: { la in
                .local(la)
        }, receive: { ga in
            if case let GlobalAction.local(la) = ga {
                return la
            }
            return nil
        })
        
        var localResults:[LocalAction] = []
        var globalResults:[GlobalAction] = []
        
        var cancelables = Set<AnyCancellable>()
         
        localSubject.sink { la in
            print("recieved local \(la)")
            localResults.append(la)
        }
        .store(in: &cancelables)
        
        globalSubject.sink { ga in
            print("recieved global \(ga)")
            globalResults.append(ga)
        }
        .store(in: &cancelables)
        
        globalSubject.send(.local(.one))
        globalSubject.send(.two)
        
        localSubject.send(.one)
        localSubject.send(.two)
       
        // We expect that both of the values sent to localSubject, and
        // the  .local sent to global to end up in localResults
        XCTAssert(localResults.count == 3)
        
        // We expect that both of the values sent to localSubject, and
        // both the values sent to globalSubject to end up in globalResults
        XCTAssert(globalResults.count == 4)
    }
}
