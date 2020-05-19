//
//  ListViewController.swift
//  NoteApp
//
//  Created by 王冠之 on 2020/4/16.
//  Copyright © 2020 Wangkuanchih. All rights reserved.
//

import UIKit
import CoreData
import StoreKit
import MessageUI
import FirebaseAnalytics
import GoogleMobileAds

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NoteViewControllerDelegate, MFMailComposeViewControllerDelegate, GADBannerViewDelegate {
    
    var bannerView: GADBannerView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topCosnstraint: NSLayoutConstraint!
    @IBAction func support(){
        
        if ( MFMailComposeViewController.canSendMail()){
            let alert = UIAlertController(title: "", message: "We want to hear from you, Please send us your feedback by email in English", preferredStyle: .alert)
            let email = UIAlertAction(title: "email", style: .default, handler: { (action) -> Void in
                let mailController =  MFMailComposeViewController()
                mailController.mailComposeDelegate = self
                mailController.title = "I have question"
                mailController.setSubject("I have question")
                let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
                let product = Bundle.main.object(forInfoDictionaryKey: "CFBundleName")
                let messageBody = "<br/><br/><br/>Product:\(product!)(\(version!))"
                mailController.setMessageBody(messageBody, isHTML: true)
                mailController.setToRecipients(["support@yoursupportemail.com"])
                self.present(mailController, animated: true, completion: nil)
            })
            alert.addAction(email)
            self.present(alert, animated: true, completion: nil)
        }else{
            //alert user can't send email
        }
    }
    
    //MARK: MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch (result){
        case MFMailComposeResult.cancelled:
            print("user cancelled")
        case MFMailComposeResult.failed:
            print("user failed")
        case MFMailComposeResult.saved:
            print("user saved email")
        case MFMailComposeResult.sent:
            print("email sent")
        @unknown default:
            print("Fail")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    var data : [Note] = [] //model: 資料用Array，裡面只能放Note類型的物件
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        loadFromCoreData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ListViewController.noteUpdate(notification:)), name: .noteUpdate, object: nil)
    }
    
    @objc func noteUpdate(notification: Notification){
        if let note = notification.userInfo?["note"] as? Note {
            if let position = self.data.firstIndex(of: note) {
                
                //self.writeToFile()
                self.saveToCoreData()
                //組成indexPath物件
                let indexPath = IndexPath(row: position, section: 0)
                //通知TableView reload特定位置的cell
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.navigationItem.title = NSLocalizedString("list", comment: "")
        
        //iOS 11 以上的環境才運行
        if #available(iOS 11.0, *){
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        //利用系統提供的編輯按鈕
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        //admob
        self.bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        self.bannerView.translatesAutoresizingMaskIntoConstraints = false
        self.bannerView.adUnitID = "ca-app-pub-3822241008799890/5932434756"
        
        self.bannerView.delegate = self
        self.bannerView.rootViewController = self
        self.bannerView.load(GADRequest())
    
    }
    
    //廣告進來時會呼叫，GADBannerViewDelegate
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        //self.tableView.tableHeaderView = self.bannerView
        if self.bannerView.superview == nil{
            self.topCosnstraint.isActive = false
            self.view.addSubview(self.bannerView)
            
            self.bannerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
            self.bannerView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
            self.bannerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
            self.bannerView.bottomAnchor.constraint(equalTo: self.tableView.topAnchor, constant: 0).isActive = true
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //SKStoreReviewController.requestReview()
        
        support()
        
//        let alert = UIAlertController(title: "請登入", message: "輸入帳號密碼", preferredStyle: .alert)
//        
//        alert.addTextField { (textField) in
//            textField.placeholder = "請輸入帳號"
//        }
//        alert.addTextField { (textField) in
//            textField.placeholder = "請輸入密碼"
//        }
//        
//        let okaction = UIAlertAction(title: "請登入", style: .default) { (action) in
//            
//            let account = alert.textFields?[0].text
//            let password = alert.textFields?[1].text
//            UserDefaults.standard.set(account, forKey: "user-account")
//            UserDefaults.standard.set(password, forKey: "user-password")
//            UserDefaults.standard.synchronize()
//            
//            let gg = UIAlertController(title: "帳號已登錄", message: "帳號: \(String(describing: UserDefaults.standard.string(forKey: "user-account"))), \r\n 密碼為 \(String(describing: UserDefaults.standard.string(forKey: "user-password")))", preferredStyle: .alert)
//            let ggaction = UIAlertAction(title: "ok", style: .cancel, handler: nil)
//            gg.addAction(ggaction)
//            self.present(gg, animated: true, completion: nil)
//        }
//        
//        alert.addAction(okaction);
//        self.present(alert, animated: true, completion: nil)
    }
    
    //MAEK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath)
        //let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! NoteCell
        //let note = self.data[indexPath.row]
        cell.textLabel?.text = self.data[indexPath.row].text
        //cell.myLabel.text = note.text
        cell.imageView?.image = self.data[indexPath.row].thumbnailImage()
        cell.showsReorderControl = true
        cell.accessoryType = .disclosureIndicator
        //cell.accessoryView = UISwitch()
        
        let now = Date()
        let dateformatter = DateFormatter()
        let calendar = Calendar(identifier: .republicOfChina)
        dateformatter.calendar = calendar
        dateformatter.dateStyle = .long
        dateformatter.timeStyle = .short
        cell.detailTextLabel?.text = dateformatter.string(from: now)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            
            //p.320
            let data = self.data.remove(at: indexPath.row)
            let moc = CoreDataHelper.shared.managedObjectContext()
            moc.performAndWait {
                moc.delete(data)
            }
            //儲存
            self.saveToCoreData()
            //self.writeToFile()
            
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //呼叫時畫面已經換好位置，處理相對應陣列中Note的位置
        //先把Note從原本位置移出來，再塞到新的位置
        let note = self.data.remove(at: sourceIndexPath.row)
        self.data.insert(note, at: destinationIndexPath.row)
    }
    
//    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //如果該位置的cell在畫面上，則回傳該cell，如果不在畫面上則回傳nil
        //let cell = tableView.cellForRow(at: indexPath)
        //print(cell?.isSelected) //true，cell灰色的
        tableView.deselectRow(at: indexPath, animated: true)
        /*
        if let noteVC = self.storyboard?.instantiateViewController(withIdentifier: "noteVC"){
            self.navigationController?.pushViewController(noteVC, animated: true)
            //self.show(noteVC, sender: self)
        }*/
        
        
    }
    
