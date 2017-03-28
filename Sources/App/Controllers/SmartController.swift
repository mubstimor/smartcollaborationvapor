//
//  SmartController.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 28/02/2017.
//
//

import Vapor
import HTTP
import VaporPostgreSQL
import VaporStripe

final class SmartController{
    
    func addRoutes(drop: Droplet){
    
        drop.get(handler: index)
        drop.get("dbversion", handler: dbversion)
        drop.post("name", handler: postName)
        drop.post("clubinjuries", handler: clubInjuries)
        drop.get("appointments", handler: appointments)
        drop.post("charge", handler: processPayment)
    }

    func dbversion(request: Request) throws -> ResponseRepresentable{
    
        if let db = drop.database?.driver as? PostgreSQLDriver{
            let version = try db.raw("SELECT version()")
            return try JSON(node: version)
        }else{
            return "NO DB Connection"
        }
    }
    
    func postName(request: Request) throws -> ResponseRepresentable{
    
        guard let name = request.data["name"]?.string else{
            throw Abort.badRequest
        }
        return try JSON(node:[
            "message":"Hello \(name)"
            ])
    }
    
    func clubInjuries(request: Request) throws -> ResponseRepresentable{
        
        guard let club_id = request.data["club_id"]?.string else{
            throw Abort.badRequest
        }

        let injuries = try Injury.query().filter("club_id", club_id).all()
        return try JSON(injuries.makeNode())
    }
    
    func processPayment(request: Request) throws -> ResponseRepresentable{
        
        guard let token = request.data["Token"]?.string else{
            throw Abort.badRequest
        }
        
        guard let amount = request.data["Amount"]?.string else{
            throw Abort.badRequest
        }
        
        let amountNo = Int(amount)!

//        let keys = "$STRIPE_SECRET_KEY"
        let api_key = "sk_test_sJofmAULIyYNFHMKsopEclQG"
        let stripe = VaporStripe(apiKey: api_key, token: token)
        let result = try stripe.charge(amount: amountNo, currency: .usd, description: "Payment for subscription")
        //        let injuries = try Injury.query().filter("club_id", card_number).all()
//        result.json
        return try JSON(node: ["message": "\(result.json)"])
    }
    
    func appointments(request: Request) throws -> ResponseRepresentable{
        
        let appointments = try Treatment.query().union(Injury.self)
            .union(Specialist.self).all()
        return try JSON(appointments.makeNode())
    }
    
    
    func index(request: Request) throws -> ResponseRepresentable{
    
        return try JSON(node: [
            "message": "Hello, welcome!"
            ])
    }
    
    

}
