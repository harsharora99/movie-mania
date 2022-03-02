//
//  ViewController.swift
//  movie-mania
//
//  Created by harshdeep.s on 18/02/22.
//

import UIKit
import Kingfisher
class HomeController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var sortSection: UIStackView!
    @IBOutlet weak var sortParamPicker: UIPickerView!
    
    var viewModel = PopularMoviesViewModel() //rename to viewModel
    
    let flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        //layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        return layout
    }()
    
    private let sectionInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
    private let itemsPerRow: CGFloat = 2

    override func viewDidLoad() {
        defer {
            viewModel.viewDidLoad()
        }
        super.viewDidLoad()
        viewModel.delegate = self
        searchBar.delegate = self
        sortParamPicker.dataSource = self
        sortParamPicker.delegate = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: Constants.cellNibName, bundle: nil), forCellWithReuseIdentifier: Constants.cellIdentifier)
    }

}

extension HomeController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as! MovieCell
        let movie = viewModel.movies[indexPath.row]
        //cell.movieLabel.text = movie.title
        let moviePosterURL = "\(Constants.imageAPIURL)\(movie.posterPath)"
        
        let processor = DownsamplingImageProcessor(size: cell.moviePoster.bounds.size)
                     |> RoundCornerImageProcessor(cornerRadius: 20)
        cell.moviePoster.kf.indicatorType = .activity
        cell.moviePoster.kf.setImage(
            with: URL(string: moviePosterURL),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])

        return cell
    }
    
    
}

extension HomeController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToDetails", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! MovieDetailsController
        
        if let indexPath = self.collectionView.indexPathsForSelectedItems?[0] {
            destinationVC.movie = viewModel.movies[indexPath.row]
        }
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row == viewModel.movies.count - 1 ) {
            viewModel.fetchMovies()
        }
    }
}
extension HomeController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = collectionView.bounds.width
            let numberOfItemsPerRow: CGFloat = 2
            let spacing: CGFloat = flowLayout.minimumInteritemSpacing
            let availableWidth = width - spacing * (numberOfItemsPerRow + 1)
            let itemDimension = floor(availableWidth / numberOfItemsPerRow)
            return CGSize(width: itemDimension, height: (itemDimension * 15 / 10))
        }
//    func collectionView(
//    _ collectionView: UICollectionView,
//    layout collectionViewLayout: UICollectionViewLayout,
//    sizeForItemAt indexPath: IndexPath
//    ) -> CGSize {
//        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
//        let availableWidth = collectionView.frame.width - paddingSpace
//        let widthPerItem = availableWidth / itemsPerRow
//
//        return CGSize(width: widthPerItem, height: widthPerItem)
////        return CGSize(width: (collectionView.frame.size.width/2) - 2, height: (collectionView.frame.size.width/2) - 2)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 1
//    }
//
//    func collectionView(
//    _ collectionView: UICollectionView,
//    layout collectionViewLayout: UICollectionViewLayout,
//    minimumLineSpacingForSectionAt section: Int
//    ) -> CGFloat {
//        return 5
//    }
    

}




extension HomeController: PopularMoviesViewModelDelegate {
    func didFetchPopularMovies() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
    }
}


extension HomeController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        sortSection.isHidden = true
        searchBar.showsCancelButton = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        sortSection.isHidden = false
        searchBar.text = ""
        searchBar.showsCancelButton = false
        if viewModel.searchTerm != nil {
            viewModel.searchTerm = nil
        }
        searchBar.resignFirstResponder()
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel.searchTerm = searchBar.text!
        searchBar.resignFirstResponder()
    }

//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchBar.text?.count == 0 {
//            sortSection.isHidden = false
//            viewModel.searchTerm = nil
//            searchBar.resignFirstResponder()
//        }
//    }
}


extension HomeController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.sortParameters.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.sortParameters[row].rawValue
    }
}

extension HomeController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.selectedSortParam = viewModel.sortParameters[row].rawValue
    }
}
