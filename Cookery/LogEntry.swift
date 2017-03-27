//
//  LogEntry.swift
//  Cookery
//
//  Created by Nicole Crawford on 3/17/17.
//  Copyright © 2017 Nicole Crawford. All rights reserved.
//

import CoreData
import UIKit

class LogEntry: NSManagedObject {
    
    class func findOrCreateLogEntry(matching image: UIImage, withText text: String, forMeal meal: Meal, in context: NSManagedObjectContext) throws -> LogEntry {
        let imageData = (UIImagePNGRepresentation(image) as NSData?)!
        
        let request: NSFetchRequest<LogEntry> = LogEntry.fetchRequest()
        request.predicate = NSPredicate(format: "image = %@ && text = %@", imageData, text)
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1, "LogEntry.findOrCreateLogEntry -- database inconsistency")
                return matches[0]
            }
        } catch {
            throw error
        }
        
        let logEntry = LogEntry(context: context)
        logEntry.image = imageData
        logEntry.text = text
        logEntry.meal = meal
        
        return logEntry
    }
}
