//
//  ViewController.swift
//  SweetsSearchApp
//
//  Created by K Barnes on 2023/01/05.
//

import UIKit


class ViewController: UIViewController {
    
    @IBOutlet weak var homeImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        homeImage.image = UIImage(named: "OkashinoToriko")
        
    }
    
    
    @IBAction func searchButton(_ sender: Any) {
        
        let searchViewController = self.storyboard?.instantiateViewController(withIdentifier: "goSearch") as! SearchViewController
        
        self.navigationController?.pushViewController(searchViewController, animated: true)
        
    }
    
    
    @IBAction func favoriteButton(_ sender: Any) {
        
        let favoriteViewController = self.storyboard?.instantiateViewController(withIdentifier: "goFavorite") as! FavoriteViewController
        
        self.navigationController?.pushViewController(favoriteViewController, animated: true)
        
    }
    
}

