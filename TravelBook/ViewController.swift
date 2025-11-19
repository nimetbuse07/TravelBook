

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var nameText: UITextField!
    
    @IBOutlet weak var commentText: UITextField!
    
    var chosenLatitude = Double()
    var chosenLongitude = Double()
    
    var selectedTitle = ""
    var selectedId : UUID?
    
    var annonationTitle = ""
    var annonationSubTitle = ""
    var annonationLongitude = Double()
    var annonationLatitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if selectedTitle != ""{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let conntext = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            let idString = selectedId!.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try conntext.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let title = result.value(forKey: "title") as? String {
                            annonationTitle = title
                            if let subtitle = result.value(forKey: "subtitle") as? String {
                                annonationSubTitle = subtitle
                                if let longitude = result.value(forKey: "longitude") as? Double {
                                    annonationLongitude = longitude
                                    if let latitude = result.value(forKey: "latitude") as? Double {
                                        annonationLatitude = latitude
                                        
                                        let annonation = MKPointAnnotation()
                                        annonation.title = annonationTitle
                                        annonation.subtitle = annonationSubTitle
                                        let coordinate = CLLocationCoordinate2D(latitude: annonationLatitude, longitude: annonationLongitude)
                                        annonation.coordinate = coordinate
                                        
                                        mapView.addAnnotation(annonation)
                                        nameText.text = annonationTitle
                                        commentText.text = annonationSubTitle
                                        locationManager.stopUpdatingLocation()
                                        
                                        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                        let region = MKCoordinateRegion(center: coordinate, span: span)
                                        mapView.setRegion(region, animated: true)
                        }}}}
                    }
                }
            }catch{
                
            }
        }else {
            
        }
        
        let gestureRecogizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer: )))
        gestureRecogizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(gestureRecogizer)
        
        let keyboardGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(keyboardGestureRecognizer)
      
    }
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @objc func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer){
        
        if gestureRecognizer.state == .began {
            let touchedPoint = gestureRecognizer.location(in: self.mapView)
            let touchedCoordinate = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            let annonation = MKPointAnnotation()
            
            chosenLatitude = touchedCoordinate.latitude
            chosenLongitude = touchedCoordinate.longitude
            
            annonation.coordinate = touchedCoordinate
            annonation.title = nameText.text
            annonation.subtitle = commentText.text
            mapView.addAnnotation(annonation)
        }
    }
    
 
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if selectedTitle == "" {
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
        }else {
            
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            if annotation is MKUserLocation {
                return nil
            }
            
            let reuseId = "myAnnotation"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
            
            if pinView == nil {
                pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                pinView?.canShowCallout = true
                pinView?.tintColor = UIColor.black
                
                let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
                pinView?.rightCalloutAccessoryView = button
                
            } else {
                pinView?.annotation = annotation
            }
            
            
            
            return pinView
        }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
           if selectedTitle != "" {
               
               let requestLocation = CLLocation(latitude: annonationLatitude, longitude: annonationLongitude)
               
               
               CLGeocoder().reverseGeocodeLocation(requestLocation) { (placemarks, error) in
                   //closure
                   
                   if let placemark = placemarks {
                       if placemark.count > 0 {
                                         
                           let newPlacemark = MKPlacemark(placemark: placemark[0])
                           let item = MKMapItem(placemark: newPlacemark)
                           item.name = self.annonationTitle
                           let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                           item.openInMaps(launchOptions: launchOptions)
                                         
                   }
               }
           }
               
               
           }
       
       
       
       
       }
       
    

    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        
        newPlace.setValue(nameText.text, forKey: "title")
        newPlace.setValue(commentText.text, forKey: "subtitle")
        newPlace.setValue(UUID(), forKey: "id")
        newPlace.setValue(chosenLatitude, forKey: "latitude")
        newPlace.setValue(chosenLongitude, forKey: "longitude")
        
        do {
            try context.save()
            print("başarılı")
        }catch{
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newPlace"), object: nil)
        navigationController?.popViewController(animated: true)
    }
    
    
}

