//
//  MealsCollectionViewController.swift
//  Cookery
//
//  Created by Nicole Crawford on 3/11/17.
//  Copyright © 2017 Nicole Crawford. All rights reserved.
//

import CoreData
import UIKit

private let reuseIdentifier = "Meal"

class MealsCollectionViewController: UICollectionViewController {
    
    // Public API
    
    var newMealDetails: MealDetails?

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchMeals()
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(byReactingTo:)))
        longPressRecognizer.minimumPressDuration = 1.0
        longPressRecognizer.numberOfTouchesRequired = 1
        collectionView?.addGestureRecognizer(longPressRecognizer)
    }
    
    @IBAction func saveMeal(segue: UIStoryboardSegue) {
        if let context = container?.viewContext, newMealDetails != nil {
            if let newMeal = try? Meal.findOrCreateMeal(matching: newMealDetails!, in: context) {
                try? context.save()
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                let date = formatter.string(from: newMeal.date as! Date)
                if mealDates!.contains(date) {
                    let section = mealDates!.index(of: date)!
                    meals![date]?.insert(newMeal, at: 0)
                    collectionView?.insertItems(at: [IndexPath(row: 0, section: section)])
                }
                else {
                    mealDates?.insert(date, at: 0)
                    meals![date] = [newMeal]
                    let indices: IndexSet = [0]
                    collectionView?.insertSections(indices)
                }
            }
        }
    }
    
    func handleLongPress(byReactingTo gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state != UIGestureRecognizerState.ended { return }
        let point = gestureRecognizer.location(in: collectionView)
        if let indexPath = collectionView?.indexPathForItem(at: point) {
            let date = mealDates![indexPath.section]
            let meal = meals![date]![indexPath.row]
            let alert = UIAlertController(title: "Meal Options", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Set Reminder for \(meal.name!)", style: .default) {
                [weak self] (action: UIAlertAction) -> Void in
                self?.scheduleNotification(forMeal: meal)
                let formatter = DateFormatter()
                formatter.dateStyle = .full
                let date = formatter.string(from: meal.date as! Date)
                let alert = UIAlertController(title: "Reminder Scheduled", message: "You will be reminded on \(date) to make \(meal.name!)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            })
            alert.addAction(UIAlertAction(title: "Delete \(meal.name!)", style: .destructive) {
                [weak self] (action: UIAlertAction) -> Void in
                if let context = self?.container?.viewContext {
                    context.delete(meal)
                    try? context.save()
                    let date = (self?.mealDates![indexPath.section])!
                    self?.meals![date]!.remove(at: indexPath.row)
                    self?.collectionView?.deleteItems(at: [indexPath])
                }
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) {
                (action: UIAlertAction) -> Void in
                // do nothing
            })
            let cell = collectionView?.cellForItem(at: indexPath)
            alert.popoverPresentationController?.sourceView = cell
            alert.popoverPresentationController?.sourceRect = cell!.bounds
            present(alert, animated: true, completion: nil)
        }
    }
    
    // Private implementation
    
    private var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    private var mealDates: [String]?
    
    private var meals: [String: Array<Meal>]?
    
    private func fetchMeals() {
        if let context = container?.viewContext {
            let request: NSFetchRequest<Meal> = Meal.fetchRequest()
            do {
                let matches = try context.fetch(request)
                let result = sectionMatches(matches)
                meals = result.0
                mealDates = result.1
            } catch {
                print(error)
            }
        }
    }
    
    private func sectionMatches(_ matches: [Meal]) -> ([String: Array<Meal>], [String]) {
        var sectionedMealsDict = [String: Array<Meal>]()
        var sectionNames = [String]()
        for meal in matches {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            let date = formatter.string(from: meal.date as! Date)
            if var arrayForDate = sectionedMealsDict[date] {
                arrayForDate.append(meal)
                sectionedMealsDict.updateValue(arrayForDate, forKey: date)
            } else {
                sectionedMealsDict[date] = [meal]
                sectionNames.append(date)
            }
        }
        return (sectionedMealsDict, sectionNames)
    }
    
    private func scheduleNotification(forMeal meal: Meal) {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate?.scheduleNotification(forMeal: meal)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if let destinationViewController = segue.destination as? MealTableViewController, let cell = sender as? MealCollectionViewCell {
            destinationViewController.meal = cell.meal
        }
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return mealDates?.count ?? 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let date = mealDates?[section] {
            return meals?[date]?.count ?? 0
        }
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MealCollectionViewCell
        cell.isAccessibilityElement = true
        // Configure the cell
        if let date = mealDates?[indexPath.section], let meal = meals?[date]?[indexPath.row] {
            cell.meal = meal
        }
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! MealCollectionViewSectionHeader
        view.sectionNameLabel?.text = mealDates?[indexPath.section]
        view.isAccessibilityElement = true
        view.sectionNameLabel.isAccessibilityElement = false
        view.accessibilityLabel = "Section Header: \(view.sectionNameLabel!.text)"
        
        return view
    }

}
