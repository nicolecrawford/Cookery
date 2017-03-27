//
//  Recipe.swift
//  Cookery
//
//  Created by Nicole Crawford on 3/9/17.
//  Copyright © 2017 Nicole Crawford. All rights reserved.
//

import CoreData
import UIKit

class Recipe: NSManagedObject {

    class func findOrCreateRecipe(matching recipeDetails: DetailedRecipe, in context: NSManagedObjectContext) throws -> Recipe {
        let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        request.predicate = NSPredicate(format: "id = %d", recipeDetails.summary.id)
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1, "Recipe.findOrCreateRecipe -- database inconsistency")
                return matches[0]
            }
        } catch {
            throw error
        }

        let recipe = Recipe(context: context)
        recipe.id = Int32(recipeDetails.summary.id)
        recipe.title = recipeDetails.summary.title
        recipe.imageURL = recipeDetails.summary.imageUrl.absoluteString
        recipe.servings = Int16(recipeDetails.servings)
        recipe.readyInMinutes = Int16(recipeDetails.readyInMinutes)
        recipe.favorite = false
        recipe.sourceURL = recipeDetails.source
        
        for ingredient in recipeDetails.ingredients {
            if let newIngredient = try? Ingredient.findOrCreateIngredient(matching: ingredient, for: recipeDetails, in: context) {
                recipe.addToIngredients(newIngredient)
            }
        }
        for instruction in recipeDetails.instructions {
            if let newIngredient = try? Instruction.findOrCreateInstruction(matching: instruction, for: recipeDetails, in: context) {
                recipe.addToInstructions(newIngredient)
            }
        }
        
        return recipe
        
    }
    
    class func fetchRecipe(matching recipeDetails: DetailedRecipe, in context: NSManagedObjectContext) -> Recipe? {
        let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        request.predicate = NSPredicate(format: "id = %d", Int32(recipeDetails.summary.id))
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1, "Recipe.fetchRecipe -- database inconsistency")
                return matches[0]
            }
        } catch {
            print(error)
        }
        
        return nil
    }

}
