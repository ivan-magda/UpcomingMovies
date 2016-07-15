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

// MARK: Types

private enum Key: String {
    case id
    case title
    case overview
    case releaseDate = "release_date"
    case genreIds = "genre_ids"
    case posterPath = "poster_path"
    case vote = "vote_average"
}

// MARK: - Movie

struct Movie {
    let id: Int
    let title: String
    let overview: String
    let releaseDate: String
    let genreIds: [Int]
    let vote: Double
    let posterPath: String?
}

// MARK: - Movie (JSON Parsing) -

extension Movie {
    
    init?(json: JSONDictionary) {
        guard let id = json[Key.id.rawValue] as? Int,
            title = json[Key.title.rawValue] as? String,
            overview = json[Key.overview.rawValue] as? String,
            releaseDate = json[Key.releaseDate.rawValue] as? String,
            genreIds = json[Key.genreIds.rawValue] as? [Int],
            vote = json[Key.vote.rawValue] as? Double else {
                return nil
        }
        
        self.id = id
        self.title = title
        self.overview = overview
        self.releaseDate = releaseDate
        self.genreIds = genreIds
        self.vote = vote
        self.posterPath = json[Key.posterPath.rawValue] as? String
    }
    
}

// MARK: - Movie (Resource) -

extension Movie {
    
    static func upcoming() -> Resource<[Movie]> {
        let URL = TMDb.urlFromParameters([:], withPathExtension: "/movie/upcoming")
        
        let resource = Resource<[Movie]>(url: URL) { json in
            let movies = json["results"] as? [JSONDictionary]
            return movies?.flatMap(Movie.init)
        }
        
        return resource
    }
}
