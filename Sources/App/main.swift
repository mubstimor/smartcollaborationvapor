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
drop.preparations.append(Fixture.self)

drop.addConfigurable(middleware: AuthMiddleware(user: Specialist.self), name: "auth")

try drop.addProvider(VaporPostgreSQL.Provider.self)


let smart = SmartController()
smart.addRoutes(drop: drop)

let account = AccountController()
account.addRoutes(drop: drop)

let league = LeagueController()
league.addRoutes(drop: drop)

let club = ClubController()
club.addRoutes(drop: drop)

let protect = ProtectMiddleware(error:
    Abort.custom(status: .forbidden, message: "Not authorized.!")
)

drop.grouped(BasicAuthMiddleware(), protect).group("api") { api in
    api.get("me") { request in
        return try JSON(node: request.user().makeNode())
    }
}


drop.resource("countries", CountryController())
//drop.resource("leagues", LeagueController())
//drop.resource("clubs", ClubController())
drop.resource("players", PlayerController())
drop.resource("injuries", InjuryController())
drop.resource("treatments", TreatmentController())
drop.resource("feedbacks", FeedbackController())
drop.resource("subscriptions", SubscriptionController())
drop.resource("specialists", SpecialistController())
drop.resource("fixtures", FixtureController())

drop.run()
