//
//  Fixture.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 02/03/2017.
//
//

import Vapor
import Fluent

final class Fixture: Model {
    var id: Node?
    var league_id : Node?
    var name: String
    var game_date: String
    var game_time: String
    var home_team: String
    var away_team: String
    var exists: Bool = false
    
    init(injury_id: Node? = nil, name: String, game_date: String, game_time: String, home_team: String, away_team: String) {
        self.league_id = injury_id
        self.name = name
        self.game_date = game_date
        self.game_time = game_time
        self.home_team = home_team
        self.away_team = away_team
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        league_id = try node.extract("league_id")
        name = try node.extract("name")
        game_date = try node.extract("game_date")
        game_time = try node.extract("game_time")
        home_team = try node.extract("home_team")
        away_team = try node.extract("away_team")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "league_id": league_id,
            "name": name,
            "game_date": game_date,
            "game_time": game_time,
            "home_team": home_team,
            "away_team": away_team
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("fixtures") { fixtures in
            fixtures.id()
            fixtures.parent(League.self, optional: false)
            fixtures.string("name")
            fixtures.string("game_date")
            fixtures.string("game_time")
            fixtures.string("home_team")
            fixtures.string("away_team")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("fixtures")
    }
}


