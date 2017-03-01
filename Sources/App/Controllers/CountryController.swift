//
//  CountryController.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 01/03/2017.
//
//

import Vapor
import HTTP

final class CountryController: ResourceRepresentable {
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try Country.all().makeNode().converted(to: JSON.self)
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        var country = try request.country()
        try country.save()
        return country
    }
    
    func show(request: Request, country: Country) throws -> ResponseRepresentable {
        return country
    }
    
    func delete(request: Request, country: Country) throws -> ResponseRepresentable {
        try country.delete()
        return JSON([:])
    }
    
    func clear(request: Request) throws -> ResponseRepresentable {
        try Country.query().delete()
        return JSON([])
    }
    
    func update(request: Request, country: Country) throws -> ResponseRepresentable {
        let new = try request.country()
        var country = country
        country.name = new.name
        try country.save()
        return country
    }
    
    func replace(request: Request, country: Country) throws -> ResponseRepresentable {
        try country.delete()
        return try create(request: request)
    }
    
    func makeResource() -> Resource<Country> {
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
    func country() throws -> Country {
        guard let json = json else { throw Abort.badRequest }
        return try Country(node: json)
    }
}

