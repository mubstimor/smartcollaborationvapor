//
//  Treatment.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 28/02/2017.
//
//

import Vapor
import Fluent

final class Treatment: Model {
    var id: Node?
    var dateOfTreatment: String
    var statusFromAssessment: String
    var sideEffectsFromPreviousTreatment: String
    var dietSuggestions: String
    var specialistSuggestions: String
    var specialist: String
    var exists: Bool = false
    
    init(dateOfTreatment: String, statusFromAssessment: String, sideEffectsFromPreviousTreatment: String, dietSuggestions: String, specialistSuggestions: String, specialist: String) {
        self.dateOfTreatment = dateOfTreatment
        self.statusFromAssessment = statusFromAssessment
        self.sideEffectsFromPreviousTreatment = sideEffectsFromPreviousTreatment
        self.dietSuggestions = dietSuggestions
        self.specialistSuggestions = specialistSuggestions
        self.specialist = specialist
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        dateOfTreatment = try node.extract("dateOfTreatment")
        statusFromAssessment = try node.extract("statusFromAssessment")
        sideEffectsFromPreviousTreatment = try node.extract("sideEffectsFromPreviousTreatment")
        dietSuggestions = try node.extract("dietSuggestions")
        specialistSuggestions = try node.extract("specialistSuggestions")
        specialist = try node.extract("specialist")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "dateOfTreatment": dateOfTreatment,
            "statusFromAssessment": statusFromAssessment,
            "sideEffectsFromPreviousTreatment": sideEffectsFromPreviousTreatment,
            "dietSuggestions": dietSuggestions,
            "specialistSuggestions": specialistSuggestions,
            "specialist": specialist
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("treatments") { treatments in
            treatments.id()
            treatments.string("dateOfTreatment")
            treatments.string("statusFromAssessment")
            treatments.string("sideEffectsFromPreviousTreatment")
            treatments.string("dietSuggestions")
            treatments.string("specialistSuggestions")
            treatments.string("specialist")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("treatments")
    }
}

