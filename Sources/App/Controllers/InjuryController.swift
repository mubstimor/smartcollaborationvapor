//
//  InjuryController.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 01/03/2017.
//
//


import Vapor
import HTTP

final class InjuryController: ResourceRepresentable {
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try Injury.all().makeNode().converted(to: JSON.self)
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        var injury = try request.injury()
        try injury.save()
        return injury
    }
    
    func show(request: Request, injury: Injury) throws -> ResponseRepresentable {
        return injury
    }
    
    func delete(request: Request, injury: Injury) throws -> ResponseRepresentable {
        try injury.delete()
        return JSON([:])
    }
    
    func clear(request: Request) throws -> ResponseRepresentable {
        try Injury.query().delete()
        return JSON([])
    }
    
    func update(request: Request, injury: Injury) throws -> ResponseRepresentable {
        let new = try request.injury()
        var injury = injury
        injury.name = new.name
        injury.player_id = new.player_id
        injury.situation = new.situation
        injury.date_of_injury = new.date_of_injury
        injury.time_of_injury = new.time_of_injury
        injury.injured_body_part = new.injured_body_part
        injury.is_contact_injury = new.is_contact_injury
        injury.playing_surface = new.playing_surface
        injury.weather_conditions = new.weather_conditions
        injury.estimated_absence_period = new.estimated_absence_period
        try injury.save()
        return injury
    }
    
    func replace(request: Request, injury: Injury) throws -> ResponseRepresentable {
        try injury.delete()
        return try create(request: request)
    }
    
    func makeResource() -> Resource<Injury> {
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
    func injury() throws -> Injury {
        guard let json = json else { throw Abort.badRequest }
        return try Injury(node: json)
    }
}

