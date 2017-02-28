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
    var dateAdded: String
    var exists: Bool = false
    
    init(name: String, dateAdded: String) {
        self.name = name
        self.dateAdded = dateAdded
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        dateAdded = try node.extract("dateAdded ")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "dateAdded": dateAdded
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("countries") { countries in
            countries.id()
            countries.string("name")
            countries.string("dateAdded")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("countries")
    }
}


