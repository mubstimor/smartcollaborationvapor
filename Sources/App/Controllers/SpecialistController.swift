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

final class SpecialistController: ResourceRepresentable {
    
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
    
    func makeResource() -> Resource<Specialist> {
        return Resource(
            index: index,
            show: show,
            replace: replace,
            modify: update,
            destroy: delete,
            clear: clear
        )
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
                "email": email,
                "club_id": club_id,
                "api_key_id": apiKeyID,
                "api_key_secret": apiKeySecret
                
            ]
        )
        return try json.makeResponse()
    }
}
