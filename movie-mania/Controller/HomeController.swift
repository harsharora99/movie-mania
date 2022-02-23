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
    @IBOutlet weak var sortParamPicker: UIPickerView!
    
    var viewModel = PopularMoviesViewModel() //rename to viewModel

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        searchBar.delegate = self
        sortParamPicker.dataSource = self
        sortParamPicker.delegate = self
        viewModel.fetchMovies()
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
        cell.movieLabel.text = movie.title
        let moviePosterURL = "\(Constants.imageAPIURL)\(movie.poster_path)"
        
        let processor = DownsamplingImageProcessor(size: cell.moviePoster.bounds.size)
                     |> RoundCornerImageProcessor(cornerRadius: 20)
        cell.moviePoster.kf.indicatorType = .activity
        cell.moviePoster.kf.setImage(
            with: URL(string: moviePosterURL),
            placeholder: UIImage(named: "placeholderImage"),
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
        print("heyy")
        performSegue(withIdentifier: "goToDetails", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! MovieDetailsController
        
        if let indexPath = self.collectionView.indexPathsForSelectedItems?[0] {
            destinationVC.movie = viewModel.movies[indexPath.row]
        }
    }
}
extension HomeController: UICollectionViewDelegateFlowLayout {
  // 1

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    return CGSize(width: (view.frame.size.width/2) - 2, height: (view.frame.size.width/2) - 2)
  }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumLineSpacingForSectionAt section: Int
  ) -> CGFloat {
    return 15
  }
    

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
        searchBar.resignFirstResponder()
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
