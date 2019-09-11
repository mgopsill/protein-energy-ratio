//
//  StationSearchViewController.swift
//  ProteinEnergyRatio
//
//  Created by Mike Gopsill on 13/08/2019.
//  Copyright © 2019 mgopsill. All rights reserved.
//

import UIKit

//protocol StationSearchDelegate: NSObject {
//    func didSelect(station: Station)
//}

class FoodSearchViewController: UITableViewController {
    
//    weak var delegate: StationSearchDelegate?
    
    var foods = [String]()

    private var searchController: UISearchController!
    private var resultsTableController: SearchResultsTableController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultsTableController = SearchResultsTableController()
        resultsTableController.tableView.delegate = self
        searchController = UISearchController(searchResultsController: resultsTableController)
        searchController.searchResultsUpdater = self
        searchController.searchBar.autocapitalizationType = .none
        
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        
//        StationService().getStations { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let stations):
//                self.stations = stations
//                self.tableView.reloadData()
//            case .failure:
//                self.tableView.reloadData() // TODO: Handle failed network call
//            }
//        }
        
        
    }
}

// MARK: - UITableViewDelegate

extension FoodSearchViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectedStation: Station
//
//        if tableView === self.tableView {
//            selectedStation = stations[indexPath.row]
//        } else {
//            selectedStation = resultsTableController.filteredStations[indexPath.row]
//        }
//
//        delegate?.didSelect(station: selectedStation)
//        tableView.deselectRow(at: indexPath, animated: false)
//
//        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension FoodSearchViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foods.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("gettingcell")
        let cell = UITableViewCell() // TODO: Dequeuecells and custom cells
        let food = foods[indexPath.row]
        cell.textLabel?.text = food
        return cell
    }
}

// MARK: - UISearchBarDelegate

extension FoodSearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

}


// MARK: - UISearchResultsUpdating

extension FoodSearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        print("updating with text \(searchController.searchBar.text)")
        guard let text = searchController.searchBar.text else { return }
//        FoodService().search(for: text) { _ in
//        }
        
        FoodService().search(for: text) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let foods):
                self.foods = foods
                self.tableView.reloadData()
                if let resultsController = searchController.searchResultsController as? SearchResultsTableController {
                                    resultsController.filteredFoods = foods
                    
                                    resultsController.tableView.reloadData()
                                }
            case .failure:
                self.tableView.reloadData() // TODO: Handle failed network call
            }
        }
            
            
//            let searchResults = foods
//            let filteredResults = searchResults.filter { $0.lowercased().contains(searchController.searchBar.text?.lowercased() ?? "") }
//            if let resultsController = searchController.searchResultsController as? SearchResultsTableController {
//                resultsController.filteredFoods = filteredResults
//                resultsController.tableView.reloadData()
//            }
//        }
    }
}
