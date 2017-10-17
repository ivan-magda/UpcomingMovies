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

typealias JSONDictionary = [String: AnyObject]

enum WebserviceError: Error {
  case other
}

final class Webservice {
  init() { }
  
  /// Loads a resource. The completion handler is always called on the main queue.
  func load<A>(_ resource: Resource<A>, completion: @escaping (Result<A>) -> ()) {
    URLSession.shared.dataTask(with: resource.url, completionHandler: { data, response, _ in
      let parsed = resource.parse(data!)
      let result = Result(parsed, or: WebserviceError.other)
      mainQueue { completion(result) }
    }) .resume()
  }
}
