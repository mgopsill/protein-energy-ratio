//
//  FoodService.swift
//  ProteinEnergyRatio
//
//  Created by Mike Gopsill on 11/09/2019.
//  Copyright © 2019 mgopsill. All rights reserved.
//

import Foundation

typealias FoodServiceCompletion = (_ result: Result<[String], NetworkError>) -> Void

enum URLs {
    static let baseURL = "https://api.edamam.com/api/food-database/parser?ingr="
    static let appkey = "53a839e96f0d41d28669466d47cdc806"
    static let appID = "f5ace2ed"
}

class FoodService {
    let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = DefaultNetworkManager()) {
        self.networkManager = networkManager
    }
    
    func getAutocomplete(for string: String, completion: @escaping FoodServiceCompletion) {
        let encodedString = string.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        let autoCompleteString = "http://api.edamam.com/auto-complete?q=\(encodedString)&app_id=\(URLs.appID)&app_key=\(URLs.appkey)"
        if let url = Foundation.URL(string: autoCompleteString) {
            let request = URLRequest(url: url)
            networkManager.fetch(request: request, completeOnMainThread: false) { [weak self] (data, response, error) in
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601

                    let model: [String]?
                    do {
                        model = try decoder.decode([String].self, from: data)
                    } catch {
                        print(error)
                        model = nil
                    }
                    
                    if let model = model {
                        DispatchQueue.main.async {
                            completion(Result.success(model))
                        }
                    } else {
                        self?.fail(completion)
                    }
                } else {
                    self?.fail(completion)
                }
            }
        }
    }
    
    func search(for food: String, completion: @escaping FoodServiceCompletion) {
        let foodString = food.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        let urlString = URLs.baseURL + foodString + "&app_id=\(URLs.appID)" + "&app_key=\(URLs.appkey)" // this is for the proper food search
        if let url = Foundation.URL(string: urlString) {
            let request = URLRequest(url: url)
            networkManager.fetch(request: request, completeOnMainThread: false) { [weak self] (data, response, error) in
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    let model: [String]?
                    do {
                        model = try decoder.decode([String].self, from: data)
                    } catch {
                        print(error)
                        model = nil
                    }
                    
                    if let model = model {
                        DispatchQueue.main.async {
                            completion(Result.success(model))
                        }
                    } else {
                        self?.fail(completion)
                    }
                } else {
                    self?.fail(completion)
                }
            }
        }
    }
    
    private func fail(_ completion: @escaping FoodServiceCompletion) {
        completion(Result.failure(NetworkError.defaultError))
    }
}
