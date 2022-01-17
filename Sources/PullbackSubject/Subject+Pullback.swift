//
//  Subject+Pullback.swift
//  
//
//  Created by David Crooks on 15/01/2022.
//

import Foundation
import Combine
import CasePaths

@available(macOS 10.15, *)
@available(iOS 13.0, *)
extension Subject {
    public func pullback<LocalOutput>(send:@escaping (LocalOutput) -> Output, receive:@escaping (Output)->LocalOutput?) -> PullbackSubject<LocalOutput,Failure> {
        PullbackSubject<LocalOutput,Failure>(subject: self, send: send, receive: receive)
    }
    
    public func pullback<LocalOutput>(_ casePath:CasePath<Output, LocalOutput>) -> PullbackSubject<LocalOutput,Failure> {
        PullbackSubject<LocalOutput,Failure>(subject: self, send:casePath.embed, receive:casePath.extract)
    }
}