/*
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row % 2 == 1 {
            return 50
        }
        return 100
    }
*/
    
    func loadFromFile(){
        //檔案寫入self.data
        let homeURL = URL(fileURLWithPath: NSHomeDirectory()) //取得Sandbox
        let documents = homeURL.appendingPathComponent("Documents")
        let fileURL = documents.appendingPathComponent("note.archive") //檔名可以隨便取
        
        do{
            let data = try Data(contentsOf: fileURL)
            if let arrayData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Note]{
                self.data = arrayData
            } else {
                self.data = []
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func writeToFile(){
        //self.data->
        //先有路徑. Document下notes.archive
        let homeURL = URL(fileURLWithPath: NSHomeDirectory()) //取得Sandbox
        let documents = homeURL.appendingPathComponent("Documents")
        let fileURL = documents.appendingPathComponent("note.archive") //檔名可以隨便取
        do{
            let data = try NSKeyedArchiver.archivedData(withRootObject: self.data, requiringSecureCoding: false)
            try data.write(to: fileURL, options: .atomicWrite) //寫入檔案
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func loadFromCoreData(){
        let moc = CoreDataHelper.shared.managedObjectContext()
        let fetchResquest = NSFetchRequest<Note>(entityName: "Note")
        
//        let predicate = NSPredicate(format: "text like %@", "*New Note*")
//        fetchResquest.predicate = predicate
        //排序
        let sort = NSSortDescriptor(key: "text", ascending: true)
        fetchResquest.sortDescriptors = [sort]
        
        moc.performAndWait {
            do{
                let result = try moc.fetch(fetchResquest)
                self.data = result
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func saveToCoreData(){
        CoreDataHelper.shared.saveContext()
    }
    
    @IBAction func edit(_ sender: Any) {
        
        //self.tableView.isEditing = !self.tableView.isEditing
        self.tableView.setEditing(!self.tableView.isEditing, animated: true)
    }
    
    
    @IBAction func upload(_ sender: Any) {
        let activityView = UIActivityIndicatorView(style: .medium)
        activityView.translatesAutoresizingMaskIntoConstraints = false
        let barButton = sender as! UIBarButtonItem
        barButton.customView = activityView //改變按鈕的view
        activityView.startAnimating() //開始轉動
        
        //async: 非同步，下方程式什麼時候執行是不確定的
        DispatchQueue.global().async {
            //把以下程式碼丟到Thread 2 以後運行
            //避免Tread 1長時間被佔用，畫面會停頓
            Thread.sleep(forTimeInterval: 3) //模擬檔案下載需要3秒鐘
            
            //與畫面有關的一定要在Thread 1執行
            DispatchQueue.main.async {
                barButton.customView = nil //把按鈕的圖示改成原本的圖案
            }
        }
    }
    
//    @IBAction func askForRating(){
//
//        let askController = UIAlertController(title: "Hello App User",
//                                              message: "If you like this app,please rate in App Store. Thanks.",
//                                              preferredStyle: .alert)
//        let laterAction = UIAlertAction(title: "稍候再評",
//                                        style: .default, handler: nil)
//        askController.addAction(laterAction)
//        let okAction = UIAlertAction(title: "我要評分", style: .default)
//        { (action) -> Void in
//            let appID = "12345"
//            let appURL =
//                URL(string: "https://itunes.apple.com/us/app/itunes-u/id\(appID)?action=write-review")!
//            UIApplication.shared.open(appURL, options: [:],
//                                      completionHandler: { (success) in
//            })
//        }
//        askController.addAction(okAction)
//        self.present(askController, animated: true, completion: nil)
//    }
    
    @IBAction func addNote(_ sender: Any) {
        
        Analytics.logEvent("addNote", parameters: nil)
        
        let moc = CoreDataHelper.shared.managedObjectContext()
        let note = Note(context: moc)
        note.text = NSLocalizedString("new.note", comment: "")
        //self.data.append(note)
        
        //新增至第一筆
        self.data.insert(note, at: 0)
        
        //self.writeToFile()
        self.saveToCoreData()
        
        let indexPath = IndexPath(row: 0, section: 0)
        
        //第二參數是動畫
        self.tableView.insertRows(at: [indexPath], with: .automatic)
        
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "noteVCSegue"{
            let noteVC = segue.destination as! NoteViewController
            
            if let indexPath = self.tableView.indexPathForSelectedRow{
                let note = self.data[indexPath.row]
                
                //傳到下一個畫面
                noteVC.currentNote = note
                noteVC.delegate = self
            }
        }
    }
    
    func didFinishUpdate(note: Note) {
        //被通知的方法，等待按下done被呼叫
        //self.tableView.reloadData()
        //取得note在data中的位置
        if let position = self.data.firstIndex(of: note) {
            //self.writeToFile()
            self.saveToCoreData()
            //組成indexPath物件
            let indexPath = IndexPath(row: position, section: 0)
            //通知TableView reload特定位置的cell
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

extension Notification.Name {
    static let noteUpdate = Notification.Name("noteUpdated")
}
