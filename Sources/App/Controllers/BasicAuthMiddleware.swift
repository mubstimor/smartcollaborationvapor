//
//  BasicAuthMiddleware.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 03/03/2017.
//
// Adapted from BasicAuthenticationMiddleware https://github.com/stormpath/Turnstile-Vapor-Example
//

import Vapor
import HTTP
import Turnstile

/**
 Takes a Basic Authentication header and turns it into a set of API Keys,
 and attempts to authenticate against it.
 */

class BasicAuthMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        
        if let apiKey = request.auth.header?.basic {
            try? request.auth.login(apiKey, persist: false)
        }
        
        return try next.respond(to: request)
    }
}

