//
//  MovieViewModel.swift
//  movie-mania
//
//  Created by harshdeep.s on 18/02/22.
//

import Foundation
import Alamofire
import CoreData
protocol PopularMoviesViewModelDelegate: AnyObject {
    func didFetchPopularMovies()
}

class PopularMoviesViewModel {
    var movies: [Movie] = []
    weak var delegate: PopularMoviesViewModelDelegate?
    private let moviesPerPage = 20
    var pageNo = 0
    var requestPending = false
    let sortParameters = ["Most popular first", "Highest rated first"]
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var initialFetch = false
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
    
    func loadMovies() {
        do {
            let request : NSFetchRequest<Movie> = Movie.fetchRequest()
            
            let movies = try context.fetch(request)
            
            appendMovies(fetchedMovies: movies)
        } catch {
            print("Error fetching data from context, \(error)")
        }
    }
    
    func initialFetchForMovies(){
        initialFetch = true
        fetchMovies()
    }
    
    func saveMovies() {
        do {
            try context.save()
        } catch {
            print("Error saving context, \(error)")
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
        AF.request(urlString).response { [weak self] response in
            
            guard let strongSelf = self else { return }
            
            guard let fetchedMovies = strongSelf.parseJSON(response.data!) else {
                strongSelf.delegate?.didFetchPopularMovies()
                return
            }

            strongSelf.appendMovies(fetchedMovies: fetchedMovies)
        }

    }
    
    func appendMovies(fetchedMovies: [Movie]) {
        movies.append(contentsOf: fetchedMovies)
        pageNo += 1 //fetchedMovies.count / moviesPerPage
        requestPending = false
        if initialFetch == true {
            saveMovies()
            initialFetch = false
        }
        delegate?.didFetchPopularMovies()
    }
    
    func parseJSON(_ moviesData: Data) -> [Movie]? {
        let decoder = JSONDecoder()
        decoder.userInfo[CodingUserInfoKey.managedObjectContext] = context
        do {
            let decodedData = try decoder.decode(PopularMoviesData.self, from: moviesData)  //WeatherData represents struct and WeatherData.self represents type
            let movies:[Movie] = decodedData.results
            return movies
        } catch {
            print(error)
            return nil
        }
        
    }
    
}
