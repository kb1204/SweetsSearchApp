//
//  WebViewController.swift
//  SweetsSearchApp
//
//  Created by K Barnes on 2023/01/13.
//

import UIKit
import WebKit
import FirebaseFirestore


class WebViewController: UIViewController {
    
    @IBOutlet weak var myWebView: WKWebView!
    
    @IBOutlet weak var myTextView: UITextView!
    
    var getURL: String = ""
    
    var getName: String = ""
    
    var getImage: String = ""
    
    var getId: String = ""
    
    var getMaker: String = ""
    
    var getDocumentId: String = ""
    
    var getMemo: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "お菓子検索・メモアプリ"
        
        // UIBarbuttonItemのactionを設定
        let button = UIBarButtonItem(title: "保存", style: .done, target: self, action: #selector(self.buttonTapped(_:)))
        
        self.navigationItem.rightBarButtonItem = button
        
        guard let url = URL(string: getURL) else {
            
            return
            
        }
        
        self.myWebView.load(URLRequest(url: url))
        
    }
    
    //    viewDidLoadだと反映されない為、viewWillAppearに記述
    override func viewWillAppear(_ animated: Bool) {
        
        myTextView.text = getMemo
        
    }
    
    
    @objc func buttonTapped(_ sender: UIBarButtonItem) {
        //        guard letでnilチェック(アンラップ)
        guard let memo = myTextView.text else {
            
            return
            
            
        }
        
        let pageViewCountData = ["id": getId, "name": getName, "maker": getMaker, "url": getURL, "image": getImage, "memo": memo]
        //        インスタンス化
        let db = Firestore.firestore()
        //データを上書きして保存し直す
        db.collection("favorite_sweets").document(getDocumentId).setData(pageViewCountData) { err in
            
            if let err = err {
                
                print("Error writing document: \(err)")
                
            } else {
                
                let dialog = UIAlertController(title: "保存しました", message: "", preferredStyle: .alert)
                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(dialog, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
}
