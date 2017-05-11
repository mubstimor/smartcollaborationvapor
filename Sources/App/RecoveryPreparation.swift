//
//  RecoveryPreparation.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 11/05/2017.
//
//

import Vapor
import Fluent

struct RecoveryPreparation: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.modify("recoverytrackers", closure: { name in
            name.string("injury_name", length: 150, optional: false, unique: false, default: "Hamstring")
        })
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("recoverytrackers")
    }
}
