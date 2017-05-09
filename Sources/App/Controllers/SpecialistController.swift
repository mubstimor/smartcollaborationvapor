//
//  SpecialistController.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 28/02/2017.
//
//


import Vapor
import HTTP
import TurnstileCrypto

final class SpecialistController {
    
    func addRoutes(drop: Droplet){
//        let specialists = drop.grouped("specialists")
        let specialists = drop.grouped(BasicAuthMiddleware(), StaticInfo.protect).grouped("specialists")
        specialists.get(handler: index)
        specialists.post(handler: create)
        specialists.get(Specialist.self, handler: show)
        specialists.patch(Specialist.self, handler: update)
        specialists.get(Specialist.self, "treatments", handler: treatmentsIndex)
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try Specialist.all().makeNode().converted(to: JSON.self)
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        var specialist = try request.specialist()
        try specialist.save()
        return specialist
    }
    
    func show(request: Request, specialist: Specialist) throws -> ResponseRepresentable {
        return specialist
    }
    
    func delete(request: Request, specialist: Specialist) throws -> ResponseRepresentable {
        try specialist.delete()
        return JSON([:])
    }
    
    func clear(request: Request) throws -> ResponseRepresentable {
        try Specialist.query().delete()
        return JSON([])
    }
    
    func update(request: Request, specialist: Specialist) throws -> ResponseRepresentable {
        let new = try request.specialist()
        var specialist = specialist
        specialist.name = new.name
        specialist.email = new.email
        specialist.password = BCrypt.hash(password: new.password)
        specialist.club_id = new.club_id
        try specialist.save()
        return specialist
    }
    
    func replace(request: Request, specialist: Specialist) throws -> ResponseRepresentable {
        try specialist.delete()
        return try create(request: request)
    }
    
//    func makeResource() -> Resource<Specialist> {
//        return Resource(
//            index: index,
//            show: show,
//            replace: replace,
//            modify: update,
//            destroy: delete,
//            clear: clear
//        )
//    }
    
    func treatmentsIndex(request: Request, specialist: Specialist) throws -> ResponseRepresentable {
        let children = try specialist.treatments()
        return try JSON(node: children.makeNode())
    }
}

extension Request {
    func specialist() throws -> Specialist {
        guard let json = json else { throw Abort.badRequest }
        return try Specialist(node: json)
    }
}

extension Specialist: ResponseRepresentable {
    func makeResponse() throws -> Response {
        let json = try JSON(node:
            [
                "id": id,
                "name": name,
                "email": email.value,
                "club_id": club_id,
                "api_key_id": apiKeyID,
                "api_key_secret": apiKeySecret
                
            ]
        )
        return try json.makeResponse()
    }
}
