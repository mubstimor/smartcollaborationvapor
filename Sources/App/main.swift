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

let account = AccountController()
account.addRoutes(drop: drop)

let league = LeagueController()
league.addRoutes(drop: drop)

let club = ClubController()
club.addRoutes(drop: drop)

drop.resource("countries", CountryController())
//drop.resource("leagues", LeagueController())
//drop.resource("clubs", ClubController())
drop.resource("players", PlayerController())
drop.resource("injuries", InjuryController())
drop.resource("treatments", TreatmentController())
drop.resource("feedbacks", FeedbackController())
drop.resource("subscriptions", SubscriptionController())
drop.resource("specialists", SpecialistController())


drop.run()
