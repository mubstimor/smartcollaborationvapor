//
//  KeyConcern.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 20/04/2017.
//
//

import Vapor
import Fluent

final class KeyConcern: Model {
    var id: Node?
    var name: String
    var player_id: Node?
    var exists: Bool = false
    
    init(name: String, player_id: Node? = nil) {
        self.name = name
        self.player_id = player_id
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        player_id = try node.extract("player_id")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "player_id": player_id
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("keyconcerns") { concerns in
            concerns.id()
            concerns.string("name")
            concerns.parent(Player.self, optional: false)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("keyconcerns")
    }
}


