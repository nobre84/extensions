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
    var apiKey = "1e5a246c44451b7c72d6b33517f6a"
    var comments = [AnyObject]()
    
    // UI
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbCount: UILabel!
    @IBOutlet weak var lbTimeLocation: UILabel!
    @IBOutlet weak var tbComments: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Carrego a api key compartilhada, se inserida pelo usuário
        let sharedDefaults = NSUserDefaults(suiteName: meetupsSuiteName)
        if let key = sharedDefaults?.stringForKey("apiKey") {
            apiKey = key
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        widgetPerformUpdateWithCompletionHandler { (NCUpdateResult) -> Void in
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        // Really!!
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Perform any setup necessary in order to update the view.
        let endpoint = "http://api.meetup.com/2/events"
        let params = ["key":apiKey, "group_urlname": "MGTi-Zona-da-Mata"]
        Alamofire.request(.GET, endpoint, parameters: params).responseJSON(options: nil) { (Request, Response, jsonData, error) -> Void in
            if jsonData != nil {
                let json = JSON(jsonData!)
                println(json)
                completionHandler(NCUpdateResult.NewData)
            }
            else {
                completionHandler(NCUpdateResult.Failed)
            }
        }

        // Evitando o pior...
        completionHandler(NCUpdateResult.NoData)

    }
    
    // TableView Data Source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell") as! UITableViewCell
        cell.textLabel!.text = "Felipe Ferraz (3 dias atrás): BlaBlabla"
        return cell;
    }
    
    @IBAction func commentAction(sender: AnyObject) {
    }
    
    @IBAction func seeAllAction(sender: AnyObject) {
    }
    
    @IBAction func configureAction(sender: AnyObject) {
    }
}
