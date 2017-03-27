//
//  Ingredient.swift
//  Cookery
//
//  Created by Nicole Crawford on 3/9/17.
//  Copyright © 2017 Nicole Crawford. All rights reserved.
//

import CoreData
import UIKit

class Ingredient: NSManagedObject {

    class func findOrCreateIngredient(matching detailedIngredient: (name: String, image: String), for recipe: DetailedRecipe, in context: NSManagedObjectContext) throws -> Ingredient {
        let request: NSFetchRequest<Ingredient> = Ingredient.fetchRequest()
        request.predicate = NSPredicate(format: "name = %@ && recipe.id = %d", detailedIngredient.name, recipe.summary.id)
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1, "Ingredient.findOrCreateIngredient -- database inconsistency")
                return matches[0]
            }
        } catch {
            throw error
        }
        
        let ingredient = Ingredient(context: context)
        ingredient.name = detailedIngredient.name
        ingredient.imageURL = detailedIngredient.image
        
        return ingredient
    }
}
