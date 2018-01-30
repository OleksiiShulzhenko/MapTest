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
        //self.locationManager.requestLocation()
        
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        timer = Observable<NSInteger>.interval(30, scheduler: MainScheduler.instance)
        
        timer.subscribe(onNext: { [weak self](msecs) in
            self?.needToLocationUpdate = true
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        UserModelController.share.retriveUsers { (success) in
            if success {
                UserModelController.share.userViewModels.
                    .bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { (row, element, cell) in
                        cell.textLabel?.text = "\(element) @ row \(row)"
                    }
                    .disposed(by: disposeBag)
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

