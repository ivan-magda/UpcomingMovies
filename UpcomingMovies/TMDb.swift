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

typealias MoviesCompletionHandler = ([Movie]?, ErrorType?) -> Void
typealias GenresCompletionHandler = ([Genre]?, ErrorType?) -> Void

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

// MARK: - Calling Endpoints -

extension TMDb {
    
    func upcomingMovies(completion: MoviesCompletionHandler) {
        webservice.load(Movie.upcoming()) { result in
            guard let movies = result.value else { return completion(nil, result.error) }
            completion(movies, nil)
        }
    }
    
    func allGenres(completion: GenresCompletionHandler) {
        webservice.load(Genre.all()) { result in
            guard let genres = result.value else { return completion(nil, result.error) }
            completion(genres, nil)
        }
    }
    
}

// MARK: - TMDb (Movie Poster Image) -

extension TMDb {
    
    func posterImageURLForMovie(movie: Movie, size: String) -> NSURL? {
        guard let posterPath = movie.posterPath else { return nil }
        let baseURL = NSURL(string: config.secureBaseImageURLString)!
        return baseURL.URLByAppendingPathComponent(size).URLByAppendingPathComponent(posterPath)
    }
    
    func posterImageURLForMovie(movie: Movie) -> NSURL? {
        return posterImageURLForMovie(movie, size: "w500")
    }
    
}
