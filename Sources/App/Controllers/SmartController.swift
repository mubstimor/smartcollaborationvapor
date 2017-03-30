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

final class SmartController{
    
    func addRoutes(drop: Droplet){
    
        drop.get(handler: index)
        drop.get("dbversion", handler: dbversion)
        drop.post("name", handler: postName)
        drop.post("clubinjuries", handler: clubInjuries)
        drop.get("appointments", handler: appointments)
        drop.post("club_subscription", handler: create_club_subscription)
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
    
    // assign user to default subscription package
    func create_club_subscription(request: Request) throws -> ResponseRepresentable{
        
        guard let club_id = request.data["club_id"]?.string else{
            throw Abort.badRequest
        }
        
        guard let email = request.data["email"]?.string else{
            throw Abort.badRequest
        }
        
        // if user is the first to register from a given club, create a sub package for them
        //if try Specialist.query().filter("club_id", club_id).first() == nil {
            
            let dictionary:Node = [
                "email": Node.string(email)
            ]
            
            // send request to stripe server
            let stripeResponse = try drop.client.post("https://smartcollaborationstripe.herokuapp.com/customer.php", headers: [
                "Content-Type": "application/x-www-form-urlencoded"
                ], body: Body.data( Node(dictionary).formURLEncoded()))
            
            return try JSON(node:[
                "message":"\(stripeResponse)"
                ])

        //}else{
          //  return try JSON(node:[
          //      "message":"Unable to create package"
          //      ])
        //}

       
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
