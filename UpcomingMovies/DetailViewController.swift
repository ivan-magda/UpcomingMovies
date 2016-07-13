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

// MARK: DetailViewController: UIViewController

class DetailViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var overview: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Properties
    
    var movie: Movie?
    private var genres = [Genre]() {
        didSet {
            updateGenresLabel()
        }
    }

    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // MARK: Private
    
    private func configure() {
        guard let movie = movie else { return }
        
        name.text = movie.title
        overview.text = movie.overview
        rating.text = rating.text! + " \(movie.vote)"
        releaseDate.text = releaseDate.text! + " \(movie.releaseDate)"
        
        activityIndicator.startAnimating()
        movie.downloadPosterImage("original") { [weak self] image in
            self?.activityIndicator.stopAnimating()
            self?.imageView.image = image
        }
        
        Webservice().load(Genre.all()) { [weak self] result in
            guard let genres = result.value else { return print(result.error!) }
            self?.genres = genres
        }
    }
    
    private func updateGenresLabel() {
        let ids = movie!.genreIds
        let movieGenres = genres.filter { ids.contains($0.id) }.map { $0.name }
        let genresString = movieGenres.joinWithSeparator(", ")
        
        genresLabel.text = genresLabel.text! + " \(genresString)"
    }

}
