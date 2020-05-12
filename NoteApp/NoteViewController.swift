//
//  NoteViewController.swift
//  NoteApp
//
//  Created by 王冠之 on 2020/4/17.
//  Copyright © 2020 Wangkuanchih. All rights reserved.
//

import UIKit

protocol NoteViewControllerDelegate: class {
    func didFinishUpdate(note: Note)
}
class NoteViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var toolBar: UIToolbar!
    
    var currentNote: Note!
    
    var isNewImage: Bool = false
    
    var imageHeighConstraint: NSLayoutConstraint!
    
    weak var delegate : NoteViewControllerDelegate?
    //改寬，所有型態的物件都可以註冊成未被通知的對象
    //條件改成: 所有類型的物件都可以，但是他一定要有didFinishUpdate方法
    

    @IBAction func cameraTool(_ sender: Any) {
        
        let imagePicker = UIImagePickerController() //內建裝置老師會再講
        imagePicker.sourceType = .savedPhotosAlbum //從相簿裝選照片
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    //MARK: UIImagePickerControllerDelegte
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        let image = info[.originalImage] as! UIImage //取得使用者選擇的照片
        self.imageView.image = image //放在imageView上

        self.isNewImage = true
        
        self.dismiss(animated: true, completion: nil) //關閉UIImagePickerController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.textView.text = self.currentNote.text
        self.imageView.image = self.currentNote.image()
        
        self.imageView.layer.borderWidth = 2
        self.imageView.layer.borderColor = UIColor.orange.cgColor
        //CG: Core Graphic
        self.imageView.layer.cornerRadius = 10
        //self.imageView.layer.masksToBounds = true
        //等於 self.imageView.clipsToBounds = true
        
        self.imageView.layer.shadowColor = UIColor.gray.cgColor
        self.imageView.layer.shadowOpacity = 0.8
        self.imageView.layer.shadowOffset = CGSize(width: 10, height: 10)
        
        self.imageHeighConstraint =
            self.imageView.heightAnchor.constraint(equalTo: self.imageView.widthAnchor, multiplier: 0.75)
        if self.traitCollection.verticalSizeClass == .regular {
            self.imageHeighConstraint.isActive = true
        } 
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        if newCollection.verticalSizeClass == .regular {
            self.imageHeighConstraint.isActive = true
        }else{
            self.imageHeighConstraint.isActive = false
        }
    }
    
    @IBAction func done(_ sender: Any) {
        
        self.currentNote.text = self.textView.text
        //self.currentNote.image = self.imageView.image
        
        //image寫到檔案中
        let homeURL = URL(fileURLWithPath: NSHomeDirectory()) //取得sanbox
        let documents = homeURL.appendingPathComponent("Documents") //取得Documents目錄位置
        
        let fileName = "\(self.currentNote.noteId).jpg"
        
        let fileURL = documents.appendingPathComponent(fileName) 
        
        if let imageData = self.imageView.image?.jpegData(compressionQuality: 1){
            do{
                try imageData.write(to: fileURL, options: [.atomicWrite])
                self.currentNote.imageName = fileName
            }catch{
                print("error saving photo \(error)")
            }
        }
        
        //通知到listVC
        self.delegate?.didFinishUpdate(note: self.currentNote)
        //NotificationCenter.default.post(name: .noteUpdate, object: nil, userInfo:["note": self.currentNote ?? Note()] )
        //回到前一頁
        self.navigationController?.popViewController(animated: true)
        
    }
}
