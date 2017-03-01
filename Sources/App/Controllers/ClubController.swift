//
//  ClubController.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 01/03/2017.
//
//

import Vapor
import HTTP

final class ClubController: ResourceRepresentable {
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try Club.all().makeNode().converted(to: JSON.self)
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        var club = try request.club()
        try club.save()
        return club
    }
    
    func show(request: Request, club: Club) throws -> ResponseRepresentable {
        return club
    }
    
    func delete(request: Request, club: Club) throws -> ResponseRepresentable {
        try club.delete()
        return JSON([:])
    }
    
    func clear(request: Request) throws -> ResponseRepresentable {
        try Club.query().delete()
        return JSON([])
    }
    
    func update(request: Request, club: Club) throws -> ResponseRepresentable {
        let new = try request.club()
        var club = club
        club.name = new.name
        club.established = new.established
        club.league_id = new.league_id
        try club.save()
        return club
    }
    
    func replace(request: Request, club: Club) throws -> ResponseRepresentable {
        try club.delete()
        return try create(request: request)
    }
    
    func makeResource() -> Resource<Club> {
        return Resource(
            index: index,
            store: create,
            show: show,
            replace: replace,
            modify: update,
            destroy: delete,
            clear: clear
        )
    }
}

extension Request {
    func club() throws -> Club {
        guard let json = json else { throw Abort.badRequest }
        return try Club(node: json)
    }
}
