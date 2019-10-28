//
//  NetworkManager.swift
//  ProteinEnergyRatio
//
//  Created by Mike Gopsill on 11/09/2019.
//  Copyright © 2019 mgopsill. All rights reserved.
//

import Foundation

typealias ServiceCompletion = (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void

protocol NetworkManager {
    @discardableResult func fetch(request: URLRequest, completeOnMainThread: Bool, completion: @escaping ServiceCompletion) -> URLSessionDataTask
}

class DefaultNetworkManager: NetworkManager {
    
    private let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    @discardableResult func fetch(request: URLRequest, completeOnMainThread: Bool, completion: @escaping ServiceCompletion) -> URLSessionDataTask {
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            self.log(data, response, error)
            if completeOnMainThread {
                DispatchQueue.main.async {
                    completion(data, response, error)
                }
            } else {
                completion(data, response, error)
            }
        }
        dataTask.resume()
        return dataTask
    }
    
    func log(_ data: Data?, _ response: URLResponse?, _ error: Error?) {
        print("--- Network Responded---")
        print("  Data: \(String(describing: data))")
        print("  Reponse: \(String(describing: response?.url))")
        print("  Error: \(String(describing: error))")
    }
}

enum NetworkError: Error {
    case defaultError
}
