//
//  FunagramsKit.swift
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 3/22/17.
//  Copyright © 2017 pluggablez. All rights reserved.
//

import CoreData

public class FunagramsKit: NSObject {
    
    let sharedAppGroup = "group.com.pluggablez.funagrams"
    public static let BUNDLE_ID = "com.pluggablez.FunagramsKit"
    let dataModelName = "FunagramModel"
    let databaseName = "Funagrams"
    let errorDomain = "FunagramsKit"
    
    public class var sharedInstance : FunagramsKit {
        struct Static {
            static let instance : FunagramsKit = FunagramsKit()
        }
        return Static.instance
    }

    
    // MARK: - Core Data stack
    
    public lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.makeandbuild.ActivityBuilder" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    public lazy var managedObjectModel: NSManagedObjectModel = {
        var proxyBundle = Bundle(identifier: BUNDLE_ID)
//        if proxyBundle == nil {
//            proxyBundle = Bundle(identifier: WATCH_KIT_BUNDLE_ID)
//        }
        
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = proxyBundle?.url(forResource: self.dataModelName, withExtension: "momd")
        
        return NSManagedObjectModel(contentsOf: modelURL!)!
    }()
    
    public lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        
        var error: NSError? = nil
        
        var sharedContainerURL: URL? = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: self.sharedAppGroup)
        if sharedContainerURL != nil {
            // Create the coordinator and store
            var proxyBundle = Bundle(identifier: FunagramsKit.BUNDLE_ID)
//            if proxyBundle == nil {
//                proxyBundle = Bundle(identifier: FunagramsKit.WATCH_KIT_BUNDLE_ID)
//            }
            var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            
            // copy sqllite db from the application package to the documents folder if it doesn't exists
            let seededDatabaseURL = proxyBundle?.url(forResource: self.databaseName, withExtension: "sqlite")
            let storeURL = sharedContainerURL?.appendingPathComponent("\(self.databaseName).sqlite")
            var fileManagerError:NSError? = nil
            //let didExists = NSFileManager.defaultManager().fileExistsAtPath(storeURL.path!)
            let didCopyDatabase: Bool
            do {
                try FileManager.default.copyItem(at: seededDatabaseURL!, to: storeURL!)
                didCopyDatabase = true
            } catch var error as NSError {
                print(error)
                fileManagerError = error
                didCopyDatabase = false
            } catch {
                fatalError()
            }
            
            if didCopyDatabase {
                
                fileManagerError = nil
                let seededSHMURL = proxyBundle?.url(forResource: self.databaseName, withExtension: "sqlite-shm")
                let shmURL = sharedContainerURL?.appendingPathComponent("\(self.databaseName).sqlite-shm")
                
                let didCopySHM: Bool
                do {
                    try FileManager.default.copyItem(at: seededSHMURL!, to: shmURL!)
                    didCopySHM = true
                } catch var error as NSError {
                    fileManagerError = error
                    didCopySHM = false
                } catch {
                    fatalError()
                }
                if !didCopySHM {
                    print("Error seeding Core Data: \(String(describing: fileManagerError))")
                    abort()
                }
                
                fileManagerError = nil
                let seededWALURL = proxyBundle?.url(forResource: self.databaseName, withExtension: "sqlite-wal")
                let walURL = sharedContainerURL?.appendingPathComponent("\(self.databaseName).sqlite-wal")
                
                let didCopyWAL: Bool
                do {
                    try FileManager.default.copyItem(at: seededWALURL!, to: walURL!)
                    didCopyWAL = true
                } catch var error as NSError {
                    fileManagerError = error
                    didCopyWAL = false
                } catch {
                    fatalError()
                }
                if !didCopyWAL {
                    print("Error seeding Core Data: \(String(describing: fileManagerError))")
                    abort()
                }
                
                print("Seeded Core Data")
            }
            
            //let storeURL = sharedContainerURL.URLByAppendingPathComponent("\(self.dataModelName).sqlite")
            //var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            do {
                try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
            } catch var error1 as NSError {
                error = error1
                
                var dict = [String: Any]()
                dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
                dict[NSLocalizedFailureReasonErrorKey] = "There was an error creating or loading the application's saved data."
                dict[NSUnderlyingErrorKey] = error
                error = NSError(domain: self.errorDomain, code: 9999, userInfo: dict)
                // Replace this with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(String(describing: error)), \(error!.userInfo)")
                abort()
                
            } catch {
                fatalError()
            }
            return coordinator
        }
        return nil
    }()
    
    public lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    public func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(String(describing: error)), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
}
