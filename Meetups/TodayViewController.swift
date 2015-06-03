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
    
    var apiKey = "1e5a246c44451b7c72d6b33517f6a7e"
    var apiStatus = "upcoming"
    var comments = [JSON]()
    var sharedDefaults = NSUserDefaults(suiteName: "group.br.com.Extensions.Meetups.Shared")
    
    // UI
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbCount: UILabel!
    @IBOutlet weak var lbTimeLocation: UILabel!
    @IBOutlet weak var tbComments: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Auto resize cells
        self.tbComments.estimatedRowHeight = 44
        self.tbComments.rowHeight = UITableViewAutomaticDimension
        
        self.resizeWidget()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Carrego a api key compartilhada, se inserida pelo usuário
        sharedDefaults?.synchronize()
        if let key = sharedDefaults?.stringForKey("apiKey") {
            apiKey = key
        }
        if let status = sharedDefaults?.stringForKey("apiStatus") {
            apiStatus = status
        }
        
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
        let eventsEndpoint = "https://api.meetup.com/2/events"
        let order = self.apiStatus == "upcoming" ? "false" : "true"
        // status: upcoming ou past
        let eventsParams = ["key":self.apiKey, "member_id": "self", "status": self.apiStatus, "order": order]
        Alamofire.request(.GET, eventsEndpoint, parameters: eventsParams).responseJSON(options: nil) { (Request, Response, jsonData, error) -> Void in
            if jsonData != nil {
                let eventsJson = JSON(jsonData!)
                self.setupMainViewData(eventsJson)
                
                println(eventsJson)
                
                if let eventId = eventsJson["results"][0]["id"].string {
                    let commentsEndpoint = "https://api.meetup.com/2/event_comments"
                    let commentsParams = ["key": self.apiKey, "event_id": eventId]
                    
                    Alamofire.request(.GET, commentsEndpoint, parameters: commentsParams).responseJSON(options: nil) { (Request, Response, jsonData, error) -> Void in
                        if jsonData != nil {
                            let commentsJson = JSON(jsonData!)
                            println(commentsJson)
                            
                            if let comments = commentsJson["results"].array {
                                self.comments = comments
                            }
                            else {
                                self.comments = []
                            }
                            self.tbComments.reloadData()
                            self.resizeWidget()
                            completionHandler(NCUpdateResult.NewData)

                        }
                        else {
                            completionHandler(NCUpdateResult.Failed)
                        }
                    }
                    
                }
                else {
                    self.setupEmptyView()
                    self.resizeWidget()
                    completionHandler(NCUpdateResult.NewData)
                }
                
                

            }
            else {
                completionHandler(NCUpdateResult.Failed)
            }
        }

        // Evitando o pior...
        completionHandler(NCUpdateResult.NoData)

    }
    
    func setupMainViewData(eventJson: JSON) {
        if let name = eventJson["results"][0]["name"].string {
            self.lbTitle.text = name
        }
        var subtitle = ""
        if let time = eventJson["results"][0]["time"].double {
            subtitle = shortDate(NSDate(timeIntervalSince1970: time/1000))
        }
        if let location = eventJson["results"][0]["venue"]["name"].string {
            subtitle += " @ " + location
        }
        self.lbTimeLocation.text = subtitle
        if let rsvp = eventJson["results"][0]["yes_rsvp_count"].int {
            if self.apiStatus == "upcoming" {
                self.lbCount.text = "\(rsvp) irão"
            }
            else {
                self.lbCount.text = "\(rsvp) foram"
            }
        }
    }
    
    func setupEmptyView() {
        self.lbTitle.text = "Nenhum evento marcado"
        self.lbCount.text = ""
    }
    
    // TableView Data Source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(self.comments.count, 1)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell") as! UITableViewCell
        if self.comments.count == 0 {
            cell.textLabel!.text = "Nenhum comentário ainda."
        }
        else {
            let jsonComment = self.comments[indexPath.row]
            if let name = jsonComment["member_name"].string, let comment = jsonComment["comment"].string, let time = jsonComment["time"].double {
                let date = NSDate(timeIntervalSince1970:time/1000)
                let timeAgo = date.timeAgoSinceNow()
                
                if let label = cell.textLabel {
                    label.text = name + ": " + comment + " - " + timeAgo
                }
            }
        }
        return cell;
    }
    
    func shortDate(date:NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        return dateFormatter.stringFromDate(date)
    }
    
    func resizeWidget() {
        self.tbComments.sizeToFit()
        var size = self.tbComments.contentSize
        size.height += self.lbTimeLocation.frame.maxY + 20
        self.preferredContentSize = size
    }
    
    @IBAction func commentAction(sender: AnyObject) {
    }
    
    @IBAction func seeAllAction(sender: AnyObject) {
    }
    
    @IBAction func configureAction(sender: AnyObject) {
        if let url = NSURL(string: "rnextensions://") {
            self.extensionContext?.openURL(url, completionHandler: nil)
        }
    }
    
}
