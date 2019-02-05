//
//  SpotifyManager.swift
//  SpotifyTestApp
//
//  Created by Daniel Yo on 2/5/19.
//  Copyright © 2019 Daniel Yo. All rights reserved.
//

import Foundation

struct Tracks: Decodable {
    let href: String?
    let limit: Int?
    let total: Int?
    let items: [Item]?
}

struct ExternalURL: Decodable {
    var spotify: String?
}

struct Item: Decodable {
    var externalURL: ExternalURL?
    var id: String?
    var isPlayable: Bool?
    var previewURL: String?
    var name: String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case externalURL = "external_urls"
        case previewURL = "preview_url"
        case isPlayable = "is_playable"
    }
}

struct SearchResult: Decodable {
    let tracks: Tracks?
}

class SpotifyManager {
    let baseURL = "https://api.spotify.com/"
    let authToken = "BQBilJhXSJgeRAwcDy8KWodKSYTo_RuTuiWV-2-k6wbsnRjiNnGlcS8dCwTIWdy3gh_4s2WRUSEJ0kRdopK64-1nopRkH-f0sAXdqoYWUsTWEpHdBPHTS60YYOP_aWIwNsM9ig6RTqKE8uEs"
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask? // used for GET
    
    init() {
        
    }
    
    public func getSongData(withTitle title: String, success:@escaping (String) -> Void, failure:@escaping (String) -> Void) {
        
        // cancel the query if data task already exists
        dataTask?.cancel()
        
        if var urlComponents = URLComponents(string: baseURL + "v1/search") {
            
            // params
            let paramQuery = URLQueryItem(name: "q", value: title)
            let paramTrack = URLQueryItem(name: "type", value: "track")
            let paramMarket = URLQueryItem(name: "market", value: "US")
            let paramLimit = URLQueryItem(name: "limit", value: "1")

            urlComponents.queryItems = [paramQuery, paramTrack, paramMarket, paramLimit]
            
            guard let url = urlComponents.url else { return }
            
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("Bearer " + authToken, forHTTPHeaderField: "Authorization")
            
            dataTask = defaultSession.dataTask(with: request, completionHandler: { (data, response, error) in
                
                // after everything is done
                defer { self.dataTask = nil }

                let test = response as? HTTPURLResponse
                if ((test?.statusCode)! >= 400) {
                    print("Token expired most likely")
                }
                print(test?.statusCode ?? 0)
                
                if let error = error {
                    print(error.localizedDescription)
                } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    do {
                        // new way to parse straight into model
                        let obj = try JSONDecoder().decode(SearchResult.self, from: data)
                        print(obj.tracks?.items![0].name)
                        if let previewURL = obj.tracks?.items![0].previewURL {
                            success(previewURL)
                        } else {
                            failure("No Preview URL available for this song")
                        }
                    } catch let jsonError {
                        print(jsonError.localizedDescription)
                    }
                }
            })
        }
        
        dataTask?.resume()
        
    }
}
