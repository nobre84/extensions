//
//  ViewController.swift
//  Extensions
//
//  Created by Rafael Nobre on 6/2/15.
//  Copyright (c) 2015 Rafael Nobre. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let meetupsSuiteName = "group.br.com.Extensions.Meetup.Shared"

    @IBOutlet weak var tfApiKey: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func saveAction(sender: AnyObject) {
        if let sharedDefaults = NSUserDefaults(suiteName: meetupsSuiteName) {
            sharedDefaults.setValue(self.tfApiKey.text, forKey: "apiKey")
            sharedDefaults.synchronize()
        }
        
    }

}

