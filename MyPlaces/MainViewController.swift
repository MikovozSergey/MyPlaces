//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Дарья Станкевич on 3/24/20.
//  Copyright © 2020 Sergey Mikovoz. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewController: UITableViewController {
    
    var places: Results<Place>!// автообновляемый тип контейнера, который возвращает запрашиваемые объекты
    
    override func viewDidLoad() {
        super.viewDidLoad()
        places = realm.objects(Place.self) // вызываем из базы наши объекты
        
        tableView.tableFooterView = UIView()
            
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { // кол-во строк
        return places.isEmpty ? 0 : places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell

        let place = places[indexPath.row]

        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        cell.imageOfPlace.clipsToBounds = true

        return cell
    }

    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) { // кнопка cancel с окна добавления места

        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }

        newPlaceVC.saveNewPlace()
        tableView.reloadData() // обновляем интерфейс
    }
    
    // MARK: - TableView Delegate
    
  override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let place = places[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in

            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])

        return swipeActions
    } // удаление объектов из бд и из списка
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
