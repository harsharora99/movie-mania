//
//  ViewController.swift
//  movie-mania
//
//  Created by harshdeep.s on 18/02/22.
//

import UIKit

class HomeController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    //var movies: [[String: String]] = [[:]]
    var viewModel = PopularMoviesViewModel() //rename to viewModel

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        viewModel.fetchPopularMovies()
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: Constants.cellNibName, bundle: nil), forCellWithReuseIdentifier: Constants.cellIdentifier)
    }

}


//extension HomeController: UICollectionViewDelegateFlowLayout {
//  // 1
//  func collectionView(
//    _ collectionView: UICollectionView,
//    layout collectionViewLayout: UICollectionViewLayout,
//    sizeForItemAt indexPath: IndexPath
//  ) -> CGSize {
//    // 2
//    let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
//    let availableWidth = view.frame.width - paddingSpace
//    let widthPerItem = availableWidth / itemsPerRow
//
//    return CGSize(width: widthPerItem, height: widthPerItem)
//  }
//
//  // 3
//  func collectionView(
//    _ collectionView: UICollectionView,
//    layout collectionViewLayout: UICollectionViewLayout,
//    insetForSectionAt section: Int
//  ) -> UIEdgeInsets {
//    return sectionInsets
//  }
//
//  // 4
//  func collectionView(
//    _ collectionView: UICollectionView,
//    layout collectionViewLayout: UICollectionViewLayout,
//    minimumLineSpacingForSectionAt section: Int
//  ) -> CGFloat {
//    return sectionInsets.left
//  }
//}


extension HomeController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "", for: indexPath) as! MovieCell
        cell.movieLabel.text = viewModel.movies[indexPath.row].title
        return cell
    }
    
    
}

extension HomeController: PopularMoviesViewModelDelegate {
    func didFetchPopularMovies() {
        //self.movies = movies
        self.collectionView.reloadData()
    }
}

