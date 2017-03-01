//
//  Country.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 28/02/2017.
//
//

import Vapor
import Fluent

final class Country: Model {
    var id: Node?
    var name: String
    var exists: Bool = false
    
    init(name: String) {
        self.name = name
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("countrys") { countries in
            countries.id()
            countries.string("name")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("countrys")
    }
}


