//
//  MovieDetailsController.swift
//  movie-mania
//
//  Created by harshdeep.s on 23/02/22.
//

import UIKit
import Kingfisher

class MovieDetailsController: UIViewController {
    var movie: MovieModel?
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var movieOverviewLabel: UILabel!
    @IBOutlet weak var averageRatingLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let selectedMovie = movie {
            movieTitleLabel.text = selectedMovie.title
            let moviePosterURL = "\(Constants.imageAPIURL)\(selectedMovie.poster_path)"
            //print(moviePosterURL)
            let processor = DownsamplingImageProcessor(size: moviePoster.bounds.size)
                         |> RoundCornerImageProcessor(cornerRadius: 20)
            moviePoster.kf.indicatorType = .activity
            moviePoster.kf.setImage(
                with: URL(string: moviePosterURL),
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
                ])
            movieOverviewLabel.text = selectedMovie.overview
            averageRatingLabel.text = String(selectedMovie.vote_average)
            releaseDateLabel.text = selectedMovie.release_date
   
        }
       
    }

}
