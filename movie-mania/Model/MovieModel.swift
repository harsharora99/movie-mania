//
//  Movie.swift
//  movie-mania
//
//  Created by harshdeep.s on 18/02/22.
//

import Foundation


struct MovieModel: Decodable {
    let id: Int
    let posterPath: String
    let title: String
    let voteAverage: Float
    let popularity: Double
    let overview: String
    let releaseDate: String
}
