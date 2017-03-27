//
//  Instruction.swift
//  Cookery
//
//  Created by Nicole Crawford on 3/9/17.
//  Copyright © 2017 Nicole Crawford. All rights reserved.
//

import CoreData
import UIKit

class Instruction: NSManagedObject {

    class func findOrCreateInstruction(matching direction: (number: Int, step: String), for recipe: DetailedRecipe, in context: NSManagedObjectContext) throws -> Instruction {
        let request: NSFetchRequest<Instruction> = Instruction.fetchRequest()
        request.predicate = NSPredicate(format: "step = %@ && recipe.id = %d", direction.step, recipe.summary.id)
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1, "Instruction.findOrCreateInstruction -- database inconsistency")
                return matches[0]
            }
        } catch {
            throw error
        }
        
        let instruction = Instruction(context: context)
        instruction.step = direction.step
        instruction.number = Int16(direction.number)
        
        return instruction
    }
}
