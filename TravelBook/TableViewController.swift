import UIKit
import CoreData

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var tableView: UITableView!
    var titleArray = [String]()
    var idArray = [UUID]()
    
    var chosenTitle = ""
    var chosenId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        getData()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newPlace"), object: nil)
    }
    @objc func addButtonClicked () {
        chosenTitle = ""
        performSegue(withIdentifier: "toViewController", sender: nil)
    }
    
    @objc func getData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
           let results =  try context.fetch(fetchRequest)
            if results.count > 0 {
                self.titleArray.removeAll(keepingCapacity: false)
                    self.idArray.removeAll(keepingCapacity: false)
                
                for result in results as! [NSManagedObject] {
                    if let title = result.value(forKey: "title") as? String {
                        titleArray.append(title)
                    }
                    if let id = result.value(forKey: "id") as? UUID{
                        idArray.append(id)
                    }
                    tableView.reloadData()
                }
            }
            
        }catch {
            print("error")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = titleArray[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenTitle = titleArray[indexPath.row]
        chosenId = idArray[indexPath.row]
        performSegue(withIdentifier: "toViewController", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toViewController" {
            let destinationVC = segue.destination as! ViewController
                destinationVC.selectedTitle = chosenTitle
                destinationVC.selectedId = chosenId
            
        }
    }
  
}
