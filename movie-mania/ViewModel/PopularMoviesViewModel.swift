//
//  MovieViewModel.swift
//  movie-mania
//
//  Created by harshdeep.s on 18/02/22.
//

import Foundation
import Alamofire
protocol PopularMoviesViewModelDelegate: AnyObject {
    func didFetchPopularMovies()
}

class PopularMoviesViewModel {
    var movies: [MovieModel] = []
    weak var delegate: PopularMoviesViewModelDelegate?
    var pageNo = 0
    var requestPending = false
    let sortParameters = ["Most popular first", "Highest rated first"]
    var searchTerm: String? {
        didSet {
            resetMovies()
            fetchMovies()
        }
    }
    var selectedSortParam: String = "Most popular first" {
        didSet{
            if oldValue != selectedSortParam {
                resetMovies()
                fetchMovies()
            }
        }
    }
    
    func fetchMovies() {
        guard !requestPending else { return }
        var urlString = ""
        if let search = searchTerm {
            if search.count > 0 {
                urlString = "\(Constants.searchMoviesAPIURL)&query=\(search)&page=\(pageNo+1)"
            }
        } else if(selectedSortParam == sortParameters[0]) {
            urlString = "\(Constants.popularMoviesAPIURL)&page=\(pageNo+1)"
        } else {
            urlString = "\(Constants.topRatedMoviesAPIURL)&page=\(pageNo+1)"
        }
        print(urlString)
        performRequest(with: urlString)
    }
    
    func resetMovies(){
        movies = []
        pageNo = 0
        requestPending = false
    }
    
//    func fetchMovies(with name: String) {
//        resetMovies()
//        let urlString =
//        print(urlString)
//        performRequest(with: urlString)
//    }
            
    
    func performRequest(with urlString: String) {

        AF.request(urlString).responseDecodable(of: PopularMoviesData.self) { [weak self] response in
            
            guard let strongSelf = self else { return }
            guard let fetchedMovies = response.value?.results else {
                strongSelf.delegate?.didFetchPopularMovies()
                return
            }
        
            strongSelf.movies.append(contentsOf: fetchedMovies)
            strongSelf.pageNo += 1
            strongSelf.requestPending = false
            strongSelf.delegate?.didFetchPopularMovies()
        }

    }
    
    func parseJSON(_ moviesData: Data) -> [MovieModel]? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(PopularMoviesData.self, from: moviesData)  //WeatherData represents struct and WeatherData.self represents type
            let movies:[MovieModel] = decodedData.results
            return movies
        } catch {
            print(error)
            return nil
        }
        
    }
    
}
