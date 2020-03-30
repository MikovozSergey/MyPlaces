//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by Дарья Станкевич on 3/30/20.
//  Copyright © 2020 Sergey Mikovoz. All rights reserved.
//

import UIKit

class NewPlaceViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
    }


    // MARK: - Table view delegate
            
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            
        } else {
            view.endEditing(true)
        }
    }
}

// MARK: - Text filed delegate

extension NewPlaceViewController: UITextFieldDelegate {
    // скрываем клавиатуру по нажатию на done
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
