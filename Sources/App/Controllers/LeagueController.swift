//
//  LeagueController.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 01/03/2017.
//
//

import Vapor
import HTTP

final class LeagueController: ResourceRepresentable {
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try League.all().makeNode().converted(to: JSON.self)
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        var league = try request.league()
        try league.save()
        return league
    }
    
    func show(request: Request, league: League) throws -> ResponseRepresentable {
        return league
    }
    
    func delete(request: Request, league: League) throws -> ResponseRepresentable {
        try league.delete()
        return JSON([:])
    }
    
    func clear(request: Request) throws -> ResponseRepresentable {
        try League.query().delete()
        return JSON([])
    }
    
    func update(request: Request, league: League) throws -> ResponseRepresentable {
        let new = try request.league()
        var league = league
        league.name = new.name
        league.country_id = new.country_id
        try league.save()
        return league
    }
    
    func replace(request: Request, league: League) throws -> ResponseRepresentable {
        try league.delete()
        return try create(request: request)
    }
    
    func makeResource() -> Resource<League> {
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
    func league() throws -> League {
        guard let json = json else { throw Abort.badRequest }
        return try League(node: json)
    }
}

