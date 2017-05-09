//
//  StaticInfo.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 09/05/2017.
//
//

import Foundation
import Vapor
import Auth

class StaticInfo {

    static let protect = ProtectMiddleware(error:
        Abort.custom(status: .forbidden, message: "Not authorized.!")
    )
    
}
