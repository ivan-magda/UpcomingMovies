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

let kCellReuseIdentifier = "Cell"

// MARK: MoviesViewController: UIViewController

class MoviesViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: Properties
    
    var movies = [Movie]() {
        didSet {
            tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
        }
    }
    private var posters = [Int: UIImage]()
    
    var didSelect: (Movie) -> () = { _ in }
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: Private
    
    private func setup() {
        configureTableView()
        
        let service = Webservice()
        service.load(Movie.upcoming()) { [weak self] result in
            guard let movies = result.value else { return print(result.error!) }
            self?.movies = movies
        }
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.remembersLastFocusedIndexPath = true
    }
    
}

// MARK: - MoviesViewController: UITableViewDataSource -

extension MoviesViewController: UITableViewDataSource {
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellReuseIdentifier)!
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    // MARK: Helpers
    
    private func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let movie = movies[indexPath.row]
        
        cell.textLabel?.text = movie.title
        cell.detailTextLabel?.text = movie.releaseDate
        cell.layer.cornerRadius = 6
        cell.layer.masksToBounds = true
    }
    
}

// MARK: - MoviesViewController: UITableViewDelegate -

extension MoviesViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        didSelect(movies[indexPath.row])
    }
    
    func tableView(tableView: UITableView, didUpdateFocusInContext context: UITableViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        guard let highlightedRow = context.nextFocusedIndexPath?.row  else { return }
        
        let movie = movies[highlightedRow]
        guard movie.posterPath != nil else {
            imageView.image = UIImage(named: "movie-placeholder")
            return
        }
        
        if let image = posters[movie.id] {
            imageView.image = image
        } else {
            imageView.image = nil
            movie.downloadPosterImage { [weak self] image in
                guard let image = image else { return }
                self?.imageView.image = image
                self?.posters[movie.id] = image
            }
        }
        
        if let row = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(row, animated: false)
        }
    }
    
}
