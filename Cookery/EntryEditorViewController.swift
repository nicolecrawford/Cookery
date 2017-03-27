//
//  EntryEditorViewController.swift
//  Cookery
//
//  Created by Nicole Crawford on 3/18/17.
//  Copyright © 2017 Nicole Crawford. All rights reserved.
//
// ImagePicker code from https://makeapppie.com/2016/06/28/how-to-use-uiimagepickercontroller-for-a-camera-and-photo-library-in-swift-3-0/

import CoreData
import UIKit

class EntryEditorViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Public API
    
    @IBOutlet weak var mealPicker: UIPickerView! {
        didSet {
            mealPicker.delegate = self
            mealPicker.dataSource = self
        }
    }
    @IBOutlet weak var entryTextView: UITextView!
    @IBOutlet weak var entryImageView: UIImageView!
    
    @IBOutlet weak var photoButton: UIBarButtonItem!
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true)
    }
    
    @IBAction func selectImage(_ sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let alert = UIAlertController(title: "Photo Options", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Camera", style: .default) {
                [weak self] (action: UIAlertAction) -> Void in
                self?.presentCamera()
            })
            alert.addAction(UIAlertAction(title: "Photo Library", style: .default) {
                [weak self] (action: UIAlertAction) -> Void in
                self?.presentPhotoLibrary()
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) {
                (action: UIAlertAction) -> Void in
                // do nothing
            })
            alert.popoverPresentationController?.barButtonItem = photoButton
            present(alert, animated: true, completion: nil)
        } else {
            presentPhotoLibrary()
        }
    }
    
    var meal: Meal?
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        getPossibleMeals()
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
        if entryImageView?.image == nil { navigationItem.rightBarButtonItem?.isEnabled = false }
    }
    
    // MARK: Image picker delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var chosenImage = UIImage()
        chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        entryImageView.image = chosenImage
        navigationItem.rightBarButtonItem?.isEnabled = true
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: Picker view delegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return meals.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let mealInRow = meals[row]
        let mealDate = formatter.string(from: mealInRow.date as! Date)
        return "\(mealInRow.name!) \(mealDate)"
    }
    
    // MARK: Picker view data source
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        meal = meals[row]
    }
    
    // Private implementation
    
    private var meals: [Meal] = [Meal]()
    
    private var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    private func getPossibleMeals() {
        if let context = container?.viewContext {
            let request: NSFetchRequest<Meal> = Meal.fetchRequest()
            request.predicate = NSPredicate(format: "entry = nil && date <= %@", NSDate())
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            do {
                let matches = try context.fetch(request)
                meals = matches
                if meals.count == 0 {
                    let alert = UIAlertController(title: "No Past Meals", message: "You must have at least one past meal not logged to use the log.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        self.presentingViewController?.dismiss(animated: true)
                    }))
                    present(alert, animated: true)
                }
                mealPicker.reloadAllComponents()
                if meals.count > 0 { meal = meals[0] }
            }
            catch {
                print(error)
            }
        }
    }
    
    private func presentCamera() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        imagePicker.cameraCaptureMode = .photo
        imagePicker.modalPresentationStyle = .fullScreen
        present(imagePicker,animated: true, completion: nil)
    }
    
    private func presentPhotoLibrary() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(imagePicker, animated: true, completion: nil)
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
        if identifier == "SaveNewEntry" {
            if entryImageView.image == nil || meal == nil {
                return false
            }
        }
        return true
    }
    
}
