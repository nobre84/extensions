//
//  ViewController.swift
//  Extensions
//
//  Created by Rafael Nobre on 6/2/15.
//  Copyright (c) 2015 Rafael Nobre. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let meetupsSuiteName = "group.br.com.Extension.Meetups.Shared"

    @IBOutlet weak var tfApiKey: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Carrego a api key compartilhada, se inserida pelo usuário
        let sharedDefaults = NSUserDefaults(suiteName: meetupsSuiteName)
        if let key = sharedDefaults?.stringForKey("apiKey") {
            self.tfApiKey!.text = key
        }
        else {
            // Salvo a apiKey padrão
            self.tfApiKey!.text = "1e5a246c44451b7c72d6b33517f6a7e"
            self.saveAction(self.tfApiKey)
        }
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

