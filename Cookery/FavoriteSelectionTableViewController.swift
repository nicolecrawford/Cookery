//
//  FavoriteSelectionTableViewController.swift
//  Cookery
//
//  Created by Nicole Crawford on 3/12/17.
//  Copyright © 2017 Nicole Crawford. All rights reserved.
//

import CoreData
import UIKit

class FavoriteSelectionTableViewController: UITableViewController {
    
    // Public API
    
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true)
    }
    
    
    var selections: [Recipe]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        getFavorites()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let popoverPresentationController = navigationController?.popoverPresentationController {
            if popoverPresentationController.arrowDirection != .unknown {
                navigationItem.leftBarButtonItem = nil
            }
        }
        var size = tableView.minimumSize(forSection: 0)
        size.height -= tableView.heightForRow(at: IndexPath(row: 1, section: 0))
        size.height += size.width
        preferredContentSize = size
    }
    
    // Private Implementation
    
    private var favorites: [Recipe]?
    
    private var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    private func getFavorites() {
        if let context = container?.viewContext {
            let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
            request.predicate = NSPredicate(format: "favorite = true")
            do {
                let matches = try context.fetch(request)
                favorites = matches
                if favorites == nil || favorites!.count == 0 {
                    navigationItem.rightBarButtonItem?.isEnabled = false
                } else {
                    navigationItem.rightBarButtonItem?.isEnabled = true
                }
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites?.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Recipe", for: indexPath)
        
        // Configure the cell...
        if let recipeCell = cell as? FavoriteSelectionTableViewCell, let recipe = favorites?[indexPath.row] {
            recipeCell.recipe = recipe
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if favorites != nil && indexPath.row < favorites!.count {
            return 150 // max height for image
        }
        return UITableViewAutomaticDimension
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let destinationViewController = segue.destination as? MealEditorViewController {
            if let indexPaths = tableView.indexPathsForSelectedRows, favorites != nil {
                destinationViewController.newSelections = indexPaths.map { favorites![$0.row] }
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == "SaveRecipeSelections" && (favorites == nil || favorites!.isEmpty) {
            return false
        }
        return true
    }
    
    
}

class FavoriteSelectionTableViewCell: UITableViewCell {
    
    // Public API
    
    var recipe: Recipe? { didSet { updateUI() } }
    
    @IBOutlet weak var mealSwitch: UISwitch!
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var recipeImageView: UIImageView!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        mealSwitch.setOn(selected, animated: true)
    }
    
    
    // Private implementation
    
    private var cache: NSCache<AnyObject, AnyObject>? = (UIApplication.shared.delegate as? AppDelegate)?.cache
    
    private func updateUI() {
        if recipe != nil {
            recipeNameLabel.text = "\(recipe!.title!)"
            if isSelected { accessoryType = .checkmark }
            
            if cache?.object(forKey: recipe?.id as AnyObject) != nil {
                recipeImageView?.image = cache?.object(forKey: recipe?.id as AnyObject) as? UIImage
            }
            else if let url = URL(string: recipe!.imageURL!) {
                DispatchQueue.global(qos: .userInitiated).async {
                    if let imageData = try? Data(contentsOf: url) {
                        DispatchQueue.main.async { [weak self] in
                            let image = UIImage(data: imageData)!
                            self?.recipeImageView?.image = image
                            self?.cache?.setObject(image, forKey: self?.recipe?.id as AnyObject)
                        }
                    }
                }
            }
        }
    }
}
