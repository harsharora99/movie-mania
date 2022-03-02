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

enum SortParameter: String {
    case popularity = "Most popular first"
    case rating = "Highest rated first"
}

class PopularMoviesViewModel {
    private(set) var movies: [MovieEntity] = []
    private let moviesPerPage = 20
    weak var delegate: PopularMoviesViewModelDelegate?
    var pageNo = 0
    var requestPending = false
    let sortParameters: [SortParameter] = [.popularity, .rating]
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var initialFetch = false
    var searchTerm: String? {
        didSet {
            resetMovies()
            fetchMovies()
        }
    }
    var selectedSortParam: SortParameter = .popularity {
        didSet{
            if oldValue != selectedSortParam {
                resetMovies()
                fetchMovies()
            }
        }
    }
    
    func fetchMoviesFromDB() throws -> [MovieEntity] {
        let request : NSFetchRequest<Movie> = Movie.fetchRequest()
        
        let fetchedMovies = try context.fetch(request)
        
        var movies: [MovieEntity] = []
        for fetchedMovie in fetchedMovies {
            let movie = MovieEntity(id: Int(fetchedMovie.id), posterPath: fetchedMovie.posterPath!, title: fetchedMovie.title!, voteAverage: fetchedMovie.voteAverage, popularity: fetchedMovie.popularity, overview: fetchedMovie.overview!, releaseDate: fetchedMovie.releaseDate!)
            movies.append(movie)
            
        }
        return movies
    }
    
    func viewDidLoad() {
        loadMovies()
    }
    func loadMovies() {
        do {
            let movies = try fetchMoviesFromDB()
            if movies.count == 0 {
                initialFetchForMovies()
            } else {
                appendMovies(fetchedMovies: movies)
            }
        } catch {
            print("Error fetching data from context, \(error)")
        }
    }

    func initialFetchForMovies(){
        initialFetch = true
        fetchMovies()
    }

    func saveMovies(movies: [MovieEntity]) {
        do {
            for movie in movies {
                let movieData = NSEntityDescription.insertNewObject(forEntityName: "Movie", into: context) as! Movie
                movieData.id = Int64(movie.id)
                movieData.title = movie.title
                movieData.posterPath = movie.posterPath
                movieData.voteAverage = movie.voteAverage
                movieData.popularity = movie.popularity
                movieData.overview = movie.overview
                movieData.releaseDate = movie.releaseDate
                
            }
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
        } else if(selectedSortParam == .popularity) {
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
    
    
    func performRequest(with urlString: String) {

//        AF.request(urlString).responseDecodable(of: PopularMoviesData.self) { [weak self] response in
        AF.request(urlString).response { [weak self] response in
            
            guard let strongSelf = self else { return }

            guard let fetchedMovies = strongSelf.parseJSON(response.data!) else {
                   strongSelf.delegate?.didFetchPopularMovies()
                   return
               }
            var movies: [MovieEntity] = []
            for fetchedMovie in fetchedMovies {
                let movie = MovieEntity(id: fetchedMovie.id, posterPath: fetchedMovie.posterPath, title: fetchedMovie.title, voteAverage: fetchedMovie.voteAverage, popularity: fetchedMovie.popularity, overview: fetchedMovie.overview, releaseDate: fetchedMovie.releaseDate)
                movies.append(movie)
            }
        
            strongSelf.appendMovies(fetchedMovies: movies)
        }

    }
    
    func appendMovies(fetchedMovies: [MovieEntity]) {
        movies.append(contentsOf: fetchedMovies)
        pageNo += fetchedMovies.count / moviesPerPage
        requestPending = false
        if initialFetch == true {
            saveMovies(movies: fetchedMovies)
            initialFetch = false
        }
        delegate?.didFetchPopularMovies()
    }

    
    func parseJSON(_ moviesData: Data) -> [MovieModel]? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
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
