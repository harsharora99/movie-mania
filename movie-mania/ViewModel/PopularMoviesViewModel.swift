//
//  MovieViewModel.swift
//  movie-mania
//
//  Created by harshdeep.s on 18/02/22.
//

import Foundation

protocol PopularMoviesViewModelDelegate: AnyObject {
    func didFetchPopularMovies()
}

class PopularMoviesViewModel {
    var movies: [MovieModel] = []
    weak var delegate: PopularMoviesViewModelDelegate?
    var pageNo = 0
    var requestPending = false
    let sortParameters = ["Most popular first", "Highest rated first"]
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
        if(selectedSortParam == sortParameters[0]) {
            urlString = "\(Constants.popularMoviesAPIURL)&page=\(pageNo+1)"
        } else {
            urlString = "\(Constants.topRatedMoviesAPIURL)&page=\(pageNo+1)"
        }
        
        performRequest(with: urlString)
    }
    
    func resetMovies(){
        movies = []
        pageNo = 0
    }
    
    func fetchMovies(with name: String) {
        resetMovies()
        let urlString = "\(Constants.searchMoviesAPIURL)&query=\(name)&page=\(pageNo+1)"
        performRequest(with: urlString)
    }
            
    
    func performRequest(with urlString: String) {

        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
          
            let task = session.dataTask(with: url) { [weak self] data, response, error in
                guard let strongSelf = self else { return }
                if(error != nil) {
                    print(error!)
                    return
                }
                
                if let safeData = data {
                    if let movies = strongSelf.parseJSON(safeData) {
                        strongSelf.movies.append(contentsOf: movies)
                        strongSelf.pageNo += 1
                        strongSelf.requestPending = false
                        strongSelf.delegate?.didFetchPopularMovies()
                    }
                }
            }
            //Start the task
            self.requestPending = true
            task.resume()
        }
    }
    
//    mutating func appendMovies(moviesFetched: [MovieModel]) -> [MovieModel]{
//        for movie in moviesFetched{
//            self.popularMovies.append(movie)
//        }
//        return self.popularMovies
//    }
    
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
