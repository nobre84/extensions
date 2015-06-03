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
    var apiKey = "1e5a246c44451b7c72d6b33517f6a7e"
    var comments = [JSON]()
    
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
        let eventsEndpoint = "https://api.meetup.com/2/events"
        let eventsParams = ["key":self.apiKey, "group_urlname": "MGTi-Zona-da-Mata"]
        Alamofire.request(.GET, eventsEndpoint, parameters: eventsParams).responseJSON(options: nil) { (Request, Response, jsonData, error) -> Void in
            if jsonData != nil {
                let eventsJson = JSON(jsonData!)
                self.setupMainViewData(eventsJson)
                
                println(eventsJson)
                
                if let eventId = eventsJson["results"][0]["id"].string {
                    let commentsEndpoint = "https://api.meetup.com/2/event_comments"
                    let commentsParams = ["key":self.apiKey, "event_id":"221974971"]
                    
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
                            completionHandler(NCUpdateResult.NewData)

                        }
                        else {
                            completionHandler(NCUpdateResult.Failed)
                        }
                    }
                    
                }
                else {
                    self.lbTitle.text = "Nenhum evento marcado"
                    self.lbCount.text = ""
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
            self.lbCount.text = "\(rsvp) irão"
        }
    }
    
    func setupEmptyView() {
        
    }
    
    // TableView Data Source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(self.comments.count, 1)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell") as! UITableViewCell
        if self.comments.count == 0 {
            cell.textLabel!.text = "Nenhum comentário ainda."
            cell.detailTextLabel!.text = ""
        }
        else {
            let jsonComment = self.comments[indexPath.row]
            cell.textLabel!.text = jsonComment["member_name"].string! + ": " + jsonComment["comment"].string!
            let date = NSDate(timeIntervalSince1970:jsonComment["time"].double!)
            cell.detailTextLabel!.text = date.timeAgoSinceNow()
        }
        return cell;
    }
    
    func shortDate(date:NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        return dateFormatter.stringFromDate(date)
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
