//
//  SubscriptionController.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 01/03/2017.
//
//


import Vapor
import HTTP

final class SubscriptionController: ResourceRepresentable {
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try Subscription.all().makeNode().converted(to: JSON.self)
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        var subscription = try request.subscription()
        try subscription.save()
        return subscription
    }
    
    func show(request: Request, subscription: Subscription) throws -> ResponseRepresentable {
        return subscription
    }
    
    func delete(request: Request, subscription: Subscription) throws -> ResponseRepresentable {
        try subscription.delete()
        return JSON([:])
    }
    
    func clear(request: Request) throws -> ResponseRepresentable {
        try Subscription.query().delete()
        return JSON([])
    }
    
    func update(request: Request, subscription: Subscription) throws -> ResponseRepresentable {
        let new = try request.subscription()
        var subscription = subscription
        subscription.package = new.package
        subscription.date_paid = new.date_paid
        subscription.amount_paid = new.amount_paid
        subscription.date_of_next_payment = new.date_of_next_payment
        subscription.payment_id = new.payment_id
        subscription.status = new.status
        subscription.club_id = new.club_id
        try subscription.save()
        return subscription
    }
    
    func replace(request: Request, subscription: Subscription) throws -> ResponseRepresentable {
        try subscription.delete()
        return try create(request: request)
    }
    
    func makeResource() -> Resource<Subscription> {
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
    func subscription() throws -> Subscription {
        guard let json = json else { throw Abort.badRequest }
        return try Subscription(node: json)
    }
}

