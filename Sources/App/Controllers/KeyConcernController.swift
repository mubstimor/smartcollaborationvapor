//
//  KeyConcernController.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 20/04/2017.
//
//

import Vapor
import HTTP

final class KeyConcernController {
    
    func addRoutes(drop: Droplet){
        let keyconcerns = drop.grouped("keyconcerns")
        keyconcerns.get(handler: index)
        keyconcerns.post(handler: create)
        keyconcerns.get(KeyConcern.self, handler: show)
        keyconcerns.patch(KeyConcern.self, handler: update)
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try KeyConcern.all().makeNode().converted(to: JSON.self)
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        var concern = try request.concern()
        try concern.save()
        return concern
    }
    
    func show(request: Request, concern: KeyConcern) throws -> ResponseRepresentable {
        return concern
    }
    
    func delete(request: Request, league: KeyConcern) throws -> ResponseRepresentable {
        try league.delete()
        return JSON([:])
    }
    
    func clear(request: Request) throws -> ResponseRepresentable {
        try KeyConcern.query().delete()
        return JSON([])
    }
    
    func update(request: Request, concern: KeyConcern) throws -> ResponseRepresentable {
        let new = try request.concern()
        var concern = concern
        concern.name = new.name
        concern.player_id = new.player_id
        try concern.save()
        return concern
    }
    
    func replace(request: Request, league: KeyConcern) throws -> ResponseRepresentable {
        try league.delete()
        return try create(request: request)
    }
 
}

extension Request {
    func concern() throws -> KeyConcern {
        guard let json = json else { throw Abort.badRequest }
        return try KeyConcern(node: json)
    }
}

