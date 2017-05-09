import Vapor
import HTTP

final class TransferController {
    
    func addRoutes(drop: Droplet){
        let transfer = drop.grouped(BasicAuthMiddleware(), StaticInfo.protect).grouped("transfers")
        transfer.get(handler: index)
        transfer.post(handler: create)
        transfer.get(Transfer.self, handler: show)
        transfer.patch(Transfer.self, handler: update)
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try Transfer.all().makeNode().converted(to: JSON.self)
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        var transfer = try request.transfer()
        try transfer.save()
        
        // update player's club id too
        let player_id = transfer.player_id!
        var player = try Player.query().filter("id", player_id).first()
        player?.club_id = Node.string(transfer.to_club)
        try player?.save()
        
        return transfer
    }
    
    func show(request: Request, transfer: Transfer) throws -> ResponseRepresentable {
        return transfer
    }
    
    func delete(request: Request, transfer: Transfer) throws -> ResponseRepresentable {
        try transfer.delete()
        return JSON([:])
    }
    
    func clear(request: Request) throws -> ResponseRepresentable {
        try Transfer.query().delete()
        return JSON([])
    }
    
    func update(request: Request, transfer: Transfer) throws -> ResponseRepresentable {
        let new = try request.transfer()
        var transfer = transfer
        transfer.player_id = new.player_id
        transfer.club_id = new.club_id
        transfer.to_club = new.to_club
        transfer.transfer_date = new.transfer_date
        try transfer.save()
        return transfer
    }
    
    func replace(request: Request, transfer: Transfer) throws -> ResponseRepresentable {
        try transfer.delete()
        return try create(request: request)
    }
    
//    func makeResource() -> Resource<Transfer> {
//        return Resource(
//            index: index,
//            store: create,
//            show: show,
//            replace: replace,
//            modify: update,
//            destroy: delete,
//            clear: clear
//        )
//    }
}

extension Request {
    func transfer() throws -> Transfer {
        guard let json = json else { throw Abort.badRequest }
        return try Transfer(node: json)
    }
}

