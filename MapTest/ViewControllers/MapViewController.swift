//
//  ViewController.swift
//  MapTest
//
//  Created by Oleksii Shulzhenko on 27.01.2018.
//  Copyright © 2018 Oleksii Shulzhenko. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import RxSwift
import RxCocoa

class MapViewController: UIViewController {
    
    var timer: Observable<NSInteger>!
    let disposeBag = DisposeBag()
    var needToLocationUpdate = true
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var tableView: UITableView!
    
    let locationManager = CLLocationManager()
    
    var previousLocation: CLLocation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        self.locationManager.startUpdatingLocation()
        
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        timer = Observable<NSInteger>.interval(1, scheduler: MainScheduler.instance)
        
        timer.subscribe(onNext: { [weak self](msecs) in
            self?.needToLocationUpdate = true
            UserModelController.share.retriveUsers(completionBlock: { (_) in })
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.Identifier)
        
        var markers = [GMSMarker]()
        
        UserModelController.share.retriveUsers { [weak self](success) in
            if success {
                guard let strongSelf = self else {return}
                UserModelController.share.userViewModels.asObservable()
                    .bind(to: strongSelf.tableView.rx.items(cellIdentifier: UserCell.Identifier, cellType: UserCell.self)) { (row, element, cell) in
                        cell.textLabel?.text = element.name
                    }
                    .disposed(by: strongSelf.disposeBag)
                
                strongSelf.tableView.rx.itemSelected
                    .subscribe(onNext: { indexPath in
                        strongSelf.mapView.camera = GMSCameraPosition(target: markers[indexPath.row].position, zoom: 15, bearing: 0, viewingAngle: 0)
                        strongSelf.mapView.selectedMarker = markers[indexPath.row]
                    }).disposed(by: strongSelf.disposeBag)
                
                UserModelController.share.userViewModels.asObservable().subscribe(onNext: { (models) in
                    strongSelf.mapView.clear()
                    markers.removeAll()
                    for model in models {
                        let position = model.coordinate!
                        let marker = GMSMarker(position: position)
                        marker.title = model.name
                        marker.map = strongSelf.mapView
                        markers.append(marker)
                    }
                }).disposed(by: strongSelf.disposeBag)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        print("deinit called")
        self.locationManager.stopUpdatingLocation()
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            if let pl = previousLocation {
                if location.distance(from: pl) > 50 || needToLocationUpdate{
                    previousLocation = location
                    FirebaseAPI.instance.setSelfLocation(coordinate: location.coordinate, lastUpdate: NSDate())
                    self.needToLocationUpdate = false
                }
            } else {
                previousLocation = location
                FirebaseAPI.instance.setSelfLocation(coordinate: location.coordinate, lastUpdate: NSDate())
                mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
                self.needToLocationUpdate = false
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

