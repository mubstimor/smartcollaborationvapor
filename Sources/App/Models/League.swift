//
//  League.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 28/02/2017.
//
//

import Vapor
import Fluent

final class League: Model {
    var id: Node?
    var name: String
    var country: String
    var exists: Bool = false
    
    init(name: String, country: String) {
        self.name = name
        self.country = country
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        country = try node.extract("country")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "country": country
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("leagues") { leagues in
            leagues.id()
            leagues.string("name")
            leagues.string("country")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("leagues")
    }
}

