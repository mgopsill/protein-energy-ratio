//
//  SearchResultsTableController.swift
//  ProteinEnergyRatio
//
//  Created by Mike Gopsill on 14/08/2019.
//  Copyright © 2019 mgopsill. All rights reserved.
//

import UIKit

class SearchResultsTableController: UITableViewController {
    
    var filteredFoods = [String]()
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFoods.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let food = filteredFoods[indexPath.row]
        cell.textLabel?.text = food
        return cell
    }
}
