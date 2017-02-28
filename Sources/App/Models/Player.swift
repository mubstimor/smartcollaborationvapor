//
//  Player.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 28/02/2017.
//
//

import Vapor
import Fluent

final class Player: Model {
    var id: Node?
    var name: String
    var weight: Float
    var dateOfBirth: String
    var dominantLeg: String
    var club: String
    var exists: Bool = false
    
    init(name: String, weight: Float, dateOfBirth: String, dominantLeg: String, club: String) {
        self.name = name
        self.weight = weight
        self.dateOfBirth = dateOfBirth
        self.dominantLeg = dominantLeg
        self.club = club
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        weight = try node.extract("weight")
        dateOfBirth = try node.extract("dateOfBirth")
        dominantLeg = try node.extract("dominantLeg")
        club = try node.extract("club")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "weight": weight,
            "dateOfBirth": dateOfBirth,
            "dominantLeg": dominantLeg,
            "club": club
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("players") { players in
            players.id()
            players.string("name")
            players.string("weight")
            players.string("dateOfBirth")
            players.string("dominantLeg")
            players.string("club")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("players")
    }
}
