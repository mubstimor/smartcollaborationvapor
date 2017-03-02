//
//  FixtureController.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 02/03/2017.
//
//

import Vapor
import HTTP

final class FixtureController: ResourceRepresentable {
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try Fixture.all().makeNode().converted(to: JSON.self)
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        var fixture = try request.fixture()
        try fixture.save()
        return fixture
    }
    
    func show(request: Request, fixture: Fixture) throws -> ResponseRepresentable {
        return fixture
    }
    
    func delete(request: Request, fixture: Fixture) throws -> ResponseRepresentable {
        try fixture.delete()
        return JSON([:])
    }
    
    func clear(request: Request) throws -> ResponseRepresentable {
        try Fixture.query().delete()
        return JSON([])
    }
    
    func update(request: Request, fixture: Fixture) throws -> ResponseRepresentable {
        let new = try request.fixture()
        var fixture = fixture
        fixture.league_id = new.league_id
        fixture.name = new.name
        fixture.game_date = new.game_date
        fixture.game_time = new.game_time
        fixture.home_team = new.home_team
        fixture.away_team = new.away_team
        try fixture.save()
        return fixture
    }
    
    func replace(request: Request, fixture: Fixture) throws -> ResponseRepresentable {
        try fixture.delete()
        return try create(request: request)
    }
    
    func makeResource() -> Resource<Fixture> {
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
    func fixture() throws -> Fixture {
        guard let json = json else { throw Abort.badRequest }
        return try Fixture(node: json)
    }
}


