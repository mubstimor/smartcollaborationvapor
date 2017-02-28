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
    var yearFounded: Int
    var country: String
    var exists: Bool = false
    
    init(name: String, yearFounded: Int, country: String) {
        self.name = name
        self.yearFounded = yearFounded
        self.country = country
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        yearFounded = try node.extract("yearFounded")
        country = try node.extract("country")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "yearFounded": yearFounded,
            "country": country
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("clubs") { clubs in
            clubs.id()
            clubs.string("name")
            clubs.string("yearFounded")
            clubs.string("country")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("clubs")
    }
}

