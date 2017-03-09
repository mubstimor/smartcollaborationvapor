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
    var email_extension: String
    var league_id: Node?
    var exists: Bool = false
    
    init(name: String, established: String, email_extension: String, league_id: Node? = nil) {
        self.name = name
        self.established = established
        self.email_extension = email_extension
        self.league_id = league_id
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        established = try node.extract("established")
        email_extension = try node.extract("email_extension")
        league_id = try node.extract("league_id")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "established": established,
            "email_extension": email_extension,
            "league_id": league_id
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("clubs") { clubs in
            clubs.id()
            clubs.string("name")
            clubs.string("established")
            clubs.string("email_extension")
            clubs.parent(League.self, optional: false)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("clubs")
    }
}

extension Club{
    func specialists() throws -> [Specialist] {
        return try children(nil, Specialist.self).all()
    }
    
    func players() throws -> [Player] {
        return try children(nil, Player.self).all()
    }
}
