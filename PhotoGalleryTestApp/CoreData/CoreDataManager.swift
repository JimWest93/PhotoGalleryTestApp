import Foundation
import CoreData
import UIKit

class CoreDataManager {
    
    static var shared: CoreDataManager = {
        let instance = CoreDataManager()
        return instance
    }()
    
    func context() -> NSManagedObjectContext {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    func photoDataSaver(hits: [PhotosData]) {
        
        let context = context()
        
        guard let entity = NSEntityDescription.entity(forEntityName: "FetchDateEntity", in: context) else { return }
        
        hits.forEach({ [weak self] hit in

            let object = FetchDateEntity(entity: entity, insertInto: context)
            object.date = Date()
            object.photoURL = hit.largeImageURL
            
            if self?.notesData(photoURL: hit.largeImageURL) == nil {
                
                do {
                    
                    try context.save()
                    
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                
            } else { return }
        })
    }
    
    func notesData(photoURL: String) -> FetchDateEntity? {
        
        let context = context()
        
        var objects: [FetchDateEntity] = []
        
        let fetchRequest: NSFetchRequest<FetchDateEntity> = FetchDateEntity.fetchRequest()
        
        do {
            
            objects = try context.fetch(fetchRequest)
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        for object in objects {
            if object.photoURL == photoURL {
                return object
            }
        }
        
        return nil
        
    }
    
}
