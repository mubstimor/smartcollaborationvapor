//
//  TreatmentController.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 01/03/2017.
//
//


import Vapor
import HTTP
import Foundation

final class TreatmentController{
    
    func addRoutes(drop: Droplet){
//        let treatments = drop.grouped("treatments")
        let treatments = drop.grouped(BasicAuthMiddleware(), StaticInfo.protect).grouped("api").grouped("treatments")
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
        
        // update injury status if injury is marked as recovered
        if treatment.status_from_assessment == "Recovered" {
            let injury_id = treatment.injury_id
            var injury = try Injury.query().filter("id", injury_id!).first()
            injury?.recovery_date = treatment.date_of_treatment
            try injury?.save()
            
            /*
             * Date comparison based on http://stackoverflow.com/questions/24723431/swift-days-between-two-nsdates
             */
            // update recovery tracker too
//            let calendar = NSCalendar.current
            
            // Replace the hour (time) of both dates with 00:00
            let date1 = Date().convertFullStringToDate(dateString: treatment.date_of_treatment)
            let date2 = Date().convertFullStringToDate(dateString: (injury?.time_of_injury)!)
            
//            let components = calendar.dateComponents([.day], from: date1, to: date2)
//            let numberOfDays = components.day
            let numberOfDays = daysBetween(start: date1, end: date2)
            
            var recovery = RecoveryTracker(injury_id: treatment.injury_id, rehab_time: "\(numberOfDays)", date_recorded: Date().getCurrentDate(), specialist_id: treatment.specialist_id, injury_name: (injury?.name)!)
            try recovery.save()
            
        }
        
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
        var response:[Node] = []
        let children = try treatment.comments()
        
        for comment in children {
            let specialist_id = comment.specialist_id
            let specialist = try Specialist.find(specialist_id!)
            
            let object = try Node(node: [
                "comment": comment.comment,
                "specialist_id": specialist?.name,
                "date_added": comment.date_added,
                "treatment_id": comment.treatment_id,
                "id": comment.id
                ])
            response += object
        }

        
        return try JSON(node: response.makeNode())
    }
    
    func daysBetween(start: Date, end: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: start, to: end).day!
    }
    
}

extension Request {
    func treatment() throws -> Treatment {
        guard let json = json else { throw Abort.badRequest }
        return try Treatment(node: json)
    }
}

