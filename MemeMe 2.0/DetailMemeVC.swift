//
//  DetailMemeVC.swift
//  MemeMe 2.0
//
//  Created by Daniel Schallmeiner on 04.04.20.
//  Copyright © 2020 otaxi GmbH. All rights reserved.
//

import Foundation
import UIKit

class DetailMemeVC: UIViewController {
    
    var meme: Meme!
    
    @IBOutlet weak var imgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgView.image = meme.memedImage
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    
    @IBAction func editBtn(_ sender: Any) {
        let viewController = storyboard!.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        viewController.memeSentFromDetail = self.meme
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    
}
