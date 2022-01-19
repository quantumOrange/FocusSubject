//
//  Subject+Focus.swift
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
    public func focus<LocalOutput>(send:@escaping (LocalOutput) -> Output, receive:@escaping (Output)->LocalOutput?) -> FocusSubject<LocalOutput,Failure> {
        FocusSubject<LocalOutput,Failure>(subject: self, send: send, receive: receive)
    }
    
    public func focus<LocalOutput>(_ casePath:CasePath<Output, LocalOutput>) -> FocusSubject<LocalOutput,Failure> {
        FocusSubject<LocalOutput,Failure>(subject: self, send:casePath.embed, receive:casePath.extract)
    }
}
