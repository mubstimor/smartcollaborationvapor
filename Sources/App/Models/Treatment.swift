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
    var injury_id : Node?
    var date_of_treatment: String
    var status_from_assessment: String
    var side_effects_from_previous_treatment: String
    var diet_suggestions: String
    var specialist_suggestions: String
    var specialist_id: Node?
    var exists: Bool = false
    
    init(injury_id: Node? = nil, dateOfTreatment: String, statusFromAssessment: String, sideEffectsFromPreviousTreatment: String, dietSuggestions: String, specialistSuggestions: String, specialist_id: Node? = nil) {
        self.injury_id = injury_id
        self.date_of_treatment = dateOfTreatment
        self.status_from_assessment = statusFromAssessment
        self.side_effects_from_previous_treatment = sideEffectsFromPreviousTreatment
        self.diet_suggestions = dietSuggestions
        self.specialist_suggestions = specialistSuggestions
        self.specialist_id = specialist_id
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        injury_id = try node.extract("injury_id")
        date_of_treatment = try node.extract("date_of_treatment")
        status_from_assessment = try node.extract("status_from_assessment")
        side_effects_from_previous_treatment = try node.extract("side_effects_from_previous_treatment")
        diet_suggestions = try node.extract("diet_suggestions")
        specialist_suggestions = try node.extract("specialist_suggestions")
        specialist_id = try node.extract("specialist_id")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "injury_id": injury_id,
            "date_of_treatment": date_of_treatment,
            "status_from_assessment": status_from_assessment,
            "side_effects_from_previous_treatment": side_effects_from_previous_treatment,
            "diet_suggestions": diet_suggestions,
            "specialist_suggestions": specialist_suggestions,
            "specialist_id": specialist_id
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("treatments") { treatments in
            treatments.id()
            treatments.parent(Injury.self, optional: false)
            treatments.string("date_of_treatment")
            treatments.string("status_from_assessment")
            treatments.string("side_effects_from_previous_treatment")
            treatments.string("diet_suggestions")
            treatments.string("specialist_suggestions")
            treatments.parent(Specialist.self, optional: false)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("treatments")
    }
}


extension Treatment{
    func comments() throws -> [Treatment] {
        return try children(nil, Treatment.self).all()
    }
}

