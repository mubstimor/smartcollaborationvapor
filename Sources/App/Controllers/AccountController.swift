//
//  AccountController.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 01/03/2017.
//
//

import Vapor
import HTTP
import Turnstile


final class AccountController{
    
    func addRoutes(drop: Droplet){
        let specialist = drop.grouped("api")
        specialist.get(handler: index)
        specialist.post("register", handler: register)
        specialist.post("login", handler: login)
        specialist.get("logout", handler: logout)
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        _ = try? request.auth.user() as! Specialist
        return try Specialist.all().makeNode().converted(to: JSON.self)
    }
    
    func register(request: Request) throws -> ResponseRepresentable {
        
        guard let email = request.data["email"]?.string,
            let name = request.data["name"]?.string,
            let password = request.data["password"]?.string,
            let club = request.data["club_id"]?.string else {
                return try JSON(node: [
                    "error": "Missing Information!"
                    ])
        }
        let user = try Specialist.register(name: name, email: email, password: password, club_id: club)
        
        let credentials = UsernamePassword(username: email, password: password)
        try request.auth.login(credentials)
        
        //return Response(redirect: "/specialists")
        return user
        
    }
    
    func login(request: Request) throws -> ResponseRepresentable {
        //print("called to authenticate api keys")
        guard let email = request.data["email"]?.string,
            let password = request.data["password"]?.string else {
                return try JSON(node: [
                    "error": "Missing email or password!"
                    ])
        }
        let credentials = UsernamePassword(username: email, password: password)
        do {
            try request.auth.login(credentials)
            //return Response(redirect: "/specialist")
            let user = try request.user()
            return user
        } catch let e as TurnstileError {
            //return e.description
            return try JSON(node: ["error": e.description])
        }
    }
    
    func logout(request: Request) throws -> ResponseRepresentable {
        try request.auth.logout()
        return Response(redirect: "/")
    }
    
}




