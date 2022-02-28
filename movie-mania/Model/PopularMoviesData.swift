//
//  MovieData.swift
//  movie-mania
//
//  Created by harshdeep.s on 18/02/22.
//

import Foundation


struct PopularMoviesData: Decodable{
    var results: [MovieModel] = []
}
