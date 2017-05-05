//
//  SmartController.swift
//  SmartCollaborationVapor
//
//  Created by Timothy Mubiru on 28/02/2017.
//
//

import Vapor
import HTTP
import VaporPostgreSQL
import Foundation

final class SmartController{
    
    func addRoutes(drop: Droplet){
    
        drop.get(handler: index)
        drop.get("dbversion", handler: dbversion)
        drop.post("name", handler: postName)
        drop.post("clubinjuries", handler: clubInjuries)
        drop.post("clubinjury_trends", handler: clubInjuryTrends)
        drop.get("appointments", handler: appointments)
        drop.get("fixtures_today", handler: get_todays_fixtures)
        drop.post("club_subscription", handler: create_club_subscription)
        drop.post("paymentupdates", handler: processPayments)
        drop.post("updatepackage", handler: updatePackage)
        drop.post("club_appointments", handler: clubSpecialistAppointments)
    }

    func dbversion(request: Request) throws -> ResponseRepresentable{
    
        if let db = drop.database?.driver as? PostgreSQLDriver{
            let version = try db.raw("SELECT version()")
            return try JSON(node: version)
        }else{
            return "NO DB Connection"
        }
    }
    
    func postName(request: Request) throws -> ResponseRepresentable{
    
        guard let name = request.data["name"]?.string else{
            throw Abort.badRequest
        }
        return try JSON(node:[
            "message":"Hello \(name)"
            ])
    }
    
    func clubInjuries(request: Request) throws -> ResponseRepresentable{
        
        guard let club_id = request.data["club_id"]?.string else{
            throw Abort.badRequest
        }

        let injuries = try Injury.query()
                        .union(Player.self)
                        .filter(Player.self, "club_id", .in, [club_id]).all()
        return try JSON(injuries.makeNode())
    }
    
    func clubInjuryTrends(request: Request) throws -> ResponseRepresentable{
        
        guard let club_id = request.data["club_id"]?.string else{
            throw Abort.badRequest
        }
        
        let injuries = try Injury.query()
            .union(Player.self)
            .filter(Player.self, "club_id", .in, [club_id]).all()
        
        let sortedInjuryList = injuries.sorted(by: { Date().convertStringToDate(dateString: $0.time_of_injury) > Date().convertStringToDate(dateString: $1.time_of_injury) })

//        let index = str.index(str.startIndex, offsetBy: 5)
//        str.substring(to: index)
        
        let groupedData = sortedInjuryList.group(by: { $0.time_of_injury.substring(to: ($0.time_of_injury.index(($0.time_of_injury.startIndex), offsetBy: 7))) })
        
        var result: [String: Int] = [:]
        
        for set in groupedData {
            
            var injuryStringArray:[String] = []
            
            // update injury data
            for injury in set.value {
                injuryStringArray.append(injury.name)
            }
            
            result[set.key] = injuryStringArray.count
//            print("key for \(set.value)")
            
        }
        
//        for injury in injuries {
//            
//            let injury_date = Date().convertStringToDate(dateString: injury.time_of_injury)
//            let calendar = Calendar.autoupdatingCurrent
//            let components = calendar.dateComponents([.hour, .minute], from: injury_date)
//            let year = components.year
//            let month = components.month
//            
//        }

        print("response data \(result)")
//        return try JSON(node: ["response": "\(result)" ])
        return try JSON(result.makeNode())
        
    }
    
    
    func clubSpecialistAppointments(request: Request) throws -> ResponseRepresentable{
        
        guard let club_id = request.data["club_id"]?.string else{
            throw Abort.badRequest
        }
        
        guard let club = try Club.find(club_id) else{
            throw Abort.custom(status: .badRequest, message: "Unable to find specialists")
        }
        
        let specialists = try club.specialists()
        
        // loop through specialists and add each one's treatments to response
        var specialist_treatments:[Treatment] = []
        var response: [Node] = []
        
        for(specialist) in specialists {

            var playerName = ""
            var injuryName = ""
            
            print(specialist.name)
            let treatments = try specialist.treatments()
            
            for treatment in treatments {
//                print("injury id = ")
//                print(treatment.injury_id!)
                
                let injuryId = treatment.injury_id!
                let injury = try Injury.find(injuryId)
                injuryName = (injury?.name)!
//                print("player from injury \((injury?.player_id)!)")
                
                let player = try Player.find((injury?.player_id)!)
//                print("Player name: \(player?.name)")
                playerName = (player?.name)!
                
                let specialist_id = treatment.specialist_id
                let specialist = try Specialist.find(specialist_id!)
                
                // compare dates
                let today = Date().getCurrentDate()
                let app_time = treatment.next_appointment
//                print("today is \(today)")
//                print("APP TIME is \(app_time)")
                let appointment_time = Date().convertStringToDate(dateString: app_time)
                let now = Date().convertStringToDate(dateString: today)
                
                if appointment_time < now {
                    continue
                }
                
                let object = try Node(node: [
                    "player": playerName,
//                    "treatment": treatment,
                    "specialist": specialist?.name,
                    "injury": injuryName,
                    "appointment_time": app_time
                    
                    ])
                
                response += object
            }
            
            specialist_treatments += treatments
        }
        
//        let injuries = try Injury.query()
//            .union(Player.self)
//            .filter(Player.self, "club_id", .in, [club_id]).all()
        
        return try JSON(response.makeNode())
    }
    
