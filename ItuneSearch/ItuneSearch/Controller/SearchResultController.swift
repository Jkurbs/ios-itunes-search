//
//  SearchResultController.swift
//  ItuneSearch
//
//  Created by Kerby Jean on 2/11/20.
//  Copyright © 2020 Kerby Jean. All rights reserved.
//

import Foundation


class SearchResultController {
    
    let baseUrl = URL(string: "https://itunes.apple.com/search?")
    
    var results: [SearchResult] = []
    
    enum HTTPMETHODS: String {
        case get = "GET"
        case post = "POST"
    }
    
    var count: Int {
        return results.count
    }
    
    func performSearch(searchTerm: String, resultType: String?, completion: @escaping(Error?) -> () ) {
        
        /// Unwrappe URL
        guard let url = baseUrl else { return }
        
        /// Create URL component
        var urlCoponemt = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        /// Create query item, base on search term
        let termQueryItem = URLQueryItem(name: "term", value: searchTerm)
        let mediaQueryItem = URLQueryItem(name: "entity", value: resultType ?? ResultType.software.rawValue)
        urlCoponemt?.queryItems = [termQueryItem, mediaQueryItem]
        
        /// Unwrappe URLComponents url
        guard let requestUrl = urlCoponemt?.url else {return}
        /// Create Request
        print(requestUrl)
        var request = URLRequest(url: requestUrl)
        
        /// Add which method is going to be used
        request.httpMethod = HTTPMETHODS.get.rawValue
        
        URLSession.shared.dataTask(with: requestUrl) { (data, _, error) in
            if let error = error {
                print("Error loading data: \(error.localizedDescription)")
                completion(error)
                return
            } else {
                let decoder = JSONDecoder()
                do {
                    guard let data = data else {
                        completion(nil)
                        return
                    }
                    let searchResult = try decoder.decode(SearchResults.self, from: data)
                    self.results.append(contentsOf: searchResult.results)
                    completion(nil)
                } catch {
                    print("Error decoding data: \(error)")
                    completion(error)
                }
            }
        }.resume()
    }
}


