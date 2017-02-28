import Vapor
import VaporPostgreSQL
import Auth

let drop = Droplet()

drop.preparations.append(Country.self)
drop.preparations.append(League.self)
drop.preparations.append(Club.self)
drop.preparations.append(Specialist.self)
drop.preparations.append(Player.self)
drop.preparations.append(Injury.self)
drop.preparations.append(Treatment.self)
drop.preparations.append(Subscription.self)
drop.preparations.append(Feedback.self)

drop.addConfigurable(middleware: AuthMiddleware(user: Specialist.self), name: "auth")

try drop.addProvider(VaporPostgreSQL.Provider.self)


let smart = SmartController()
smart.addRoutes(drop: drop)

let specialist = SpecialistController()
specialist.addRoutes(drop: drop)

drop.get("test"){ request in

//    var user = Specialist(email: "mubstimor@gmail.com", password: "sfdsrgeer", club: "Programmers United", country: "UK", league: "Devs")
//    try user.save()
//    return try JSON(node: Specialist.all().makeNode())
    return try JSON(node: [
        "message": "testing suspended temporarily!"
        ])
}

drop.run()
