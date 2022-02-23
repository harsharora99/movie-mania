//
//  ViewController.swift
//  movie-mania
//
//  Created by harshdeep.s on 18/02/22.
//

import UIKit

class HomeController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var sortParamPicker: UIPickerView!
    
    private let itemsPerRow: CGFloat = 2
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    
    //let sortBasis = ["asc", "desc"]
    
    //var movies: [[String: String]] = [[:]]
    var viewModel = PopularMoviesViewModel() //rename to viewModel

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        searchBar.delegate = self
        sortParamPicker.dataSource = self
        sortParamPicker.delegate = self
        viewModel.fetchMovies()
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
//    //CGSize(width: <#T##CGFloat#>, height: <#T##CGFloat#>)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as! MovieCell
        cell.movieLabel.text = viewModel.movies[indexPath.row].title
        return cell
    }
    
    
}

extension HomeController: PopularMoviesViewModelDelegate {
    func didFetchPopularMovies() {
        //self.movies = movies
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
    }
}


extension HomeController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel.fetchMovies(with: searchBar.text!)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            viewModel.resetMovies()
            viewModel.fetchMovies()
            searchBar.resignFirstResponder()
        }
    }
}


extension HomeController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.sortParameters.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.sortParameters[row]
    }
}

extension HomeController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.selectedSortParam = viewModel.sortParameters[row]
    }
}
