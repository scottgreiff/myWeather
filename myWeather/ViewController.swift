//
//  ViewController.swift
//  myWeather
//
//  Created by Scott Alan Greiff on 4/3/16.
//  Copyright © 2016 Scott Alan Greiff. All rights reserved.
//

import UIKit
import JSQCoreDataKit
import Alamofire

class ViewController: UIViewController {

    var stack: CoreDataStack!

    override func viewDidLoad() {
        super.viewDidLoad()

        let model = CoreDataModel(name: modelName, bundle: modelBundle)
        let factory = CoreDataStackFactory(model: model)
        
        factory.createStackInBackground { (result: StackResult) in
            switch result {
            case .success(let s):
                self.stack = s
            case .failure(let e):
                print("Error: \(e)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

