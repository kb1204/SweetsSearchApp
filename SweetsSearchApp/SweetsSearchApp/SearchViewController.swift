//
//  SearchViewController.swift
//  SweetsSearchApp
//
//  Created by K Barnes on 2023/01/06.
//

import UIKit
import SafariServices
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore


struct GetDocumentID: Codable {
    
    @DocumentID var documentId: String?
    
}


class SearchViewController: UIViewController,SFSafariViewControllerDelegate,UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return okashiList.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = okashiList[indexPath.row]["name"] as? String
        
        let imageStr = okashiList[indexPath.row]["image"] as? String
        
        let url = URL(string: imageStr!)
        
        do {
            
            let data = try! Data(contentsOf: url!)
            
            cell.imageView?.image = UIImage(data: data)!
            
        } catch {
            
            print(error)
            
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let safariURL = URL(string: okashiList[indexPath.row]["url"] as! String)
        
        let tapCellValue = SFSafariViewController(url: safariURL!)
        
        tapCellValue.delegate = self
        
        present(tapCellValue, animated: true, completion: nil)
        
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // 編集処理
        let editAction = UIContextualAction(style: .destructive, title: "お気に入り登録") { (action, view, completionHandler) in
            // 編集処理を記述
            let sweetsValue = self.okashiList[indexPath.row]
            
            let doc = "\(sweetsValue["id"]!):\(sweetsValue["name"]!)"
            
            //            登録済み商品と新規登録商品の選別
            if self.documentArray.contains(doc) == true {
                
                let dialog = UIAlertController(title: "登録済みの商品です", message: "", preferredStyle: .alert)
                
                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                self.present(dialog, animated: true, completion: nil)
                
            } else {
                
                let dialog = UIAlertController(title: "登録しました", message: "", preferredStyle: .alert)
                
                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                self.present(dialog, animated: true, completion: nil)
                
           }
            
            let docRef = Firestore.firestore().collection("favorite_sweets").document(doc)
            //　FirebaseにURL型が登録出来ない為、URL型からString型へキャスト
            let strURL = sweetsValue["url"] as! String
            
            let strImage = sweetsValue["image"] as! String
            
            let pageViewCountData = ["id": sweetsValue["id"], "name": sweetsValue["name"], "maker": sweetsValue["maker"], "url": strURL, "image": strImage, "memo": ""]
            //　Firebaseの書き込み処理
            docRef.setData(pageViewCountData) { (err) in
                
                if let err = err {
                    
                    print("FirestoreへのPageViewCountの保存に失敗した。　\(err)")
                    
                    return
                    
                }
                
                self.documentArray.append(doc)
                
            }
            
            // 実行結果に関わらず記述
            completionHandler(true)
            
        }
        
        return UISwipeActionsConfiguration(actions: [editAction])
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
            return 150
        
        }
    
    
    @IBOutlet weak var okashiSearchTableView: UITableView!
    
    @IBOutlet weak var okashiSearchBar: UISearchBar!
    
    var okashiDataRow:Dictionary<String,Any> = [:]
    
    var okashiList = [[String:Any]]()
    
    var documentArray = [String]()
    
    let db = Firestore.firestore()
    
    var cellCount = ""
    
    var cellCount2 = ""
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //キーボードを閉じる
        view.endEditing(true)
        
        if searchBar.text == "" {
            
            let alert = UIAlertController(title: "エラー", message: "値を入力してください。", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            self.present(alert, animated: true, completion: nil)
            
            print("空です")
            
            self.okashiList.removeAll()
            
            self.okashiDataRow.removeAll()
            
            self.okashiSearchTableView.reloadData()
            
        } else  {
            
            if let searchWord = searchBar.text {
                //デバックエリアに出力
                print(searchWord)
                //入力されていたらお菓子を検索
                searchOkashi(keyword: searchWord)
                
            }
            
        }
        
    }
    
    
    //searchOkashiメソッド
    //第一引数：　keyword 検索したいワード
    func searchOkashi(keyword : String) {
        //お菓子のキーワードをURlにエンコードする
        guard let keyWord_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            
            return
            
        }
        //リクエストURLの組み立て
        guard let req_url = URL(string: "https://www.sysbird.jp/webapi/?apikey=guest&format=json&keyword=\(keyWord_encode)&max=10&order=r") else {
            
            return
            
        }
        
        print(req_url)
        
        self.okashiList.removeAll()
        
        self.okashiDataRow.removeAll()
        
        var request = URLRequest(url: req_url)
        
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: req_url) { (data, response, err) in
            
            if let err = err {
                
                print("情報の取得に失敗しました :", err)
                
                return
                
            }
            
            if let data = data {
                
                do {
                    
                    //取得する商品数によって処理を変える必要がある為、APIのJSONから"count”を取得
                    let count = try JSONDecoder().decode(Count.self, from: data)
                    
                    let cellCount = count.count
                    
                    let cellCount2 = Int(cellCount)!
                    
                    //商品数が一つの場合"item"の値がDictionary型になる為、取得する際のモデルを"OneItem"にする
                    if cellCount2 == 1 {
                        
                        let okashi2 = try JSONDecoder().decode(OneItem.self, from: data)
                        
                        let imageData = okashi2.item.image
                        
                        print(imageData)
                        
                        let userName = okashi2.item.name
                        
                        print(userName)
                        
                        let url = okashi2.item.url
                        
                        let id = okashi2.item.id
                        
                        let maker = okashi2.item.maker
                        
                        self.okashiDataRow = ["image": imageData, "name": userName, "url": url, "id": id, "maker": maker]
                        
                        self.okashiList.append(self.okashiDataRow)
                        
                        
                    } else {
                        
                        let okashi = try JSONDecoder().decode(Okashi.self, from: data)
                        
                        for i in 0..<okashi.item.count {
                            
                            let imageData = okashi.item[i].image
                            
                            print(imageData)
                            
                            let userName = okashi.item[i].name
                            
                            print(userName)
                            
                            let url = okashi.item[i].url
                            
                            let id = okashi.item[i].id
                            
                            let maker = okashi.item[i].maker
                            
                            self.okashiDataRow = ["image": imageData, "name": userName, "url": url, "id": id, "maker": maker]
                            
                            self.okashiList.append(self.okashiDataRow)
                            
                        }
                        
                    }
                    
                    DispatchQueue.main.sync {
                        
                        self.okashiSearchTableView.reloadData()
                        
                        return
                        
                    }
                    
                } catch(let err) {
                    
                    print("情報の取得に失敗 :", err)
                    
                }
                
            }
            
        }
        
        task.resume()
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        okashiSearchTableView.dataSource = self
        
        okashiSearchTableView.delegate = self
        
        okashiSearchBar.delegate = self
        
        self.navigationItem.title = "検索画面"
        // リスト初期化
        var item: [Item] = []
        
        getDocument()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
            

            //ゆっくり付けたり消したりする
            if let indexPathForSelectedRow = okashiSearchTableView.indexPathForSelectedRow {
                
                okashiSearchTableView.deselectRow(at: indexPathForSelectedRow, animated: true)
                
            }
        }
    
    func getDocument() {
        
        db.collection("favorite_sweets").getDocuments{ (snapshots, error) in
            
            if error != nil{
                
                print("失敗")
                
                return
                
            }
            
            snapshots?.documents.forEach { snapshot in
                
                let id = snapshot.documentID
                
                self.documentArray.append(id)
                
            }
            
            print(self.documentArray)
            
        }
        
    }
    
}

