//
//  TodayViewController.swift
//  Meetups
//
//  Created by Rafael Nobre on 6/2/15.
//  Copyright (c) 2015 Rafael Nobre. All rights reserved.
//

import UIKit
import NotificationCenter
import Alamofire

class TodayViewController: UIViewController, NCWidgetProviding {
    
    let meetupsSuiteName = "group.br.com.Extensions.Meetup.Shared"
    var apiKey: String?
    let standardApiKey = ""
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        let sharedDefaults = NSUserDefaults(suiteName: meetupsSuiteName)
        if let key = sharedDefaults?.stringForKey("apiKey") {
            apiKey = key
        }
        else {
            apiKey = standardApiKey
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Perform any setup necessary in order to update the view.

//        Alamofire.request(.GET, "http://meetup.com", parameters: ["key":apiKey!])
//                 .responseJSON(options: nil) { (, , , ) -> Void in
//                    
//        }
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }
    
}
