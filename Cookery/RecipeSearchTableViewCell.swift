//
//  RecipeSearchTableViewCell.swift
//  Cookery
//
//  Created by Nicole Crawford on 3/4/17.
//  Copyright © 2017 Nicole Crawford. All rights reserved.
//

import UIKit

class RecipeSearchTableViewCell: UITableViewCell {
    
    // Public API
    
    var recipeSummary: RecipeSummary? { didSet { updateUI() } }

    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var recipeLabel: UILabel!
    
    // Private Implementation
    
    private var cache: NSCache<AnyObject, AnyObject>? = (UIApplication.shared.delegate as? AppDelegate)?.cache
    
    private func updateUI() {
        recipeLabel.text = recipeSummary?.title
        if cache?.object(forKey: recipeSummary?.id as AnyObject) != nil {
            recipeImageView?.image = cache?.object(forKey: recipeSummary?.id as AnyObject) as? UIImage
        }
        else if let url = recipeSummary?.imageUrl {
            DispatchQueue.global(qos: .userInitiated).async {
                if let imageData = try? Data(contentsOf: url) {
                    DispatchQueue.main.async { [weak self] in
                        let image = UIImage(data: imageData)!
                        self?.recipeImageView?.image = image
                        self?.cache?.setObject(image, forKey: self?.recipeSummary?.id as AnyObject)
                    }
                }
            }
        }
    }
    

}
