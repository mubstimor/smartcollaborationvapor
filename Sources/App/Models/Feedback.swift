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
    var treatment_id: Node?
    var comment: String
    var date_added: String
    var specialist_id: Node?
    var exists: Bool = false
    
    init(treatment_id: Node? = nil, comment: String, dateAdded: String, specialist_id: Node? = nil) {
        self.treatment_id = treatment_id
        self.comment = comment
        self.date_added = dateAdded
        self.specialist_id = specialist_id
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        treatment_id = try node.extract("treatment_id")
        comment = try node.extract("comment")
        date_added = try node.extract("date_added")
        specialist_id = try node.extract("specialist_id")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "treatment_id": treatment_id,
            "comment": comment,
            "date_added": date_added,
            "specialist_id": specialist_id
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("feedbacks") { feedbacks in
            feedbacks.id()
            feedbacks.parent(Treatment.self, optional: false)
            feedbacks.string("comment")
            feedbacks.string("date_added")
            feedbacks.parent(Specialist.self, optional: false)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("feedbacks")
    }
}
