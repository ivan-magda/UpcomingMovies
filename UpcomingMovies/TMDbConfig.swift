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

// MARK: File Support

private let _documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as URL
private let _fileURL = _documentsDirectoryURL.appendingPathComponent("TheMovieDB-Configuration")

// MARK: - TMDbConfig -

///  The TMDbConfig stores (persist) information that is used to build image
///  URL's for TheMovieDB. Invoking the updateConfig convenience method
///  will download the latest using the initializer below to parse the dictionary.
class TMDbConfig: NSObject, NSCoding {
  
  // MARK: Properties
  
  // default values from 13/07/16
  var baseImageURLString = "http://image.tmdb.org/t/p/"
  var secureBaseImageURLString =  "https://image.tmdb.org/t/p/"
  var posterSizes = ["w92", "w154", "w185", "w342", "w500", "w780", "original"]
  var dateUpdated: Date? = nil
  
  /// Returns the number days since the config was last updated.
  var daysSinceLastUpdate: Int? {
    if let lastUpdate = dateUpdated {
      return Int(Date().timeIntervalSince(lastUpdate)) / 60*60*24
    } else {
      return nil
    }
  }
  
  // MARK: Initialization
  
  override init() {}
  
  convenience init?(dictionary: [String: AnyObject]) {
    self.init()
    
    guard let imageDictionary = dictionary["images"] as? [String: AnyObject],
      let urlString = imageDictionary["base_url"] as? String,
      let secureURLString = imageDictionary["secure_base_url"] as? String,
      let posterSizesArray = imageDictionary["poster_sizes"] as? [String] else {
        return nil
    }
    
    self.baseImageURLString = urlString
    self.secureBaseImageURLString = secureURLString
    self.posterSizes = posterSizesArray
    self.dateUpdated = Date()
  }
  
  // MARK: Update
  
  func requestForNewConfigIfDaysSinceUpdateExceeds(_ days: Int, newConfig completion: @escaping (Result<TMDbConfig>) -> ()) {
    guard let daysSinceLastUpdate = daysSinceLastUpdate, daysSinceLastUpdate <= days else {
      return Webservice().load(TMDbConfig.resource(), completion: completion)
    }
  }
  
  // MARK: NSCoding
  
  let BaseImageURLStringKey = "config.base_image_url_string_key"
  let SecureBaseImageURLStringKey =  "config.secure_base_image_url_key"
  let PosterSizesKey = "config.poster_size_key"
  let ProfileSizesKey = "config.profile_size_key"
  let DateUpdatedKey = "config.date_update_key"
  
  required init(coder aDecoder: NSCoder) {
    baseImageURLString = aDecoder.decodeObject(forKey: BaseImageURLStringKey) as! String
    secureBaseImageURLString = aDecoder.decodeObject(forKey: SecureBaseImageURLStringKey) as! String
    posterSizes = aDecoder.decodeObject(forKey: PosterSizesKey) as! [String]
    dateUpdated = aDecoder.decodeObject(forKey: DateUpdatedKey) as? Date
  }
  
  func encode(with aCoder: NSCoder) {
    aCoder.encode(baseImageURLString, forKey: BaseImageURLStringKey)
    aCoder.encode(secureBaseImageURLString, forKey: SecureBaseImageURLStringKey)
    aCoder.encode(posterSizes, forKey: PosterSizesKey)
    aCoder.encode(dateUpdated, forKey: DateUpdatedKey)
  }
  
  func save() {
    NSKeyedArchiver.archiveRootObject(self, toFile: _fileURL.path)
  }
  
  class func unarchivedInstance() -> TMDbConfig? {
    if FileManager.default.fileExists(atPath: _fileURL.path) {
      return NSKeyedUnarchiver.unarchiveObject(withFile: _fileURL.path) as? TMDbConfig
    } else {
      return nil
    }
  }
  
}
