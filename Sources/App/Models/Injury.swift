//
//  Injury.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 28/02/2017.
//
//

import Vapor
import Fluent

final class Injury: Model {
    var id: Node?
    var name: String
    var playerName: String
    var situation: String
    var dateOfInjury: String
    var timeOfInjury: String
    var injuredBodyPart: String
    var isContactInjury : Bool?
    var playingSurface: String?
    var weatherConditions: String?
    var estimatedAbsencePeriod: String?
    var exists: Bool = false
    
    init(name: String, playerName: String, situation: String, dateOfInjury: String,
         timeOfInjury: String, injuredBodyPart: String, isContactInjury: Bool,
         playingSurface: String, weatherConditions: String, estimatedAbsencePeriod: String)
    {
        self.name = name
        self.playerName = playerName
        self.situation = situation
        self.dateOfInjury = dateOfInjury
        self.timeOfInjury = timeOfInjury
        self.injuredBodyPart = injuredBodyPart
        self.isContactInjury = isContactInjury
        self.playingSurface = playingSurface
        self.weatherConditions = weatherConditions
        self.estimatedAbsencePeriod = estimatedAbsencePeriod
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        playerName = try node.extract("playerName")
        situation = try node.extract("situation")
        dateOfInjury = try node.extract("dateOfInjury")
        timeOfInjury = try node.extract("timeOfInjury")
        injuredBodyPart = try node.extract("injuredBodyPart")
        isContactInjury = try node.extract("isContactInjury")
        playingSurface = try node.extract("playingSurface")
        weatherConditions = try node.extract("weatherConditions")
        estimatedAbsencePeriod = try node.extract("estimatedAbsencePeriod")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "playerName": playerName,
            "situation": situation,
            "dateOfInjury": dateOfInjury,
            "timeOfInjury": timeOfInjury,
            "injuredBodyPart": injuredBodyPart,
            "isContactInjury": isContactInjury,
            "playingSurface": playingSurface,
            "weatherConditions": weatherConditions,
            "estimatedAbsencePeriod": estimatedAbsencePeriod
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("injuries") { injuries in
            injuries.id()
            injuries.string("name")
            injuries.string("playerName")
            injuries.string("situation")
            injuries.string("dateOfInjury")
            injuries.string("timeOfInjury")
            injuries.string("injuredBodyPart")
            injuries.string("isContactInjury")
            injuries.string("playingSurface")
            injuries.string("weatherConditions")
            injuries.string("estimatedAbsencePeriod")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("injuries")
    }
}

