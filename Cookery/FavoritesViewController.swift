//
//  FavoritesViewController.swift
//  Cookery
//
//  Created by Nicole Crawford on 3/11/17.
//  Copyright © 2017 Nicole Crawford. All rights reserved.
//
// based off of https://spin.atomicobject.com/2015/12/23/swift-uipageviewcontroller-tutorial/

import CoreData
import UIKit

class FavoritesViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkFavorites()
    }
    
    
    // MARK: Page controller data source
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else { return nil }
        guard orderedViewControllersCount > nextIndex else { return nil }
        
        return orderedViewControllers[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        return orderedViewControllers[previousIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    
    // Private implementation
    
    private var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    private var orderedViewControllers: [UIViewController] = [UIViewController]()
    
    private var favoriteRecipes: [Recipe]?
    
    private func checkFavorites() {
        if let context = container?.viewContext {
            let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
            request.predicate = NSPredicate(format: "favorite = true")
            do {
                let matches = try context.fetch(request)
                if favoriteRecipes == nil || matches != favoriteRecipes! || matches.isEmpty {
                    favoriteRecipes = matches
                    orderedViewControllers.removeAll()
                    updateUI()
                } else {
                    favoriteRecipes = [Recipe]()
                }
            } catch {
                print(error)
            }
        }
    }
    
    private func updateUI() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if favoriteRecipes != nil && favoriteRecipes!.count > 0 {
            for recipe in favoriteRecipes! {
                if let viewController = storyboard.instantiateViewController(withIdentifier: "CardViewController") as? CardViewController {
                    viewController.recipe = recipe
                    orderedViewControllers.append(viewController)
                }
            }
        } else {
            let alert = UIAlertController(title: "No Favorites", message: "Search for recipes to add to your favorites!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] action in
                self?.tabBarController?.selectedIndex = 0 // switch to search
            }))
            present(alert, animated: true)
        }
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let destinationViewController = segue.destination as? RecipeViewController, let currentViewController = viewControllers![0] as? CardViewController {
            destinationViewController.recipeID = Int(currentViewController.recipe!.id)
        }
    }
    
}
