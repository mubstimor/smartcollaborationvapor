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
    var country_id: Node?
    var exists: Bool = false
    
    init(name: String, country_id: Node? = nil) {
        self.name = name
        self.country_id = country_id
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        country_id = try node.extract("country_id")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "country_id": country_id
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("leagues") { leagues in
            leagues.id()
            leagues.string("name")
            leagues.parent(Country.self, optional: false)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("leagues")
    }
}

extension League{
    func clubs() throws -> [Club] {
        return try children(nil, Club.self).all()
    }
}
