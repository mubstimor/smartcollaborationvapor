//
//  Club.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 28/02/2017.
//
//

import Vapor
import Fluent

final class Club: Model {
    var id: Node?
    var name: String
    var established: String
    var league_id: Node?
    var exists: Bool = false
    
    init(name: String, established: String, league_id: Node? = nil) {
        self.name = name
        self.established = established
        self.league_id = league_id
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        established = try node.extract("established")
        league_id = try node.extract("league_id")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "established": established,
            "league_id": league_id
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("clubs") { clubs in
            clubs.id()
            clubs.string("name")
            clubs.string("established")
            clubs.parent(League.self, optional: false)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("clubs")
    }
}

