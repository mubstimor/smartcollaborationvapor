//
//  RecoveryTracker.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 10/05/2017.
//
//

import Vapor
import Fluent

final class RecoveryTracker: Model {
    var id: Node?
    var injury_id: Node?
    var rehab_time: String
    var date_recorded: String
    var specialist_id: Node?
    var injury_name: String
    var exists: Bool = false
    
    init(injury_id: Node? = nil, rehab_time: String, date_recorded: String, specialist_id: Node? = nil,   injury_name: String) {
        self.injury_id = injury_id
        self.rehab_time = rehab_time
        self.date_recorded = date_recorded
        self.specialist_id = specialist_id
        self.injury_name = injury_name
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        injury_id = try node.extract("injury_id")
        rehab_time = try node.extract("rehab_time")
        date_recorded = try node.extract("date_recorded")
        specialist_id = try node.extract("specialist_id")
        injury_name = try node.extract("injury_name")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "injury_id": injury_id,
            "rehab_time": rehab_time,
            "date_recorded": date_recorded,
            "specialist_id": specialist_id,
            "injury_name" : injury_name
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("recoverytrackers") { recovery in
            recovery.id()
            recovery.parent(Injury.self, optional: false)
            recovery.string("rehab_time")
            recovery.string("date_recorded")
            recovery.parent(Specialist.self, optional: false)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("recoverytrackers")
    }
}

