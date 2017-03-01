//
//  FeedbackController.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 01/03/2017.
//
//


import Vapor
import HTTP

final class FeedbackController: ResourceRepresentable {
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try Feedback.all().makeNode().converted(to: JSON.self)
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        var feedback = try request.feedback()
        try feedback.save()
        return feedback
    }
    
    func show(request: Request, feedback: Feedback) throws -> ResponseRepresentable {
        return feedback
    }
    
    func delete(request: Request, feedback: Feedback) throws -> ResponseRepresentable {
        try feedback.delete()
        return JSON([:])
    }
    
    func clear(request: Request) throws -> ResponseRepresentable {
        try Feedback.query().delete()
        return JSON([])
    }
    
    func update(request: Request, feedback: Feedback) throws -> ResponseRepresentable {
        let new = try request.feedback()
        var feedback = feedback
        feedback.treatment_id = new.treatment_id
        feedback.comment = new.comment
        feedback.date_added = new.date_added
        feedback.specialist_id = new.specialist_id
        try feedback.save()
        return feedback
    }
    
    func replace(request: Request, feedback: Feedback) throws -> ResponseRepresentable {
        try feedback.delete()
        return try create(request: request)
    }
    
    func makeResource() -> Resource<Feedback> {
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
    func feedback() throws -> Feedback {
        guard let json = json else { throw Abort.badRequest }
        return try Feedback(node: json)
    }
}

