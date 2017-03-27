//
//  CardViewController.swift
//  Cookery
//
//  Created by Nicole Crawford on 3/11/17.
//  Copyright © 2017 Nicole Crawford. All rights reserved.
//

import UIKit

class CardViewController: UIViewController {
    
    // Public API
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var servingsLabel: UILabel!
    @IBOutlet weak var recipeNameLabel: UILabel!

    var recipe: Recipe?

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    // Private implementation
    
    private var cache: NSCache<AnyObject, AnyObject>? = (UIApplication.shared.delegate as? AppDelegate)?.cache
    
    private func updateUI() {
        if recipe != nil {
            recipeNameLabel.text = "\(recipe!.title!)"
            servingsLabel.text = "Servings: \(recipe!.servings)"
            timeLabel.text = "Ready in \(recipe!.readyInMinutes) minutes"
            
            if cache?.object(forKey: recipe?.id as AnyObject) != nil {
                view.backgroundColor = UIColor(patternImage: cache?.object(forKey: recipe?.id as AnyObject) as! UIImage)
            }
            else if let url = URL(string: recipe!.imageURL!) {
                DispatchQueue.global(qos: .userInitiated).async {
                    if let imageData = try? Data(contentsOf: url) {
                        DispatchQueue.main.async { [weak self] in
                            let image = UIImage(data: imageData)!
                            self?.view.backgroundColor = UIColor(patternImage: image)
                            self?.cache?.setObject(image, forKey: self?.recipe?.id as AnyObject)
                        }
                    }
                }
            }
            let blurEffect = UIBlurEffect(style: .light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.insertSubview(blurEffectView, at: 0)
        }
    }
    
}
