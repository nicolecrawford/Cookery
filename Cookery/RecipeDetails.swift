//
//  RecipeDetails.swift
//  Cookery
//
//  Created by Nicole Crawford on 3/7/17.
//  Copyright © 2017 Nicole Crawford. All rights reserved.
//

import Foundation

public struct DetailedRecipe {

    private(set) var ingredients: [(name: String, image: String)]
    private(set) var instructions: [(number: Int, step: String)]
    private(set) var summary: RecipeSummary
    private(set) var readyInMinutes: Int
    private(set) var servings: Int
    private(set) var source: String
}

public struct RecipeSummary {
    
    private(set) var id: Int
    private(set) var title: String
    private(set) var imageUrl: URL
    
}

public struct MealDetails {
    private(set) var name: String
    private(set) var date: Date
    private(set) var recipes: [Recipe]
}
