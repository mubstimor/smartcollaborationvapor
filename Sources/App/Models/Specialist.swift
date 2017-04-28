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
    var name: String
    var email: Valid<EmailValidator>
    var password: String
    var club_id: String
    var apiKeyID = URandom().secureToken
    var apiKeySecret = URandom().secureToken
    var exists: Bool = false
    
    init(name: String, email: String, password: String, club_id: String) throws {
        self.name = name
        self.email = try email.validated()
        self.password = BCrypt.hash(password: password)
        self.club_id = club_id
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
//        let emailString = try node.extract("email") as String
        name = try node.extract("name")
        email = try (node.extract("email") as String).validated()
        password = try node.extract("password")
        club_id = try node.extract("club_id")
        apiKeyID = try node.extract("api_key_id")
        apiKeySecret = try node.extract("api_key_secret")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "email": email.value,
            "password": password,
            "club_id": club_id,
            "api_key_id": apiKeyID,
            "api_key_secret": apiKeySecret
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("specialists") { specialists in
            specialists.id()
            specialists.string("name")
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
    
    static func register(name: String, email: String, password: String, club_id: String) throws -> Specialist {
        var newUser = try Specialist(name: name, email: email, password: password, club_id: club_id)
        if try Specialist.query().filter("email", newUser.email.value).first() == nil {
            // check user email belongs to a given extension
            let userEmail = newUser.email.value
            
            guard let club = try Club.query().filter("id", club_id).first() else{
                throw Abort.custom(status: .badRequest, message: "can't load club with id \(club_id)")
            }
            
//            guard let club_subscription = try Subscription.query().filter("id", club_id).first() else{
//                throw Abort.custom(status: .badRequest, message: "can't load club with id \(club_id)")
//            }
            
            if userEmail.hasSuffix(club.email_extension) {
                // save user
                try newUser.save()
                return newUser
            }else{
                throw Abort.custom(status: .badRequest, message: "Email not supported for \(club.name)")
            }
            
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
            print("auth with api keys")
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
