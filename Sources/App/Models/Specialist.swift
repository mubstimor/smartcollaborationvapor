//
//  Specialist.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 28/02/2017.
//
//

import Vapor
import Fluent
import Turnstile
import TurnstileCrypto
import HTTP
import Auth

final class Specialist: Model, User {
    
    var id: Node?
    var email: String
    var password: String
    var club_id: String
    var apiKeyID = URandom().secureToken
    var apiKeySecret = URandom().secureToken
    var exists: Bool = false
    
    init(email: String, password: String, club_id: String) {
        self.email = email
        self.password = BCrypt.hash(password: password)
        self.club_id = club_id
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        email = try node.extract("email")
        password = try node.extract("password")
        club_id = try node.extract("club_id")
        apiKeyID = try node.extract("api_key_id")
        apiKeySecret = try node.extract("api_key_secret")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "email": email,
            "password": password,
            "club_id": club_id,
            "api_key_id": apiKeyID,
            "api_key_secret": apiKeySecret
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("specialists") { specialists in
            specialists.id()
            specialists.string("email")
            specialists.string("password")
            specialists.parent(Club.self, optional: false)
            specialists.string("api_key_id")
            specialists.string("api_key_secret")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("specialists")
    }
    
    static func register(email: String, password: String, club_id: String) throws -> Specialist {
        var newUser = Specialist(email: email, password: password, club_id: club_id)
        if try Specialist.query().filter("email", newUser.email).first() == nil {
            try newUser.save()
            return newUser
        } else {
            throw AccountTakenError()
        }
    }
    
}

extension Specialist{
    // to be filled with specialist roles
}

extension Specialist: Authenticator {
    
    static func authenticate(credentials: Credentials) throws -> User {
        var user: Specialist?
        
        switch credentials {
            
            /*
             * Based on example at https://videos.raywenderlich.com/screencasts/server-side-swift-with-vapor-authentication-with-turnstile
             */
        case let credentials as UsernamePassword:
            let fetchedUser = try Specialist.query()
                .filter("email", credentials.username)
                .first()
            if let password = fetchedUser?.password,
                password != "",
                (try? BCrypt.verify(password: credentials.password, matchesHash: password)) == true {
                user = fetchedUser
            }
            
        case let credentials as Identifier:
            user = try Specialist.find(credentials.id)
            
            /**
             Authenticates via API Keys
             * taken from https://github.com/stormpath/Turnstile-Vapor-Example
             */
        case let credentials as APIKey:
            user = try Specialist.query()
                .filter("api_key_id", credentials.id)
                .filter("api_key_secret", credentials.secret)
                .first()
            
        default:
            throw UnsupportedCredentialsError()
        }
        
        if let user = user {
            return user
        } else {
            //throw IncorrectCredentialsError()
            throw Abort.custom(status: .badRequest, message: "Invalid credentials.")
        }
    }
    
    static func register(credentials: Credentials) throws -> User {
        throw Abort.badRequest
    }
    
}

extension Request {
    func user() throws -> Specialist {
        guard let user = try auth.user() as? Specialist else {
            throw Abort.badRequest
        }
        return user
    }
}
