//
//  Meal.swift
//  Cookery
//
//  Created by Nicole Crawford on 3/9/17.
//  Copyright © 2017 Nicole Crawford. All rights reserved.
//

import CoreData
import UIKit

class Meal: NSManagedObject {
    
    class func findOrCreateMeal(matching mealDetails: MealDetails, in context: NSManagedObjectContext) throws -> Meal {
        let request: NSFetchRequest<Meal> = Meal.fetchRequest()
        request.predicate = NSPredicate(format: "name = %@ && date = %@", mealDetails.name, mealDetails.date as NSDate)
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1, "findOrCreateMeal -- database inconsistency")
                return matches[0]
            }
        } catch {
            throw error
        }
        
        let meal = Meal(context: context)
        meal.name = mealDetails.name
        meal.date = mealDetails.date as NSDate
        meal.recipes = NSSet(array: mealDetails.recipes)

        return meal
    }
    
}
