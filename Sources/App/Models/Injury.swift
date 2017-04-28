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
    var player_id: Node?
    var situation: String
    var date_of_injury: String
    var time_of_injury: String
    var injured_body_part: String?
    var is_contact_injury : String?
    var playing_surface: String?
    var weather_conditions: String?
    var estimated_absence_period: String?
    var recovery_date: String?
    var club_id: Node?
    var specialist_id: Node?

    var exists: Bool = false
    
    init(name: String, player_id: Node? = nil, situation: String, dateOfInjury: String, timeOfInjury: String,
        injuredBodyPart: String, isContactInjury: String,
        playingSurface: String, weatherConditions: String, estimatedAbsencePeriod: String, recovery_date: String, club_id: Node? = nil, specialist_id: Node? = nil
        )
    {
        self.name = name
        self.player_id = player_id
        self.situation = situation
        self.date_of_injury = dateOfInjury
        self.time_of_injury = timeOfInjury
        self.injured_body_part = injuredBodyPart
        self.is_contact_injury = isContactInjury
        self.playing_surface = playingSurface
        self.weather_conditions = weatherConditions
        self.estimated_absence_period = estimatedAbsencePeriod
        self.recovery_date = recovery_date
        self.club_id = club_id
        self.specialist_id = specialist_id
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        player_id = try node.extract("player_id")
        situation = try node.extract("situation")
        date_of_injury = try node.extract("date_of_injury")
        time_of_injury = try node.extract("time_of_injury")
        injured_body_part = try node.extract("injured_body_part")
        is_contact_injury = try node.extract("is_contact_injury")
        playing_surface = try node.extract("playing_surface")
        weather_conditions = try node.extract("weather_conditions")
        estimated_absence_period = try node.extract("estimated_absence_period")
        recovery_date = try node.extract("recovery_date")
        club_id = try node.extract("club_id")
        specialist_id = try node.extract("specialist_id")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "player_id": player_id,
            "situation": situation,
            "date_of_injury": date_of_injury,
            "time_of_injury": time_of_injury,
            "injured_body_part": injured_body_part,
            "is_contact_injury": is_contact_injury,
            "playing_surface": playing_surface,
            "weather_conditions": weather_conditions,
            "estimated_absence_period": estimated_absence_period,
            "recovery_date": recovery_date,
            "club_id": club_id,
            "specialist_id": specialist_id

            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("injurys") { injuries in
            injuries.id()
            injuries.string("name")
            injuries.parent(Player.self, optional: false)
            injuries.string("situation")
            injuries.string("date_of_injury")
            injuries.string("time_of_injury")
            injuries.string("injured_body_part")
            injuries.string("is_contact_injury")
            injuries.string("playing_surface")
            injuries.string("weather_conditions")
            injuries.string("estimated_absence_period")
            injuries.string("recovery_date")
            injuries.parent(Club.self, optional:false)
            injuries.parent(Specialist.self, optional: false)

        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("injurys")
    }
}

extension Injury{
    func treatments() throws -> [Treatment] {
        return try children(nil, Treatment.self).all()
    }
}
