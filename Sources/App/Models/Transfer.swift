//
//  Transfer.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 13/04/2017.
//
//

import Vapor
import Fluent

final class Transfer: Model {
    
    var id: Node?
    var player_id: Node?
    var from_club: Node?
    var to_club: String
    var transfer_date: String
    var exists: Bool = false
    
    init(player_id: Node? = nil, from_club: Node? = nil, to_club: String, transfer_date: String) {
        self.player_id = player_id
        self.from_club = from_club
        self.to_club = to_club
        self.transfer_date = transfer_date
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        player_id = try node.extract("player_id")
        from_club = try node.extract("from_club")
        to_club = try node.extract("to_club")
        transfer_date = try node.extract("transfer_date")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "player_id": player_id,
            "from_club": from_club,
            "to_club": to_club,
            "transfer_date": transfer_date
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("transfers") { transfers in
            transfers.id()
            transfers.parent(Player.self, optional: false)
            transfers.parent(Club.self, optional: false)
            transfers.string("to_club")
            transfers.string("transfer_date")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("transfers")
    }
}