    // assign user to default subscription package
    func create_club_subscription(request: Request) throws -> ResponseRepresentable{
      
        /*
        guard let club_id = request.data["club_id"]?.string else{
            throw Abort.badRequest
        } */
        
        guard let email = request.data["email"]?.string else{
            throw Abort.badRequest
        }
        
        // if user is the first to register from a given club, create a sub package for them
        //if try Specialist.query().filter("club_id", club_id).first() == nil {
            
            let dictionary:Node = [
                "email": Node.string(email)
            ]
            
            // send request to stripe server
            let stripeResponse = try drop.client.post("https://smartcollaborationstripe.herokuapp.com/customer.php", headers: [
                "Content-Type": "application/x-www-form-urlencoded"
                ], body: Body.data( Node(dictionary).formURLEncoded()))
        
        
            return try JSON(node:[
                "message": stripeResponse.json!
                ])

        //}else{
          //  return try JSON(node:[
          //      "message":"Unable to create package"
          //      ])
        //}

       
    }
    
    func processPayments(request: Request) throws -> ResponseRepresentable{
        
        guard let customer_id = request.data["customer_id"]?.string else{
            throw Abort.badRequest
        }
        
        guard let amount = request.data["amount"]?.string else{
            throw Abort.badRequest
        }
        
        guard let status = request.data["status"]?.string else{
            throw Abort.badRequest
        }
        
        guard var subscription = try Subscription.query().filter("payment_id", customer_id).first() else{
            throw Abort.custom(status: .badRequest, message: "Unable to find subscription")
        }
        // update returned subscription object
        subscription.amount_paid = Double(amount)!
        subscription.status = status
        try subscription.save()
        return try JSON(subscription.makeNode())
    }
    
    func updatePackage(request: Request) throws -> ResponseRepresentable{
        
        guard let customer_id = request.data["payment_id"]?.string else{
            throw Abort.badRequest
        }
        
        guard let amount = request.data["amount_paid"]?.string else{
            throw Abort.badRequest
        }
        
        guard let date_paid = request.data["date_paid"]?.string else{
            throw Abort.badRequest
        }
        
        guard let next_payment = request.data["date_of_next_payment"]?.string else{
            throw Abort.badRequest
        }
        
        guard let status = request.data["status"]?.string else{
            throw Abort.badRequest
        }
        
        guard let sub_package = request.data["package"]?.string else{
            throw Abort.badRequest
        }
        
        var subscription = try Subscription.query().filter("payment_id", customer_id).first()
        // update returned subscription object
        subscription?.amount_paid = Double(amount)!
        subscription?.status = status
        subscription?.date_of_next_payment = next_payment
        subscription?.date_paid = date_paid
        subscription?.package = sub_package
        try subscription?.save()
        return try JSON(subscription!.makeNode())
    }


    
    func appointments(request: Request) throws -> ResponseRepresentable{
        
        let appointments = try Treatment.query().union(Injury.self)
            .union(Specialist.self).all()
        return try JSON(appointments.makeNode())
    }
    
    func get_todays_fixtures(request: Request) throws -> ResponseRepresentable{
        
//        guard let game_date = request.data["game_date"]?.string else{
//            throw Abort.badRequest
//        }
        
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let today = dateFormatter.string(from: currentDate) // use current date
        
        let fixture = try Fixture.query().filter("game_date", today).all()
        return try JSON(fixture.makeNode())
    }
    
    func index(request: Request) throws -> ResponseRepresentable{
    
        return try JSON(node: [
            "message": "Hello, welcome!"
            ])
    }
    
    
}

extension Date {
    
    /*
     * Based on http://stackoverflow.com/questions/36861732/swift-convert-string-to-date
     */
    
    func getCurrentDate() -> String{
        // get current date
        let currentDate = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let date_of_treatment = dateFormatter.string(from: currentDate) // use current time
        
        return date_of_treatment
    }
    
    func convertStringToDate(dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        print("received \(dateString)")
        let newDate = dateFormatter.date(from: dateString)
//        print("date is \(newDate)")
        return newDate!
    }
    
}

/*
 * categorise data based on 
 * http://stackoverflow.com/questions/31220002/how-to-group-by-the-elements-of-an-array-in-swift
 */
public extension Sequence {
    func group<U: Hashable>(by key: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
        var categories: [U: [Iterator.Element]] = [:]
        for element in self {
            let key = key(element)
            if case nil = categories[key]?.append(element) {
                categories[key] = [element]
            }
        }
        return categories
    }
}
