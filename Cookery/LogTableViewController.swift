//
//  LogTableViewController.swift
//  Cookery
//
//  Created by Nicole Crawford on 3/17/17.
//  Copyright © 2017 Nicole Crawford. All rights reserved.
//

import CoreData
import HealthKit
import UIKit

class LogTableViewController: FetchedResultsTableViewController {
    
    // Public API
    
    @IBAction func saveNewEntry(from segue: UIStoryboardSegue) {
        if let editor = segue.source as? EntryEditorViewController, let context = container?.viewContext {
            let _ = try? LogEntry.findOrCreateLogEntry(matching: editor.entryImageView.image!, withText: editor.entryTextView.text, forMeal: editor.meal!, in: context)
            try? context.save()
            tableView.reloadData()
        }
    }
    
    var fetchedResultsController: NSFetchedResultsController<LogEntry>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem
        updateUI()
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Entry", for: indexPath)
        
        // Configure the cell...
        if let entryCell = cell as? LogTableViewCell, let entry = fetchedResultsController?.object(at: indexPath) {
            entryCell.mealNameLabel?.text = entry.meal?.name
            entryCell.entryImageView?.image = UIImage(data: entry.image as! Data)
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            entryCell.mealDateLabel?.text = formatter.string(from: entry.meal!.date as! Date)
            entryCell.entryTextView?.text = entry.text
        }
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            if let context = container?.viewContext, let entry = fetchedResultsController?.object(at: indexPath) {
                context.delete(entry)
                try? context.save()
            }
        }
    }
    
    
    // Private implementation
    
    private var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    private func updateUI() {
        if let context = container?.viewContext {
            let request: NSFetchRequest<LogEntry> = LogEntry.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "meal.date", ascending: false)]
            
            fetchedResultsController = NSFetchedResultsController<LogEntry>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController?.delegate = self
            try? fetchedResultsController?.performFetch()
            tableView.reloadData()
        }
    }
    
}

class LogTableViewCell: UITableViewCell {
    
    @IBOutlet weak var entryImageView: UIImageView!
    @IBOutlet weak var mealNameLabel: UILabel!
    @IBOutlet weak var mealDateLabel: UILabel!
    @IBOutlet weak var entryTextView: UITextView!
}
