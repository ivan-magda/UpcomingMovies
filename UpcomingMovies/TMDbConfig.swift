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

import UIKit
import Foundation

// MARK: - TMDbConfig -

///  The TMDbConfig stores (persist) information that is used to build image
///  URL's for TheMovieDB. Invoking the updateConfig convenience method
///  will download the latest using the initializer below to parse the dictionary.
class TMDbConfig: Codable {
  
  // MARK: Properties
  
  // default values from 13/07/16
  var baseImageUrl = "http://image.tmdb.org/t/p/"
  var secureBaseImageUrl =  "https://image.tmdb.org/t/p/"
  var posterSizes = ["w92", "w154", "w185", "w342", "w500", "w780", "original"]
  var dateUpdated: Date? = nil
  
  /// Returns the number days since the config was last updated.
  var daysSinceLastUpdate: Int? {
    if let lastUpdate = dateUpdated {
      return Int(Date().timeIntervalSince(lastUpdate)) / (60 * 60 * 24)
    } else {
      return nil
    }
  }
  
  // MARK: Initialization
  convenience init?(dictionary: [String: AnyObject]) {
    self.init()
    
    guard let imageDictionary = dictionary["images"] as? [String: AnyObject],
      let urlString = imageDictionary["base_url"] as? String,
      let secureURLString = imageDictionary["secure_base_url"] as? String,
      let posterSizesArray = imageDictionary["poster_sizes"] as? [String] else {
        return nil
    }
    
    self.baseImageUrl = urlString
    self.secureBaseImageUrl = secureURLString
    self.posterSizes = posterSizesArray
    self.dateUpdated = Date()
  }
  
  // MARK: Update
  
  func requestForNewConfigIfDaysSinceUpdateExceeds(_ days: Int, newConfig completion: @escaping (Result<TMDbConfig>) -> ()) {
    guard let daysSinceLastUpdate = daysSinceLastUpdate, daysSinceLastUpdate <= days else {
      return Webservice().load(TMDbConfig.resource(), completion: completion)
    }
  }
  
  // MARK: Codable
  
  private enum CodingKeys: String, CodingKey {
    case baseImageUrl = "base_url"
    case secureBaseImageUrl = "secure_base_url"
    case posterSizes = "poster_sizes"
    case dateUpdated
  }
  
  func save() {
    let encoder = JSONEncoder()
    if let json = try? encoder.encode(self) {
        UserDefaults.standard.set(json, forKey: "TheMovieDB-Configuration")
    }
  }
  
  class func unarchivedInstance() -> TMDbConfig? {
    let decoder = JSONDecoder()
    return try? decoder.decode(self, from: UserDefaults.standard.data(forKey: "TheMovieDB-Configuration") ?? "".data(using: .utf8)!)
  }
  
}
