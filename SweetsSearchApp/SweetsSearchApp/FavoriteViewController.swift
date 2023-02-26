//
//  FavoriteViewController.swift
//  SweetsSearchApp
//
//  Created by K Barnes on 2023/01/07.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

struct OkashiInfo: Codable {
    
    @DocumentID var documentId: String?
    
    var name: String
    
    var maker: String
    
    var image: String
    
    var url: String
    
    var id: String
    
    var memo: String
    
}


class FavoriteViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, UITextViewDelegate {
    
    var okashiDataArray:[OkashiInfo] = []
    
    @IBOutlet weak var okashiFavoriteTableView: UITableView!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let db = Firestore.firestore()
        
        okashiFavoriteTableView.dataSource = self
        
        okashiFavoriteTableView.delegate = self
        
        self.navigationItem.title = "お気に入り"
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        
        
    }
    
    
    //    WebViewControllerから戻ったタイミングで、更新したメモの内容がviewDidLoad内だと反映されないため、viewWillAppearにてFirebaseのデータを呼び出させる
    override func viewWillAppear(_ animated: Bool) {
        
        getData()
        
        //ゆっくり付けたり消したりする
        if let indexPathForSelectedRow = okashiFavoriteTableView.indexPathForSelectedRow {
            
            okashiFavoriteTableView.deselectRow(at: indexPathForSelectedRow, animated: true)
            
        }
        
    }
    
    
    func getData() {
        
        //        重複してデータが読まれるのでokashiDataArrayをここで一旦空にする
        self.okashiDataArray.removeAll()
        
        // Firestoreからデータを取得
        db.collection("favorite_sweets").getDocuments { (_snapShot, _error) in
            
            if let snapShot = _snapShot {
                
                let documents = snapShot.documents
                
                let okashiList = documents.compactMap {
                    
                    // この1行でデコード終了
                    return try? $0.data(as: OkashiInfo.self)
                    
                }
                
                self.okashiDataArray.append(contentsOf: okashiList)
                
                
            } else {
                
                print("Data Not Found")
                
            }
            
            // データ取得が終わったタイミングでtableViewをリロードデータ
            self.okashiFavoriteTableView.reloadData()
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.okashiDataArray.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        let okashiName = okashiDataArray[indexPath.row].name
        
        let okashiMaker = okashiDataArray[indexPath.row].maker
        
        cell.textLabel?.text = (okashiName)
        
        cell.detailTextLabel?.text = (okashiMaker)
        
        let imageStr = okashiDataArray[indexPath.row].image
        
        let url = URL(string: imageStr)
        
        do {
            
            let data = try! Data(contentsOf: url!)
            
            cell.imageView?.image = UIImage(data: data)!
            
        } catch {
            
            print(error)
            
        }
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let webViewController = self.storyboard?.instantiateViewController(withIdentifier: "goWeb") as! WebViewController
        
        webViewController.getURL = okashiDataArray[indexPath.row].url
        
        webViewController.getName = okashiDataArray[indexPath.row].name
        
        webViewController.getId = okashiDataArray[indexPath.row].id
        
        webViewController.getImage = okashiDataArray[indexPath.row].image
        
        webViewController.getMaker = okashiDataArray[indexPath.row].maker
        
        webViewController.getDocumentId = okashiDataArray[indexPath.row].documentId!
        
        webViewController.getMemo = okashiDataArray[indexPath.row].memo
        
        self.navigationController?.pushViewController(webViewController, animated: true)
        
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let documentID = okashiDataArray[indexPath.row].documentId
        let editAction = UIContextualAction(style: .destructive, title: "削除") { (action, view, completionHandler) in
            
            self.db.collection("favorite_sweets").document(documentID!).delete() { err in
                
                if let err = err {
                    
                    print("Error removing document: \(err)")
                    
                } else {
                    
                    self.okashiDataArray.remove(at: indexPath.row)
                    
                    self.okashiFavoriteTableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
                    
                }
                
            }
            
            // 実行結果に関わらず記述
            completionHandler(true)
            
        }
        
        return UISwipeActionsConfiguration(actions: [editAction])
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 150
        
    }
    
}

