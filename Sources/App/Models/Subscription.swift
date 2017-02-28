//
//  Subscription.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 28/02/2017.
//
//

import Vapor
import Fluent

final class Subscription: Model {
    var id: Node?
    var package: String
    var datePaid: String
    var amountPaid: Double
    var dateOfNextPayment: String
    var club: String
    var exists: Bool = false
    
    init(package: String, datePaid: String, amountPaid: Double, dateOfNextPayment: String, club: String) {
        self.package = package
        self.datePaid = datePaid
        self.amountPaid = amountPaid
        self.dateOfNextPayment = dateOfNextPayment
        self.club = club
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        package = try node.extract("package")
        datePaid = try node.extract("yearFounded")
        amountPaid = try node.extract("country")
        dateOfNextPayment = try node.extract("dateOfNextPayment")
        club = try node.extract("club")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "package": package,
            "datePaid": datePaid,
            "amountPaid": amountPaid,
            "dateOfNextPayment": dateOfNextPayment,
            "club": club
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("subscription") { clubs in
            clubs.id()
            clubs.string("package")
            clubs.string("datePaid")
            clubs.string("amountPaid")
            clubs.string("dateOfNextPayment")
            clubs.string("club")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("subscription")
    }
}
