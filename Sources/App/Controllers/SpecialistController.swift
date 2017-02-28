//
//  SpecialistController.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 28/02/2017.
//
//

import Vapor
import HTTP
import Turnstile

final class SpecialistController{

    func addRoutes(drop: Droplet){
        let specialist = drop.grouped("specialist")
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
        
        guard let email = request.formURLEncoded?["email"]?.string,
            let password = request.formURLEncoded?["password"]?.string,
            let club = request.formURLEncoded?["club"]?.string else {
                return try JSON(node: [
                    "error": "Missing Information!"
                    ])
        }
        _ = try Specialist.register(email: email, password: password, club: club)
        
        let credentials = UsernamePassword(username: email, password: password)
        try request.auth.login(credentials)
        
        return Response(redirect: "/specialist")
        
    }

    func login(request: Request) throws -> ResponseRepresentable {
        guard let email = request.formURLEncoded?["email"]?.string,
            let password = request.formURLEncoded?["password"]?.string else {
                return try JSON(node: [
                    "error": "Missing email or password!"
                    ])
        }
        let credentials = UsernamePassword(username: email, password: password)
        do {
            try request.auth.login(credentials)
            return Response(redirect: "/specialist")
        } catch let e as TurnstileError {
            return e.description
        }
    }
    
    func logout(request: Request) throws -> ResponseRepresentable {
        try request.auth.logout()
        return Response(redirect: "/")
    }

}
