//
//  TreatmentController.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 01/03/2017.
//
//


import Vapor
import HTTP

final class TreatmentController{
    
    func addRoutes(drop: Droplet){
        let treatments = drop.grouped("treatments")
        treatments.get(handler: index)
        treatments.post(handler: create)
        treatments.get(Treatment.self, handler: show)
        treatments.patch(Treatment.self, handler: update)
        treatments.get(Treatment.self, "feedbacks", handler: commentsIndex)
    }
    
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
        treatment.next_appointment = new.next_appointment
        treatment.specialist_id = new.specialist_id
        try treatment.save()
        return treatment
    }
    
    func replace(request: Request, treatment: Treatment) throws -> ResponseRepresentable {
        try treatment.delete()
        return try create(request: request)
    }
    
//    func makeResource() -> Resource<Treatment> {
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
    
    func commentsIndex(request: Request, treatment: Treatment) throws -> ResponseRepresentable {
        let children = try treatment.comments()
        return try JSON(node: children.makeNode())
    }
    
}

extension Request {
    func treatment() throws -> Treatment {
        guard let json = json else { throw Abort.badRequest }
        return try Treatment(node: json)
    }
}

