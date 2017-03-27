//
//  Request.swift
//  Cookery
//
//  Created by Nicole Crawford on 3/3/17.
//  Copyright © 2017 Nicole Crawford. All rights reserved.
//
// based off of code from http://mrgott.com/swift-programing/30-work-with-rest-api-in-swift-3-and-xcode-8-using-urlsession-and-jsonserialization

import Foundation
import SwiftyJSON

private let apiKey: String = "YOUR_API_KEY_HERE"
private let baseUri: String = "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/"
private let imageBaseUri: String = "https://spoonacular.com/recipeImages/"
private let recipeCount = 3

public class Request: NSObject {

    class func getRecipeSummaries(for query: String, _ handler: @escaping ([RecipeSummary]) -> Void) {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let url = URL(string: "\(baseUri)recipes/search?instructionsRequired=true&query=\(encodedQuery)&number=\(recipeCount)")!
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-Mashape-Key")
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                let json = JSON(data: data!)
                var recipes: [RecipeSummary] = [RecipeSummary]()
                for result in json["results"].arrayValue {
                    recipes.append(RecipeSummary(id: result["id"].intValue, title: result["title"].stringValue, imageUrl: URL(string: "\(imageBaseUri)\(result["image"].stringValue.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)")!))
                }
                handler(recipes)
            }
        }
        task.resume()
    }
    
    class func getDetailedRecipe(for summary: RecipeSummary, _ handler: @escaping (DetailedRecipe) -> Void) {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let url = URL(string: "\(baseUri)recipes/\(summary.id)/information")!
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-Mashape-Key")
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                let json = JSON(data: data!)
                let source = json["sourceUrl"].stringValue
                let instructions: [(number: Int, step: String)] = json["analyzedInstructions"].arrayValue[0]["steps"].arrayValue.map {
                    (number: $0["number"].intValue, step: $0["step"].stringValue)
                }

                let ingredients: [(name: String, image: String)] = json["extendedIngredients"].arrayValue.map {
                    (name: $0["originalString"].stringValue, image: $0["image"].stringValue)
                }
                let readyInMinutes = json["readyInMinutes"].intValue
                let servings = json["servings"].intValue
                let recipe = DetailedRecipe(ingredients: ingredients, instructions: instructions, summary: summary, readyInMinutes: readyInMinutes, servings: servings, source: source)
                handler(recipe)
            }
        }
        task.resume()
    }
}
