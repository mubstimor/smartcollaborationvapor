import Vapor
import VaporPostgreSQL

let drop = Droplet(
    preparations: [User.self],
    providers: [VaporPostgreSQL.Provider.self]
)

drop.get { request in
    return try JSON(node: [
        "message": "Hello, vapor!"
        ])
}

drop.get("hello") { request in
    return try JSON(node: [
        "message": "Hello, again!"
        ])
}

drop.get("players", Int.self) { request, players in
    return try JSON(node: [
        "message": "There are \(players) players here!"
        ])
}

drop.post("players"){ request in
    guard let name = request.data["name"]?.string else{
        throw Abort.badRequest
    }
    return try JSON(node:[
        "message":"Hello \(name)"
        ])
    
}

drop.get("dbversion") { request in
    if let db = drop.database?.driver as? PostgreSQLDriver{
        let version = try db.raw("SELECT version()")
        return try JSON(node: version)
    }else{
        return "NO DB Connection"
    }
}

drop.get("test"){ request in

    var user = User(name:"Timothy Mubiru")
    try user.save()
    return try JSON(node: User.all().makeNode())
}

drop.run()
