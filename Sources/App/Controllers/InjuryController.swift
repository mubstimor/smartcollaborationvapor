//
//  InjuryController.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 01/03/2017.
//
//


import Vapor
import HTTP

final class InjuryController {
    
    func addRoutes(drop: Droplet){
//        let injuries = drop.grouped("injuries")
        let injuries = drop.grouped(BasicAuthMiddleware(), StaticInfo.protect).grouped("api").grouped("injuries")
        injuries.get(handler: index)
        injuries.post(handler: create)
        injuries.get(Injury.self, handler: show)
        injuries.patch(Injury.self, handler: update)
        injuries.get(Injury.self, "treatments", handler: treatmentsIndex)
    }
    
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
        injury.time_of_injury = new.time_of_injury
        injury.injured_body_part = new.injured_body_part
        injury.is_contact_injury = new.is_contact_injury
        injury.playing_surface = new.playing_surface
        injury.weather_conditions = new.weather_conditions
        injury.estimated_absence_period = new.estimated_absence_period
        injury.club_id = new.club_id
        injury.specialist_id = new.specialist_id

        try injury.save()
        return injury
    }
    
    func replace(request: Request, injury: Injury) throws -> ResponseRepresentable {
        try injury.delete()
        return try create(request: request)
    }
    
//    func makeResource() -> Resource<Injury> {
//        return Resource(
//            index: index,
//            store: create,
//            show: show,
//            replace: replace,
//            modify: update,
//            destroy: delete,
//            clear: clear
//        )
//    }
    
    func treatmentsIndex(request: Request, injury: Injury) throws -> ResponseRepresentable {
        var response: [Node] = []
        
        let children = try injury.treatments()
        for treatment in children {
            let specialist_id = treatment.specialist_id
            let specialist = try Specialist.find(specialist_id!)
            
            let object = try Node(node: [
                "treatment": treatment,
                "specialist": specialist?.name
                ])
            response += object
        }
        
        return try JSON(node: response.makeNode())
        
    }
}

extension Request {
    func injury() throws -> Injury {
        guard let json = json else { throw Abort.badRequest }
        return try Injury(node: json)
    }
}

