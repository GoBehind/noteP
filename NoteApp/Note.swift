//
//  Note.swift
//  NoteApp
//
//  Created by 王冠之 on 2020/4/16.
//  Copyright © 2020 Wangkuanchih. All rights reserved.
//

import Foundation
import UIKit
import CoreData

//class Note : Equatable {
//class Note: NSObject, NSCoding {
class Note: NSManagedObject {
    
//    func encode(with coder: NSCoder) {
//        coder.encode(self.text, forKey: "text")
//        coder.encode(self.imageName, forKey: "imageName")
//        coder.encode(self.noteId, forKey: "noteID")
//    }
//
//    required init?(coder: NSCoder) {
//        self.noteId = coder.decodeObject(forKey: "noteID") as! String
//        self.text = coder.decodeObject(forKey: "text") as? String
//        self.imageName = coder.decodeObject(forKey: "imageName") as? String
//    }
//

    //判斷兩個Note物件，怎麽樣才叫做相等
    static func == (lhs: Note, rhs: Note) -> Bool {
        return lhs.noteId == rhs.noteId
    }
    
    @NSManaged var noteId : String
    @NSManaged var text : String?
    @NSManaged var imageName : String? //照片檔名 (noteID.jpg or nil)
    
    //從檔案中讀取圖片轉成UIImage
    func image() -> UIImage?{
        if let fileName = self.imageName {
            let homeURL = URL(fileURLWithPath: NSHomeDirectory()) //取得sanbox
            let documents = homeURL.appendingPathComponent("Documents") //取得Documents目錄位置
            let fileURL = documents.appendingPathComponent(fileName)
            return UIImage(contentsOfFile: fileURL.path)
            //從檔案路徑載入UIImage, url.path轉成String形式的路徑
        }
        return nil
    }
    
    //產生縮圖, 50X50縮圖
    func thumbnailImage() -> UIImage?{
        if let image =  self.image() {
            
            let thumbnailSize = CGSize(width:50, height: 50); //設定縮圖大小
            let scale = UIScreen.main.scale //找出目前螢幕的scale，視網膜技術為2.0

            //產生畫布，第一個參數指定大小,第二個參數true:不透明（黑色底）,false表示透明背景,scale為螢幕scale
            UIGraphicsBeginImageContextWithOptions(thumbnailSize,false,scale)
            
            //計算長寬要縮圖比例，取最大值MAX會變成UIViewContentModeScaleAspectFill
            //最小值MIN會變成UIViewContentModeScaleAspectFit
            let widthRatio = thumbnailSize.width / image.size.width;
            let heightRadio = thumbnailSize.height / image.size.height;
            
            let ratio = max(widthRatio,heightRadio);
            
            let imageSize = CGSize(width:image.size.width*ratio,height: image.size.height*ratio);
            
            let circlePath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: thumbnailSize.width, height: thumbnailSize.height))
            
            circlePath.addClip()
            
            image.draw(in:CGRect(x: -(imageSize.width-thumbnailSize.width)/2.0,y: -(imageSize.height-thumbnailSize.height)/2.0,
                width: imageSize.width,height: imageSize.height))
            //取得畫布上的縮圖
            let smallImage = UIGraphicsGetImageFromCurrentImageContext();
            //關掉畫布
            UIGraphicsEndImageContext();
            return smallImage
        }else{
            return nil;
        }
    }
    
    override func awakeFromInsert() {
        self.noteId = UUID().uuidString //產生隨機的亂碼
    }
}
