//
//  NoteDetailControllerViewController.swift
//  Notes-App
//
//  Created by Dinh Phu Quoc on 06/12/2017.
//  Copyright © 2017 if26. All rights reserved.
//

import UIKit
import os.log

class NoteDetailController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var titreNoteTextField: UITextField!
    @IBOutlet weak var contentNoteTextView: UITextView!
    @IBOutlet weak var imageNote: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIView!
    
    var note: Note?
    var dateCreateNote : Date?
    var isModified : Bool = false
    var imageBase64 = "defaultPhoto"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        titreNoteTextField.delegate = self
        contentNoteTextView.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        imageView.addGestureRecognizer(tapGesture)
        
        navigationItem.setHidesBackButton(true, animated: true)
        if note == nil {
            contentNoteTextView.text = "No Additional Text"
            contentNoteTextView.textColor = UIColor.lightGray
        }
        
        if let note = note {
            navigationItem.title = note.titre
            titreNoteTextField.text = note.titre
            contentNoteTextView.text = note.content
            if note.imageBase64 == "defaultPhoto" {
                imageNote.image = #imageLiteral(resourceName: "defaultPhoto")
            } else {
                let dataDecoded : Data = Data(base64Encoded: note.imageBase64, options: .ignoreUnknownCharacters)!
                let decodedImage = UIImage(data: dataDecoded)
                imageNote.image = decodedImage
            }
        }
        
        updateSaveButtonState()
        
    }
    
    @objc func imageViewTapped(){
        titreNoteTextField.endEditing(true)
        contentNoteTextView.endEditing(true)
    }
    
    
    // MARK: Selecte Photo
    
    // TODO : call when user taps the image picker's Cancel Button
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // TODO: call when user finish choose image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // The info dictionary may contain multiple representations of the image. We want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        imageNote.image = selectedImage
        if selectedImage.imageOrientation != UIImageOrientation.up {
            UIGraphicsBeginImageContextWithOptions(selectedImage.size, false, selectedImage.scale)
            
            selectedImage.draw(in: CGRect(x: 0, y: 0, width: selectedImage.size.width, height: selectedImage.size.height))
            
            let normalImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            let imageData:Data = UIImageJPEGRepresentation(normalImage!, 0.7)!
            imageBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
        } else {
            let imageData:Data = UIImageJPEGRepresentation(selectedImage, 0.7)!
            imageBase64 = imageData.base64EncodedString(options: .endLineWithLineFeed)
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func takePhotoPressed(_ sender: UIBarButtonItem) {
        // TODO: Hide the keyboard
        titreNoteTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .camera
        
        // Make sure ViewController is notified when the user picks an image
        imagePickerController.delegate = self
        
        present(imagePickerController,animated: true,completion: nil)
    }
    
    
    @IBAction func photoLibraryPressed(_ sender: UIBarButtonItem) {
        // TODO: Hide the keyboard
        titreNoteTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image
        imagePickerController.delegate = self
        
        present(imagePickerController,animated: true,completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        var titre = titreNoteTextField.text ?? "New Note"
        var content = contentNoteTextView.text ?? "No Additional Text"

        if titre == "" {
            titre = "New Note"
        }
        if content == "" {
            content = "No Additional Text"
        }
        if note?.dateCreated != nil {
            note = Note(titre: titre, content: content,category: categoryChosen,imageBase64: imageBase64, dateCreated: (note?.dateCreated)!, isModified: false)
        } else {
            note = Note(titre: titre, content: content,category: categoryChosen,imageBase64: imageBase64, dateCreated: Date(), isModified: false)
        }
        
    }
    
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
        let isPresentingInAddNoteMode = presentingViewController is UINavigationController
        if isPresentingInAddNoteMode {
            dismiss(animated: true, completion: nil)
        } else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        } else {
             fatalError("The NoteDetailController is not inside a navigation controller.")
        }
    }
    
    
    // MARK : UITextFieldDelegate Section
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.title = textField.text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    
    // MARK: UITextViewDelegate Section
    func textViewDidBeginEditing(_ textView: UITextView) {
        saveButton.isEnabled = false
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        updateSaveButtonState()
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    private func updateSaveButtonState() {
        // Disable save button when the titre and the content is empty
        let titre = titreNoteTextField.text ?? ""
        var content = contentNoteTextView.text ?? ""
        if content == "No Additional Text" {
            content = ""
        }
        if titre.isEmpty && content.isEmpty {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }
    
//    function reduce quality of image
//    extension UIImage {
//        // MARK: - UIImage+Resize
//        func compressTo(_ expectedSizeInMb:Int) -> UIImage? {
//            let sizeInBytes = expectedSizeInMb * 1024 * 1024
//            var needCompress:Bool = true
//            var imgData:Data?
//            var compressingValue:CGFloat = 1.0
//            while (needCompress && compressingValue > 0.0) {
//                if let data:Data = UIImageJPEGRepresentation(self, compressingValue) {
//                    if data.count < sizeInBytes {
//                        needCompress = false
//                        imgData = data
//                    } else {
//                        compressingValue -= 0.1
//                    }
//                }
//            }
//
//            if let data = imgData {
//                if (data.count < sizeInBytes) {
//                    return UIImage(data: data)
//                }
//            }
//            return nil
//        }
//    }
}
