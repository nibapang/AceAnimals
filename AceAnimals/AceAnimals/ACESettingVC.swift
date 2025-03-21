
//
//  ACEACESettingVC.swift
//  AceAnimals
//
//  Created by Sun on 2025/3/21.
//

import UIKit
import StoreKit

class ACESettingVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func btnRate(_ sender: Any) {
        
        SKStoreReviewController.requestReview()
        
    }
    
}
