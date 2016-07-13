/**
 * Copyright (c) 2016 Ivan Magda
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation

typealias MethodParameters = [String: AnyObject]

// MARK: TMDb

class TMDb {
    
    // MARK: Properties
    
    static let sharedInstance = TMDb()
    var config: TMDbConfig!
    
    // MARK: Init
    
    private init() {
        config = TMDbConfig.unarchivedInstance() ?? TMDbConfig()
        config.requestForNewConfigIfDaysSinceUpdateExceeds(7) { [unowned self] result in
            guard let newConfig = result.value else { return print(result.error!) }
            self.config = newConfig
            self.config.save()
        }
    }
    
}

// MARK: - Create URLs -

extension TMDb {
    
    class func urlFromParameters(parameters: MethodParameters, withPathExtension: String? = nil) -> NSURL {
        let components = NSURLComponents()
        components.scheme = Constants.TMDB.ApiScheme
        components.host = Constants.TMDB.ApiHost
        components.path = Constants.TMDB.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        let apiKey = NSURLQueryItem(
            name: Constants.TMDBParameterKeys.ApiKey,
            value: Constants.TMDBParameterValues.ApiKey
        )
        components.queryItems!.append(apiKey)
        
        parameters.forEach { key, value in
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
    
}
