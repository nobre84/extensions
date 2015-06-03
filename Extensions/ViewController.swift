//
//  ViewController.swift
//  Extensions
//
//  Created by Rafael Nobre on 6/2/15.
//  Copyright (c) 2015 Rafael Nobre. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var status = "upcoming"
    var sharedDefaults = NSUserDefaults(suiteName: "group.br.com.Extension.Meetups.Shared")

    @IBOutlet weak var tfApiKey: UITextField!
    @IBOutlet weak var segStatus: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        sharedDefaults?.synchronize()
        // Carrego a api key compartilhada, se inserida pelo usuário
        if let key = sharedDefaults?.stringForKey("apiKey") {
            self.tfApiKey!.text = key
        }
        else {
            // Salvo a apiKey padrão
            self.tfApiKey!.text = "1e5a246c44451b7c72d6b33517f6a7e"
            self.saveAction(self.tfApiKey)
        }
        if let status = sharedDefaults?.stringForKey("apiStatus") {
            self.segStatus!.selectedSegmentIndex = status == "upcoming" ? 0 : 1
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func saveAction(sender: AnyObject) {
        
        sharedDefaults?.setValue(self.tfApiKey.text, forKey: "apiKey")
        sharedDefaults?.setValue(self.status, forKey: "apiStatus")
        sharedDefaults?.synchronize()
        
    }

    @IBAction func segValueChanged(sender: UISegmentedControl) {
        self.status = sender.selectedSegmentIndex == 0 ? "upcoming" : "past"
    }
}

