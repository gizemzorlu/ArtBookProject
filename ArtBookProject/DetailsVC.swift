//
//  DetailsVC.swift
//  ArtBookProject
//
//  Created by Gizem Zorlu on 21.05.2023.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenPainting = ""
    var chosenPaintingId : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPainting != "" {
            
            saveButton.isHidden = true
            
            // Core Data
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            
            let idString = chosenPaintingId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    
                    for result in results as! [NSManagedObject] {
                        
                        if let name = result.value(forKey: "name") as? String {
                            nameText.text = name
                            
                        }
                        if let artist = result.value(forKey: "artist") as? String {
                            artistText.text = artist
                            
                            
                        }
                        if let year = result.value(forKey: "year") as? Int {
                            yearText.text = String(year)
                            
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                            
                        }
                    }
                    
                    
                }
                
            } catch {
                print("error")
                
            }
            
        } else {
            
            saveButton.isHidden = false
            saveButton.isEnabled = false
            
        }
        
            
            // Recognizers
            
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
            view.addGestureRecognizer(gestureRecognizer)
            
            
            imageView.isUserInteractionEnabled = true
            let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
            imageView.addGestureRecognizer(imageTapRecognizer)
            
        }
        
        @objc func selectImage() {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true
            present(picker, animated: true)
            
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            imageView.image = info[.originalImage] as? UIImage
            saveButton.isEnabled = true
            self.dismiss(animated: true)
            
        }
        
        @objc func hideKeyboard() {
            view.endEditing(true)
        }
        
        @IBAction func saveClicked(_ sender: Any) {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let newPaintings = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
            
            // Attributes
            
            newPaintings.setValue(artistText.text!, forKey: "artist")
            
            newPaintings.setValue(nameText.text!, forKey: "name")
            
            if let year = Int(yearText.text!) {
                
                newPaintings.setValue(year, forKey: "year")
            }
            
            newPaintings.setValue(UUID(), forKey: "id")
            
            let data = imageView.image!.jpegData(compressionQuality: 0.5)
            
            newPaintings.setValue(data, forKey: "image")
            
            do {
                try context.save()
                print("success")
            } catch {
                print("error")
            }
            
            NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
            self.navigationController?.popViewController(animated: true)
        }
        
    }

