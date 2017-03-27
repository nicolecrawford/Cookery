//
//  MealEditorViewController.swift
//  Cookery
//
//  Created by Nicole Crawford on 3/12/17.
//  Copyright © 2017 Nicole Crawford. All rights reserved.
//

import UIKit

class MealEditorViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Public API
    
    @IBOutlet weak var mealNameTextField: UITextField! { didSet { mealNameTextField.delegate = self } }
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var typePicker: UIPickerView!
    @IBOutlet weak var mealSelectionCell: MealSelectionTableViewCell!
    @IBOutlet weak var mealSelectionTableView: UITableView! {
        didSet {
            mealSelectionTableView.delegate = mealSelectionCell
            mealSelectionTableView.dataSource = mealSelectionCell
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true)
    }
    
    
    @IBAction func saveRecipeSelection(segue: UIStoryboardSegue) {
        if newSelections != nil && selections != newSelections! {
            selections = newSelections!
        }
    }
    
    var name: String {
        return (mealNameTextField?.text!.isEmpty)! ? type : (mealNameTextField?.text)!
    }
    
    var newSelections: [Recipe]?
    
    
    // Private implementation
    
    private var selections: [Recipe] = [Recipe]() {
        didSet {
            mealSelectionCell?.selections = selections
            mealSelectionTableView.reloadData()
        }
    }
    
    private enum MealType:String {
        case breakfast = "Breakfast"
        case lunch = "Lunch"
        case dinner = "Dinner"
        case snack = "Snack"
        case drink = "Drink"
        case brunch = "Brunch"
    }
    
    private let mealTypes: [MealType] = [.breakfast, .lunch, .dinner, .snack, .drink, .brunch]
    
    private var type: String = "Dinner"
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        typePicker.delegate = self
        typePicker.dataSource = self
        typePicker.selectRow(2, inComponent: 0, animated: true) // default meal type is Dinner
        typePicker.accessibilityHint = "Swipe up or down with one finger to select a meal type"
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
    
    // MARK: - Picker view data source

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        type = mealTypes[row].rawValue
    }
    
    // MARK: - Picker view delegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return mealTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return mealTypes[row].rawValue
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
            return tableView.bounds.size.width
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    
    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == "SaveMeal" && selections.isEmpty {
            handleNoRecipes()
            return false
        }
        return true
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let destinationViewController = segue.destination as? MealsCollectionViewController, !selections.isEmpty {
            destinationViewController.newMealDetails = MealDetails(name: name, date: datePicker.date, recipes: selections)
        }
    }
    
    private func handleNoRecipes() {
        let alert = UIAlertController(title: "Invalid Recipes", message: "A meal must have at least one recipe.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    
}


// code from FaceIt class demo
extension UITableView {
    func minimumSize(forSection section: Int) -> CGSize {
        var width: CGFloat = 0
        var height : CGFloat = 0
        for row in 0..<numberOfRows(inSection: section) {
            let indexPath = IndexPath(row: row, section: section)
            if let cell = cellForRow(at: indexPath) ?? dataSource?.tableView(self, cellForRowAt: indexPath) {
                let cellSize = cell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                width = max(width, cellSize.width)
                height += heightForRow(at: indexPath)
            }
        }
        return CGSize(width: width, height: height)
    }
    
    func heightForRow(at indexPath: IndexPath? = nil) -> CGFloat {
        if indexPath != nil, let height = delegate?.tableView?(self, heightForRowAt: indexPath!) {
            return height
        } else {
            return rowHeight
        }
    }
}


class MealSelectionTableViewCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    
    // Public API
    
    var selections: [Recipe]?
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selections?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Meal", for: indexPath)
        
        // Configure the cell...
        if let recipe = selections?[indexPath.row] {
            cell.textLabel?.text = recipe.title
        }
        
        return cell
    }
    
}
