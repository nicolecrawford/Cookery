//
//  MealTableViewController.swift
//  Cookery
//
//  Created by Nicole Crawford on 3/14/17.
//  Copyright © 2017 Nicole Crawford. All rights reserved.
//

import UIKit

class MealTableViewController: UITableViewController {
    
    // Public API
    
    var meal: Meal? {
        didSet {
            recipes = meal!.recipes!.allObjects as?[Recipe]
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            let mealDate = formatter.string(from: meal!.date as! Date)
            title = "\(meal!.name!) \(mealDate)"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }


    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return recipes?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Recipe", for: indexPath)

        // Configure the cell...
        if recipes != nil, let recipeCell = cell as? MealTableViewCell {
            let recipe = recipes![indexPath.row]
            recipeCell.recipe = recipe
        }

        return cell
    }
    
    // Private Implementation
    private var recipes: [Recipe]? { didSet { tableView.reloadData() } }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let destinationViewController = segue.destination as? RecipeViewController, let cell = sender as? MealTableViewCell {
            destinationViewController.recipeID = Int(cell.recipe!.id)
        }
    }

}

class MealTableViewCell: UITableViewCell {
    
    var recipe: Recipe? { didSet { updateUI() } }
    
    private func updateUI() {
        if recipe != nil {
            textLabel?.text = recipe!.title
            detailTextLabel?.text = "Ready in \(recipe!.readyInMinutes) minutes"
        }
    }
}
