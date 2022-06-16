//
//  URL+Extensions.swift
//  Part of my local repo
//
//  Created by Emmanuel Adigun on 2020/04/26.
//  Copyright © 2020. All rights reserved.
//

import Foundation

extension URL {

    mutating func appendQueryItem(_ name: String, _ value: String?) {

        guard var urlComponents = URLComponents(string: absoluteString) else { return }

        // Create array of existing query items
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []

        // Create query item
        let queryItem = URLQueryItem(name: name, value: value)

        // Append the new query item in the existing query items array
        queryItems.append(queryItem)

        // Append updated query items array in the url component object
        urlComponents.queryItems = queryItems

        // Returns the url from new url components
        self = urlComponents.url!
    }
}
