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
import SwiftyJSON

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDataSource {
    
    let meetupsSuiteName = "group.br.com.Extensions.Meetup.Shared"
    var apiKey = ""
    let standardApiKey = ""
    var comments = [AnyObject]()
    
    // UI
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbCount: UILabel!
    @IBOutlet weak var lbTimeLocation: UILabel!
    @IBOutlet weak var tbComments: UITableView!
    
    
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

        Alamofire.request(.GET, "http://meetup.com", parameters: ["key":apiKey]).responseJSON(options: nil) { (Request, Response, jsonData, error) -> Void in
            let json = JSON(jsonData)
            println(json)
            completionHandler(NCUpdateResult.NewData)
        }
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

    }
    
    // TableView Data Source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return nil
    }
    
    @IBAction func commentAction(sender: AnyObject) {
    }
    
    @IBAction func seeAllAction(sender: AnyObject) {
    }
    
    @IBAction func configureAction(sender: AnyObject) {
    }
}
