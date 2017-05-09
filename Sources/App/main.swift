import Vapor
import VaporPostgreSQL
import Auth
import Sessions
import Cookies
import Foundation
import HTTP

let drop = Droplet()

do {
    drop.middleware.insert(try CORSMiddleware(configuration: drop.config), at: 0)
} catch {
    fatalError("Error creating CORSMiddleware, please check that you've setup cors.json correctly.")
}

let memory = MemorySessions()
let sessions = SessionsMiddleware(sessions: memory)

drop.preparations.append(Country.self)
drop.preparations.append(League.self)
drop.preparations.append(Club.self)
drop.preparations.append(Specialist.self)
drop.preparations.append(Player.self)
drop.preparations.append(Injury.self)
drop.preparations.append(Treatment.self)
drop.preparations.append(Subscription.self)
drop.preparations.append(Feedback.self)
drop.preparations.append(Fixture.self)
drop.preparations.append(Transfer.self)
drop.preparations.append(KeyConcern.self)

let auth = AuthMiddleware(user: Specialist.self) { value in
    return Cookie(
        name: "vapor-auth",
        value: value,
        expires: Date().addingTimeInterval(60 * 60 * 24 * 365), // 24 hours x 365 days
        secure: true,
        httpOnly: true
    )
}

drop.middleware.append(auth)

//drop.addConfigurable(middleware: AuthMiddleware(user: Specialist.self), name: "auth")
//drop.addConfigurable(middleware: BasicAuthMiddleware, name: "basic")
drop.middleware.append(BasicAuthMiddleware())
drop.middleware.append(sessions)

try drop.addProvider(VaporPostgreSQL.Provider.self)


let smart = SmartController()
smart.addRoutes(drop: drop)

let account = AccountController()
account.addRoutes(drop: drop)

let league = LeagueController()
league.addRoutes(drop: drop)

let specialist = SpecialistController()
specialist.addRoutes(drop: drop)

let club = ClubController()
club.addRoutes(drop: drop)

let injury = InjuryController()
injury.addRoutes(drop: drop)

let treatment = TreatmentController()
treatment.addRoutes(drop: drop)

let player = PlayerController()
player.addRoutes(drop: drop)

let concern = KeyConcernController()
concern.addRoutes(drop: drop)

let feedback = FeedbackController()
feedback.addRoutes(drop: drop)

let subscription = SubscriptionController()
subscription.addRoutes(drop: drop)

let transfer = TransferController()
transfer.addRoutes(drop: drop)

let protect = ProtectMiddleware(error:
    Abort.custom(status: .forbidden, message: "Not authorized.!")
)

drop.grouped(BasicAuthMiddleware(), protect).group("api") { api in
    api.get("me") { request in
        return try JSON(node: request.user().makeNode())
    }
}

drop.get{ request in
    return try JSON(node: [
        "message": "Hello, welcome!"
        ])
}

drop.get("clubs_list"){ request in
    return try JSON(node: Club.all().makeNode())
}

drop.resource("countries", CountryController())
//drop.resource("leagues", LeagueController())
//drop.resource("clubs", ClubController())
//drop.resource("players", PlayerController())
//drop.resource("injuries", InjuryController())
//drop.resource("treatments", TreatmentController())
//drop.resource("feedbacks", FeedbackController())
//drop.resource("subscriptions", SubscriptionController())
//drop.resource("specialists", SpecialistController())
drop.resource("fixtures", FixtureController())
//drop.resource("transfers", TransferController())

drop.run()
