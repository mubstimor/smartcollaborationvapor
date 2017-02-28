//
//  Feedback.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 28/02/2017.
//
//

import Vapor
import Fluent

final class Feedback: Model {
    var id: Node?
    var treatmentNumber: Int
    var comment: String
    var dateAdded: String
    var exists: Bool = false
    
    init(treatmentNumber: Int, comment: String, dateAdded: String) {
        self.treatmentNumber = treatmentNumber
        self.comment = comment
        self.dateAdded = dateAdded
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        treatmentNumber = try node.extract("treatmentNumber")
        comment = try node.extract("comment")
        dateAdded = try node.extract("dateAdded")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "treatmentNumber": treatmentNumber,
            "comment": comment,
            "dateAdded": dateAdded
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("feedbacks") { feedbacks in
            feedbacks.id()
            feedbacks.string("treatmentNumber")
            feedbacks.string("comment")
            feedbacks.string("dateAdded")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("feedbacks")
    }
}
