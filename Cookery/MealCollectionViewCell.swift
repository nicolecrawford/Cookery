//
//  MealCollectionViewCell.swift
//  Cookery
//
//  Created by Nicole Crawford on 3/11/17.
//  Copyright © 2017 Nicole Crawford. All rights reserved.
//

import UIKit

class MealCollectionViewCell: UICollectionViewCell {
    
    // Public API
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mealLabel: UILabel!
    
    var meal: Meal? { didSet { updateUI() } }
    
    
    // Private implementation
    
    private var recipes: [Recipe] = [Recipe]()
    
    private var imageIndex = 0
    
    private var cache: NSCache<AnyObject, AnyObject>? = (UIApplication.shared.delegate as? AppDelegate)?.cache
    
    private func updateUI() {
        if meal != nil {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            let mealDate = formatter.string(from: meal!.date as! Date)
            mealLabel.text = "\(meal!.name!) \(mealDate)"
            mealLabel.isAccessibilityElement = false
            accessibilityLabel = mealLabel.text
            recipes = meal!.recipes?.allObjects as! [Recipe]
            if !recipes.isEmpty {
                setImage(with: imageIndex, for: imageView)
                imageIndex += 1
                crossFadeImages()
            }
        }
    }
    
    private func crossFadeImages() {
        if imageIndex >= recipes.count { imageIndex = 0 }
        let secondImageView = UIImageView()
        setImage(with: imageIndex, for: secondImageView)
        secondImageView.frame = imageView.frame
        secondImageView.alpha = 0.0
        contentView.insertSubview(secondImageView, aboveSubview: imageView)
        
        UIView.animate(withDuration: 2.0, delay: 2.0, options: .curveEaseOut, animations: {
            secondImageView.alpha = 1.0
        }, completion: { [weak self] _ in
            self?.imageView.image = secondImageView.image
            secondImageView.removeFromSuperview()
            self?.imageIndex += 1
            self?.crossFadeImages()
        })
    }
    
    private func setImage(with imageIndex: Int, for view: UIImageView) {
        let imageUrl = recipes[imageIndex].imageURL!
        
        if cache?.object(forKey: recipes[imageIndex].id as AnyObject) != nil {
            view.image = cache?.object(forKey: recipes[imageIndex].id as AnyObject) as? UIImage
        }
        else if let url = URL(string: imageUrl) {
            DispatchQueue.global(qos: .userInitiated).async {
                if let imageData = try? Data(contentsOf: url) {
                    DispatchQueue.main.async { [weak self] _ in
                        let image = UIImage(data: imageData)!
                        view.image = image
                        self?.cache?.setObject(image, forKey: self?.recipes[imageIndex].id as AnyObject)
                    }
                }
            }
        }
    }
}

class MealCollectionViewSectionHeader: UICollectionReusableView {
    
    @IBOutlet weak var sectionNameLabel: UILabel!
}
