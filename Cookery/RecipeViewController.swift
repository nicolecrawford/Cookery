//
//  RecipeViewController.swift
//  Cookery
//
//  Created by Nicole Crawford on 3/7/17.
//  Copyright © 2017 Nicole Crawford. All rights reserved.
//

import AVFoundation
import CoreData
import UIKit

class RecipeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Public API
    
    @IBOutlet weak var segmentedControl: UISegmentedControl! {
        didSet {
            segmentedControl.addTarget(self, action: #selector(indexChanged(sender:)), for: UIControlEvents.valueChanged)
            //updateUI()
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    @IBOutlet weak var recipeNameLabel: UILabel!
    
    @IBOutlet weak var servingsLabel: UILabel! {
        didSet {
            if recipe != nil {
                recipeNameLabel?.text = recipe!.title
                readyInMinutesLabel?.text = "Ready in \(recipe!.readyInMinutes) Minutes"
                servingsLabel?.text = "Servings: \(recipe!.servings)"
            }
        }
    }
    
    @IBOutlet weak var readyInMinutesLabel: UILabel!
    
    @IBOutlet weak var faveButton: UIBarButtonItem!
    
    @IBOutlet weak var printButton: UIBarButtonItem!
    
    @IBAction func toggleFavorite(_ sender: UIBarButtonItem) {
        if recipe != nil, sender == faveButton, let context = container?.viewContext {
            recipe!.favorite = !recipe!.favorite
            faveButton.image = (recipe!.favorite ? UIImage(named:"favorite.png"): UIImage(named:"add_favorite.png"))
            try? context.save()
            if (recipe?.favorite)! {
                faveButton.accessibilityLabel = "Remove Favorite"
            } else {
                faveButton.accessibilityLabel = "Add Favorite"
            }
        }
    }
    
    @IBAction func printRecipe(_ sender: UIBarButtonItem) {
        if recipe != nil {
            let image = UIImage(view: view)
            let printInfo = UIPrintInfo(dictionary: nil)
            printInfo.outputType = .general
            printInfo.jobName = recipe!.title!
            
            let printController = UIPrintInteractionController.shared
            printController.printInfo = printInfo
            printController.printingItem = image
            printController.present(from: view.frame, in: view, animated: true, completionHandler: nil)
        }
    }
    
    var recipeID: Int? {
        didSet {
            instructions.removeAll()
            ingredients.removeAll()
            tableView?.reloadData()
            updateUI()
            //title = recipeSummary?.title
        }
    }
    
    private var recipe: Recipe?
    
    func indexChanged(sender: UISegmentedControl) {
        inCookingMode = (segmentedControl.selectedSegmentIndex == 1)
    }
    
    private var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    private var instructions = [Instruction]()
    private var ingredients = [Ingredient]()
    
    private var inCookingMode: Bool = false {
        didSet {
            tableView.reloadData()
        }
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (instructions.count > 0 && ingredients.count > 0) ? 2: 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return ingredients.count
        default:
            return instructions.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeAttribute", for: indexPath)
        cell.isAccessibilityElement = false
        // Configure the cell...
        if let attributeCell = cell as? RecipeAttributeTableViewCell {
            attributeCell.inCookingMode = inCookingMode
            if indexPath.section == 0 {
                let ingredient = ingredients[indexPath.row]
                attributeCell.textView?.text = ingredient.name
            } else {
                let attribute = instructions[indexPath.row]
                attributeCell.textView?.text = "\(attribute.number)\t\(attribute.step!)"
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Ingredients"
        default:
            return "Directions"
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView?.estimatedRowHeight = tableView.rowHeight
        tableView?.rowHeight = UITableViewAutomaticDimension
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(speak(byReactingTo:)))
        longPressRecognizer.minimumPressDuration = 1.0
        longPressRecognizer.numberOfTouchesRequired = 1
        tableView.addGestureRecognizer(longPressRecognizer)
    }
    
    
    // Private Implementation
    
    private func updateUI() {
        if recipeID != nil, let context = container?.viewContext {
            let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
            request.predicate = NSPredicate(format: "id = %d", recipeID!)
            do {
                let matches = try context.fetch(request)
                if matches.count > 0 {
                    assert(matches.count == 1)
                    recipe = matches[0]
                    DispatchQueue.main.async { [weak self] in
                        if let newIngredients = self?.recipe?.ingredients?.allObjects as? [Ingredient], let newInstructions = self?.recipe?.instructions?.allObjects as? [Instruction] {
                            self?.ingredients.append(contentsOf: newIngredients.sorted { $0.name! < $1.name! })
                            self?.instructions.append(contentsOf: newInstructions.sorted { $0.number < $1.number })
                            self?.tableView?.insertSections([0, 1], with: .fade)
                        }
                        self?.faveButton.image = ((self?.recipe?.favorite)! ? UIImage(named:"favorite.png"): UIImage(named:"add_favorite.png"))
                        if (self?.recipe?.favorite)! {
                            self?.faveButton.accessibilityLabel = "Remove Favorite"
                        } else {
                            self?.faveButton.accessibilityLabel = "Add Favorite"
                        }
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    
    func speak(byReactingTo gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state != UIGestureRecognizerState.ended { return }
        let point = gestureRecognizer.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: point) {
            let utterance: AVSpeechUtterance = (indexPath.section == 0) ? AVSpeechUtterance(string: ingredients[indexPath.row].name!) : AVSpeechUtterance(string: instructions[indexPath.row].step!)
            let synthesizer = AVSpeechSynthesizer()
            synthesizer.speak(utterance)
        }
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let navController = segue.destination as? UINavigationController, let destinationViewController = navController.topViewController as? SourceUrlViewController {
            destinationViewController.sourceUrl = recipe?.sourceURL
        }
    }
    
}

// an extension to covert the view to an image
// taken from http://stackoverflow.com/questions/30696307/how-to-convert-a-uiview-to-a-image
extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage!)!)
    }
}

class RecipeAttributeTableViewCell: UITableViewCell {
    
    // Public API
    
    @IBOutlet weak var textView: UITextView!
    
    var inCookingMode: Bool = false
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if inCookingMode { strikethrough(selected) }
    }
    
    // Private implementation
    
    private func strikethrough(_ selected: Bool) {
        let text = NSMutableAttributedString(attributedString: textView.attributedText)
        let nsrange = NSRange(location: 0, length: text.length)
        
        let styleValue = selected ? NSUnderlineStyle.styleSingle.rawValue : NSUnderlineStyle.styleNone.rawValue
        text.addAttribute(NSStrikethroughStyleAttributeName, value: styleValue, range: nsrange)
        textView.attributedText = text
        if selected {
            textView.accessibilityLabel = "completed: \(textView.text!)"
        } else {
            textView.accessibilityLabel = textView.text
        }
    }
}

