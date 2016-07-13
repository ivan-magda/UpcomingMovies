//
//  TMDb+ResourceExtensions.swift
//  UpcomingMovies
//
//  Created by Ivan Magda on 13/07/16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

extension TMDbConfig {
    
    class func resource() -> Resource<TMDbConfig> {
        let URL = TMDb.urlFromParameters([:], withPathExtension: "/configuration")
        let resource = Resource<TMDbConfig>(url: URL) { json in
            let dictionary = json as? JSONDictionary
            return dictionary.flatMap(TMDbConfig.init)
        }
        
        return resource
    }
    
}
