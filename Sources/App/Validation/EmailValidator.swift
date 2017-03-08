//
//  EmailValidator.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 08/03/2017.
//
//

import Vapor

class EmailValidator: ValidationSuite {

    static func validate(input value: String) throws {
        let evaluation = Email.self && Count.containedIn(low: 6, high: 64)
        try evaluation.validate(input: value)
    }
}
