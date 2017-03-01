//
//  TreatmentController.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 01/03/2017.
//
//


import Vapor
import HTTP

final class TreatmentController: ResourceRepresentable {
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try Treatment.all().makeNode().converted(to: JSON.self)
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        var treatment = try request.treatment()
        try treatment.save()
        return treatment
    }
    
    func show(request: Request, treatment: Treatment) throws -> ResponseRepresentable {
        return treatment
    }
    
    func delete(request: Request, treatment: Treatment) throws -> ResponseRepresentable {
        try treatment.delete()
        return JSON([:])
    }
    
    func clear(request: Request) throws -> ResponseRepresentable {
        try Treatment.query().delete()
        return JSON([])
    }
    
    func update(request: Request, treatment: Treatment) throws -> ResponseRepresentable {
        let new = try request.treatment()
        var treatment = treatment
        treatment.injury_id = new.injury_id
        treatment.date_of_treatment = new.date_of_treatment
        treatment.status_from_assessment = new.status_from_assessment
        treatment.diet_suggestions = new.diet_suggestions
        treatment.side_effects_from_previous_treatment = new.side_effects_from_previous_treatment
        treatment.specialist_suggestions = new.specialist_suggestions
        treatment.specialist_id = new.specialist_id
        try treatment.save()
        return treatment
    }
    
    func replace(request: Request, treatment: Treatment) throws -> ResponseRepresentable {
        try treatment.delete()
        return try create(request: request)
    }
    
    func makeResource() -> Resource<Treatment> {
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
    func treatment() throws -> Treatment {
        guard let json = json else { throw Abort.badRequest }
        return try Treatment(node: json)
    }
}

