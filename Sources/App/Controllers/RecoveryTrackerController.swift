//
//  RecoveryTrackerController.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 10/05/2017.
//
//

import Vapor
import HTTP

final class RecoveryTrackerController {
    
    func addRoutes(drop: Droplet){

        let recovery = drop.grouped(BasicAuthMiddleware(), StaticInfo.protect).grouped("api").grouped("recovery")
        recovery.get(handler: index)
        recovery.post(handler: create)
        recovery.get(RecoveryTracker.self, handler: show)
        recovery.patch(RecoveryTracker.self, handler: update)
        recovery.delete(RecoveryTracker.self, handler: delete)
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try RecoveryTracker.all().makeNode().converted(to: JSON.self)
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        var recovery = try request.recovery()
        try recovery.save()
        return recovery
    }
    
    func show(request: Request, recovery: RecoveryTracker) throws -> ResponseRepresentable {
        return recovery
    }
    
    func delete(request: Request, recovery: RecoveryTracker) throws -> ResponseRepresentable {
        try recovery.delete()
        return JSON([:])
    }
    
    func clear(request: Request) throws -> ResponseRepresentable {
        try RecoveryTracker.query().delete()
        return JSON([])
    }
    
    func update(request: Request, recovery: RecoveryTracker) throws -> ResponseRepresentable {
        let new = try request.recovery()
        var recovery = recovery
        recovery.injury_id = new.injury_id
        recovery.rehab_time = new.rehab_time
        recovery.date_recorded = new.date_recorded
        recovery.specialist_id = new.specialist_id
        recovery.injury_name = new.injury_name
        try recovery.save()
        return recovery
    }
    
    func replace(request: Request, recovery: RecoveryTracker) throws -> ResponseRepresentable {
        try recovery.delete()
        return try create(request: request)
    }

  
}

extension Request {
    func recovery() throws -> RecoveryTracker {
        guard let json = json else { throw Abort.badRequest }
        return try RecoveryTracker(node: json)
    }
}

