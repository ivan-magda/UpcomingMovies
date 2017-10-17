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

typealias MoviesCompletionHandler = ([Movie]?, Error?) -> Void
typealias GenresCompletionHandler = ([Genre]?, Error?) -> Void

// MARK: TMDb

class TMDb {
  
  // MARK: Properties
  
  var webservice: Webservice
  var config: TMDbConfig
  
  // MARK: Init
  
  init(webservice: Webservice, config: TMDbConfig) {
    self.webservice = webservice
    self.config = config
    
    config.requestForNewConfigIfDaysSinceUpdateExceeds(7) { [unowned self] result in
      guard let newConfig = result.value else { return print(result.error!) }
      self.config = newConfig
      self.config.save()
    }
  }
  
  convenience init(webservice: Webservice) {
    let config = TMDbConfig.unarchivedInstance() ?? TMDbConfig()
    self.init(webservice: webservice, config: config)
  }
  
}

// MARK: - Create URLs -

extension TMDb {
  
  class func url(from parameters: MethodParameters, withPathExtension: String? = nil) -> URL {
    var components = URLComponents()
    components.scheme = Constants.TMDB.ApiScheme
    components.host = Constants.TMDB.ApiHost
    components.path = Constants.TMDB.ApiPath + (withPathExtension ?? "")
    components.queryItems = [URLQueryItem]()
    
    let apiKey = URLQueryItem(
      name: Constants.TMDBParameterKeys.ApiKey,
      value: Constants.TMDBParameterValues.ApiKey
    )
    components.queryItems!.append(apiKey)
    
    parameters.forEach { key, value in
      let queryItem = URLQueryItem(name: key, value: "\(value)")
      components.queryItems!.append(queryItem)
    }
    
    return components.url!
  }
  
}

// MARK: - Calling Endpoints -

extension TMDb {
  
  func upcomingMovies(_ completion: @escaping MoviesCompletionHandler) {
    webservice.load(Movie.upcoming()) { result in
      guard let movies = result.value else { return completion(nil, result.error) }
      completion(movies.results, nil)
    }
  }
  
  func allGenres(_ completion: @escaping GenresCompletionHandler) {
    webservice.load(Genre.all()) { result in
      guard let genres = result.value else { return completion(nil, result.error) }
      completion(genres.first?.value, nil)
    }
  }
  
}

// MARK: - TMDb (Movie Poster Image) -

extension TMDb {
  
  func posterImageURL(for movie: Movie, size: String) -> URL? {
    guard let posterPath = movie.posterPath else { return nil }
    let baseURL = URL(string: config.secureBaseImageUrl)!
    return baseURL.appendingPathComponent(size).appendingPathComponent(posterPath)
  }
  
  func posterImageURL(for movie: Movie) -> URL? {
    return posterImageURL(for: movie, size: "w500")
  }
  
}
