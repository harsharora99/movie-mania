//
//  Constants.swift
//  movie-mania
//
//  Created by harshdeep.s on 18/02/22.
//

import Foundation

struct Constants {
    static let imageAPIURL = "https://image.tmdb.org/t/p/w500"
    static let popularMoviesAPIURL = "https://api.themoviedb.org/3/movie/popular?api_key=\(Config.apiKey)"
    static let topRatedMoviesAPIURL = "https://api.themoviedb.org/3/movie/top_rated?api_key=\(Config.apiKey)"
    static let searchMoviesAPIURL = "https://api.themoviedb.org/3/search/movie?api_key=\(Config.apiKey)"
    static let cellIdentifier = "ReusableCell"
    static let cellNibName = "MovieCell"
}
