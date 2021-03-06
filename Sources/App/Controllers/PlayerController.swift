//
//  PlayerController.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 01/03/2017.
//
//

import Vapor
import HTTP

final class PlayerController {
    
    func addRoutes(drop: Droplet){
//        let players = drop.grouped("players")
        let players = drop.grouped(BasicAuthMiddleware(), StaticInfo.protect).grouped("api").grouped("players")
        players.get(handler: index)
        players.post(handler: create)
        players.get(Player.self, handler: show)
        players.patch(Player.self, handler: update)
        players.delete(Player.self, handler: delete)
        players.get(Player.self, "injuries", handler: playerInjuries)
        players.get(Player.self, "concerns", handler: playerConcerns)
        players.get(Player.self, "details", handler: playerDetails)
    }

    
    func index(request: Request) throws -> ResponseRepresentable {
        return try Player.all().makeNode().converted(to: JSON.self)
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        var player = try request.player()
        try player.save()
        return player
    }
    
    func show(request: Request, player: Player) throws -> ResponseRepresentable {
        return player
    }
    
    func delete(request: Request, player: Player) throws -> ResponseRepresentable {
        try player.delete()
        return JSON([:])
    }
    
    func clear(request: Request) throws -> ResponseRepresentable {
        try Player.query().delete()
        return JSON([])
    }
    
    func update(request: Request, player: Player) throws -> ResponseRepresentable {
        let new = try request.player()
        var player = player
        player.name = new.name
        player.weight = new.weight
        player.date_of_birth = new.date_of_birth
        player.dominant_leg = new.dominant_leg
        player.photo = new.photo
        player.club_id = new.club_id
        try player.save()
        return player
    }
    
    func replace(request: Request, player: Player) throws -> ResponseRepresentable {
        try player.delete()
        return try create(request: request)
    }
    
    func playerInjuries(request: Request, player: Player) throws -> ResponseRepresentable {
        let children = try player.injuries()
        return try JSON(node: children.makeNode())
    }

    func playerConcerns(request: Request, player: Player) throws -> ResponseRepresentable {
        let children = try player.concerns()
        return try JSON(node: children.makeNode())
    }
    
    func playerDetails(request: Request, player: Player) throws -> ResponseRepresentable {
        let concerns = try player.concerns()
        let injuries = try player.injuries()
        return try JSON(node: [
            "injuries": injuries.makeNode(),
            "concerns" : concerns.makeNode()
            ])
    }

}

extension Request {
    func player() throws -> Player {
        guard let json = json else { throw Abort.badRequest }
        return try Player(node: json)
    }
}

