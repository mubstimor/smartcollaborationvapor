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
    var date_of_birth: String
    var dominant_leg: String
    var club_id: Node?
    var exists: Bool = false
    
    init(name: String, weight: Float, dateOfBirth: String, dominantLeg: String, club_id: Node? = nil) {
        self.name = name
        self.weight = weight
        self.date_of_birth = dateOfBirth
        self.dominant_leg = dominantLeg
        self.club_id = club_id
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        weight = try node.extract("weight")
        date_of_birth = try node.extract("date_of_birth")
        dominant_leg = try node.extract("dominant_leg")
        club_id = try node.extract("club_id")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "weight": weight,
            "date_of_birth": date_of_birth,
            "dominant_leg": dominant_leg,
            "club_id": club_id
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("players") { players in
            players.id()
            players.string("name")
            players.string("weight")
            players.string("date_of_birth")
            players.string("dominant_leg")
            players.parent(Club.self, optional: false)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("players")
    }
}


extension Player{
    func injuries() throws -> [Injury] {
        return try children(nil, Injury.self).all()
    }
    
    func concerns() throws -> [KeyConcern] {
        return try children(nil, KeyConcern.self).all()
    }
   
}
