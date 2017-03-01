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
    var date_paid: String
    var amount_paid: Double
    var date_of_next_payment: String
    var club_id: Node?
    var exists: Bool = false
    
    init(package: String, datePaid: String, amountPaid: Double, dateOfNextPayment: String, club_id: Node? = nil) {
        self.package = package
        self.date_paid = datePaid
        self.amount_paid = amountPaid
        self.date_of_next_payment = dateOfNextPayment
        self.club_id = club_id
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        package = try node.extract("package")
        date_paid = try node.extract("date_paid")
        amount_paid = try node.extract("amount_paid")
        date_of_next_payment = try node.extract("date_of_next_payment")
        club_id = try node.extract("club_id")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "package": package,
            "date_paid": date_paid,
            "amount_paid": amount_paid,
            "date_of_next_payment": date_of_next_payment,
            "club_id": club_id
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("subscriptions") { subscriptions in
            subscriptions.id()
            subscriptions.string("package")
            subscriptions.string("date_paid")
            subscriptions.string("amount_paid")
            subscriptions.string("date_of_next_payment")
           subscriptions.parent(Club.self, optional: false)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("subscriptions")
    }
}
