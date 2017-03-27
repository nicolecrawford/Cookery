//
//  RecipeSearchTableViewController.swift
//  Cookery
//
//  Created by Nicole Crawford on 3/3/17.
//  Copyright © 2017 Nicole Crawford. All rights reserved.
//

import CoreData
import UIKit

class RecipeSearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    // Public API

    var searchText: String? {
        didSet {
            searchBar.text = searchText
            searchBar.resignFirstResponder()
            recipes.removeAll()
            tableView.reloadData()
            fetchRecipes()
            title = "\(searchText!) Recipes"
        }
    }

    @IBOutlet weak var searchBar: UISearchBar! { didSet { searchBar.delegate = self } }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar == self.searchBar {
            searchText = searchBar.text
        }
    }
    
    
    // Private Implementation
    
    private var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer

    private var recipes = [Array<RecipeSummary>]()
    
    private func fetchRecipes() {
        Request.getRecipeSummaries(for: searchText!) { [weak self] newRecipes in
            DispatchQueue.main.async {
                self?.recipes.insert(newRecipes, at: 0)
                self?.tableView.insertSections([0], with: .fade)
                self?.updateDatabase(with: newRecipes)
            }
        }
    }
    
    private func updateDatabase(with newRecipes: [RecipeSummary]) {
        for summary in newRecipes {
            Request.getDetailedRecipe(for: summary) { [weak self] detailedRecipe in
                self?.container?.performBackgroundTask { context in
                    _ = try? Recipe.findOrCreateRecipe(matching: detailedRecipe, in: context)
                    try? context.save()
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = view.bounds.height
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return recipes.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Recipe", for: indexPath)
        let recipe = recipes[indexPath.section][indexPath.row]

        // Configure the cell...
        if let recipeCell = cell as? RecipeSearchTableViewCell {
            recipeCell.recipeSummary = recipe
        }
        
        return cell
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? RecipeViewController, let recipeCell = sender as? RecipeSearchTableViewCell {
            destinationViewController.recipeID = recipeCell.recipeSummary!.id
        }
    }

}
