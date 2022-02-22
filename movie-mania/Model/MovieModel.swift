//
//  Movie.swift
//  movie-mania
//
//  Created by harshdeep.s on 18/02/22.
//

import Foundation


struct MovieModel: Decodable {
    let id: Int
    let poster_path: String
    let title: String
    let vote_average: Float
    let popularity: Double
    let overview: String
    let release_date: String
}
