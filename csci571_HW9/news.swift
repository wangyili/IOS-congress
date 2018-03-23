//
//  news.swift
//  csci571_HW9
//
//  Created by Shiqi Wei on 4/23/16.
//  Copyright © 2016 Shiqi Wei. All rights reserved.
//

import UIKit

class news: UIViewController, UITableViewDataSource,UITableViewDelegate {
 
    var json: AnyObject?
    var symbol : String?
    var titlearray = [String]()
    var contentarray = [String]()
    var publisherarray = [String]()
    var publisheddatearray = [String]()
    var newsurlarray = [String]()


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = self.symbol
        
        //tableView.estimatedRowHeight = 68.0
        //tableView.rowHeight = UITableViewAutomaticDimension
        
//        let requestURL: NSURL = NSURL(string: "https://www.googleapis.com/customsearch/v1?q="+self.symbol!+"&cx=010538348950327075090%3Au8wysyf_kmu&num=10&key=AIzaSyCulF-YZK-Nwqgrssl1zaTTtF6eD_ctlwA")!
//        // googlenewsatricle
        
        
        

        let requestURL: NSURL = NSURL(string: "http://csci571-hw8-weishiqi.appspot.com/?news="+self.symbol!)!
        
        
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        let session = NSURLSession.sharedSession()
        
        let semaphore = dispatch_semaphore_create(0)
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! NSHTTPURLResponse
            
            let statusCode = httpResponse.statusCode
            if (statusCode == 200) {
                do{
                    
                    let json : NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments) as! NSDictionary

                    if let json_response = json["d"] as? NSDictionary{
                        
                        if let json_result = json_response["results"] as? NSArray{
                    
                            if(json_result.count != 0){
                        for index in 0...json_result.count-1 {
                            let search_news : AnyObject? = json_result[index]
                            
                            let collection = search_news! as! Dictionary<String, AnyObject>
                            
                            let title : String? = collection["Title"] as? String
                            let content : String? = collection["Description"]as? String
                            let publisher : String? = collection["Source"]as? String
                            let publisheddate : String? = collection["Date"]as? String
                            let newsurl : String? = collection["Url"]as? String
                            //print("\(title!)-\(content!)-\(publisheddate!)");
                            self.titlearray.append(title!)
                            self.contentarray.append(content!)
                            self.publisherarray.append(publisher!)
                            self.newsurlarray.append(newsurl!)
                            
                            self.publisheddatearray.append(publisheddate!)
                            
                        }
                    }
                    }
                    }
                    
                    
                    dispatch_semaphore_signal(semaphore)
                    
                }catch {
                    dispatch_semaphore_signal(semaphore)
                    print("Error with Json: \(error)")
                }
            }
        }
        
        task.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)

        
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("news_cell", forIndexPath: indexPath) as! NewsTableViewCell
        
        
        let dataformat1 = NSDateFormatter()
        dataformat1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        let origindata = dataformat1.dateFromString(publisheddatearray[indexPath.row].html2String)
        
        let dataformat2 = NSDateFormatter()
         dataformat2.dateFormat = "MMM d yyyy HH:mm"
        let dataString: String = dataformat2.stringFromDate(origindata!)
        
        cell.tabledate.text = dataString
        cell.tabletitle.text = titlearray[indexPath.row].html2String
        cell.tablecontent.text = contentarray[indexPath.row].html2String
        cell.tablepublisher.text = publisherarray[indexPath.row].html2String


        return cell
        
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return titlearray.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //print(newsurlarray[indexPath.row].stringByRemovingPercentEncoding)
        if let checkURL = NSURL(string: newsurlarray[indexPath.row].stringByRemovingPercentEncoding!) {
            if UIApplication.sharedApplication().openURL(checkURL) {
                print("url successfully opened")
            }
        } else {
            print("invalid url")
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        

        if segue.identifier == "ShowHistoricalSegueOne" {
            if let destinationVC = segue.destinationViewController as? historical{
                destinationVC.symbol = self.symbol!
                destinationVC.json = self.json!
                
            }
        }
        if segue.identifier == "ShowCurrentSegueTwo" {
            if let destinationVC = segue.destinationViewController as? current{
                destinationVC.symbol = self.symbol!
                destinationVC.json = self.json!
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
       
        super.viewWillAppear(animated)
        //tableView.reloadData()
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        self.titlearray.removeAll()
        self.contentarray.removeAll()
        self.publisherarray.removeAll()
        self.publisheddatearray.removeAll()

        
        
        let marr: NSMutableArray = NSMutableArray(array: self.navigationController!.viewControllers)
        for vc in marr {
            if vc.isKindOfClass(news) {
                marr.removeObject(vc)
                break
            }
        }
        self.navigationController!.viewControllers = marr.copy() as! [UIViewController]
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension String {
    
    var html2AttributedString: NSAttributedString? {
        guard
            let data = dataUsingEncoding(NSUTF8StringEncoding)
            else { return nil }
        do {
            return try NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:NSUTF8StringEncoding], documentAttributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

