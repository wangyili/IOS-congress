//
//  page1.swift
//  csci571_HW9
//
//  Created by Shiqi Wei on 4/19/16.
//  Copyright © 2016 Shiqi Wei. All rights reserved.
//

import UIKit
import CoreData
import FBSDKCoreKit
import FBSDKShareKit
//import FBSDKLoginKit


class current: UIViewController, UITableViewDataSource, FBSDKSharingDelegate{
    
    @IBOutlet weak var starbutton: UIButton!
    var json: AnyObject?
    var symbol : String?
    var changePercent_arrow : Float?
    var changeYTDPercent_arrow : Float?
    var tabledata = [String]()
    let tableheader:[String] = ["Name", "Symbol", "Last Price", "Change", "Time and Date", "Market Cap", "Volume", "Change YTD","High Price", "Low Price", "Opening Price"]
    var isFavourite: Bool?
    var favourites = [NSManagedObject]()
    var facebookflagVCdiappear : Bool?
    
    //@IBOutlet var scrollview: UIScrollView!
    @IBOutlet weak var stock_chart: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isFavourite = false
        facebookflagVCdiappear = false
        //fetch data from coredata
        //1
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let fetchRequest = NSFetchRequest(entityName: "Favourite_stock")
        
        //3
        do {
            let results =
                try managedContext.executeFetchRequest(fetchRequest)
            favourites = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        for (_, element) in favourites.enumerate() {
            //print("Item \(index): \(element)")
            
            if symbol == element.valueForKey("symbol") as? String{
                isFavourite = true
                break
            }
        }
        
        if(isFavourite == true){
            let image = UIImage(named: "Star Filled-50") as UIImage!
            starbutton.setImage(image, forState: .Normal)
        
        }
        
        
        let url = NSURL(string: "http://chart.finance.yahoo.com/t?s="+self.symbol!+"&lang=en-US&width=500&height=400")
        let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
        stock_chart.image = UIImage(data: data!)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("current_cell", forIndexPath: indexPath) as! CurrentTableViewCell
        cell.current_header.text = tableheader[indexPath.row]
        if indexPath.row == 3{
            if(changePercent_arrow > 0)
            {
                let image : UIImage = UIImage(named: "Up-52")!
                cell.current_data.attributedText = attachArrow(tabledata[indexPath.row], image: image)
            }
            else if(changePercent_arrow < 0)
            {
                let image : UIImage = UIImage(named: "Down-52")!
                cell.current_data.attributedText = attachArrow(tabledata[indexPath.row], image: image)
            }
            else{
                cell.current_data.text = tabledata[indexPath.row]
            }
            
        }
        else if indexPath.row == 7{
            if(changeYTDPercent_arrow > 0)
            {
                let image : UIImage = UIImage(named: "Up-52")!
                cell.current_data.attributedText = attachArrow(tabledata[indexPath.row], image: image)
            }
            else if(changeYTDPercent_arrow < 0)
            {
                let image : UIImage = UIImage(named: "Down-52")!
                cell.current_data.attributedText = attachArrow(tabledata[indexPath.row], image: image)
            }
            else{
                cell.current_data.text = tabledata[indexPath.row]
            }

            
        }
        else {
            
            cell.current_data.text = tabledata[indexPath.row]
        }
                return cell
        
    }
    
    // add data to coredata
    func savestock(symbol: String) {
        //1
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let entity =  NSEntityDescription.entityForName("Favourite_stock",
                                                        inManagedObjectContext:managedContext)
        
        let Favourite_stock = NSManagedObject(entity: entity!,
                                     insertIntoManagedObjectContext: managedContext)
        
        //3
        Favourite_stock.setValue(symbol, forKey: "symbol")
        
        //4
        do {
            try managedContext.save()
            //5
            favourites.append(Favourite_stock)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    // remove data to coredata
    func removestock(symbol: String) {
        //1
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        //3
        for (index, element) in favourites.enumerate() {
            if symbol == element.valueForKey("symbol") as? String{
                managedContext.deleteObject(favourites[index])
                favourites.removeAtIndex(index)
                break
            }
        }
    
        //4
        do {
            try managedContext.save()
            //5
        } catch let error as NSError  {
            print("Could not remove \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func addordelete_favourite(sender: AnyObject) {
        if isFavourite == true{
            removestock(self.symbol!)
            let image = UIImage(named: "Star-50") as UIImage!
            starbutton.setImage(image, forState: .Normal)
            isFavourite = false
        }
        else
        {
           savestock(self.symbol!)
            let image = UIImage(named: "Star Filled-50") as UIImage!
            starbutton.setImage(image, forState: .Normal)
            isFavourite = true
        }
        
    }
    
    
    
  
    @IBAction func facebookshare(sender: AnyObject) {
       
        let content : FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentURL = NSURL(string: "http://finance.yahoo.com/q?s=\(self.symbol!)")
        content.contentTitle = "Current Stock Price of \(tabledata[0]) is \(tabledata[2])"
        content.contentDescription = "Stock information of \(tabledata[0]) (\(tabledata[1]))"
        content.imageURL = NSURL(string: "http://chart.finance.yahoo.com/t?s="+self.symbol!+"&lang=en-US&width=220&height=240")
        
        //FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: self)
        
        
        let shareDialog : FBSDKShareDialog = FBSDKShareDialog()
        shareDialog.mode = FBSDKShareDialogMode.Native
        //shareDialog.mode = FBSDKShareDialogMode.FeedBrowser
        shareDialog.shareContent = content
        shareDialog.delegate = self
        shareDialog.fromViewController=self
        
        
        if !shareDialog.canShow() {
            // fallback presentation when there is no FB app
            shareDialog.mode = FBSDKShareDialogMode.FeedBrowser
        }
        
        facebookflagVCdiappear = true
        shareDialog.show()
        

    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return tabledata.count
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowNewsSegue" {
            if let destinationVC = segue.destinationViewController as? news{
                destinationVC.symbol = self.symbol!
                destinationVC.json = self.json!
            }
        }
        if segue.identifier == "ShowHistoricalSegue" {
            if let destinationVC = segue.destinationViewController as? historical{
                destinationVC.symbol = self.symbol!
                destinationVC.json = self.json!
            }
        }
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        let symbol_temp : String? = self.json!["Symbol"] as? String
        self.symbol = symbol_temp
        
        self.title = self.symbol
        
        let name : AnyObject? = self.json!["Name"]
        tabledata.append(name as! String)
        tabledata.append(self.symbol!)
        
        let lastprice_orginal : Float? = self.json!["LastPrice"] as? Float
        let lastprice = "$ "+String(format: "%.2f", lastprice_orginal!)
        tabledata.append(lastprice)
        
        let change_orginal : Float? = self.json!["Change"] as? Float
        
        let changePercent_orginal : Float? = self.json!["ChangePercent"] as? Float
        
        changePercent_arrow = Float(String(format: "%.2f", changePercent_orginal!))
        let change = String(format: "%.2f", change_orginal!)+"(\(String(format: "%.2f", changePercent_orginal!))%)"
        tabledata.append(change)
        
        let timestamp : AnyObject? = self.json!["Timestamp"]
        
        let dataformat1 = NSDateFormatter()
        dataformat1.dateFormat = "EEE MMM d HH:mm:ss zzz yyy"
        let origindata = dataformat1.dateFromString(timestamp as! String)
        
        let dataformat2 = NSDateFormatter()
        dataformat2.dateFormat = "MMM d yyyy HH:mm"
        let dataString: String = dataformat2.stringFromDate(origindata!)
        
        
        tabledata.append(dataString)
        
        let marketCap_orginal : Float? = self.json!["MarketCap"] as? Float
        var marketCap : String? = ""
        if(Float(String(format: "%.2f",(marketCap_orginal! / 1000000000))) == 0)
        {
            if(Float(String(format: "%.2f",(marketCap_orginal! / 1000000))) == 0){
                let temp = round(marketCap_orginal! / 1000) * 1000
                marketCap = temp.description
            }
                
            else{
                marketCap=String(format: "%.2f",(marketCap_orginal! / 1000000))+"   Million";
            }
        }
        else{
            marketCap=String(format: "%.2f",(marketCap_orginal! / 1000000000))+" Billion";
        }
        
        tabledata.append(marketCap!)
        
        let volume : AnyObject? = self.json!["Volume"]
        tabledata.append(volume!.stringValue as String)
        
        let changeYTD_orginal : Float? = self.json!["ChangeYTD"] as? Float
        
        let changePercentYTD_orginal : Float? = self.json!["ChangePercentYTD"] as? Float
        
        changeYTDPercent_arrow = Float(String(format: "%.2f", changePercentYTD_orginal!))
        
        let changeYTD = String(format: "%.2f", changeYTD_orginal!)+"(\(String(format: "%.2f", changePercentYTD_orginal!))%)"
        tabledata.append(changeYTD);
        
        
        let high : Float? = self.json!["High"] as? Float
        tabledata.append("$ " + String(high!))
        
        let low : Float? = self.json!["Low"] as? Float
        tabledata.append("$ " + String(low!))
        
        let open : Float? = self.json!["Open"] as? Float
        tabledata.append("$ " + String(open!))
        
        //print(json!)
    }
    
    func attachArrow(result:String, image:UIImage) -> NSMutableAttributedString{

        //Get image and set it's size
        let newSize = CGSize(width: 20, height: 20)
        
        //Resize image
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let imageResized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        //Create attachment text with image
        let attachment = NSTextAttachment()
        attachment.image = imageResized
        let attachmentString = NSAttributedString(attachment: attachment)
        let resultwitharrow = NSMutableAttributedString(string: result)
        resultwitharrow.appendAttributedString(attachmentString)

        return resultwitharrow
    }
    
    
    
    override func viewWillDisappear(animated: Bool) {

        super.viewWillDisappear(animated)
        
        tabledata.removeAll()
        
        let marr: NSMutableArray = NSMutableArray(array: self.navigationController!.viewControllers)
        for vc in marr {
            if vc.isKindOfClass(current) {
                if(facebookflagVCdiappear == false){
                    marr.removeObject(vc)
                }
                break
            }
        }
        self.navigationController!.viewControllers = marr.copy() as! [UIViewController]
        
    }
    
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        print(results)
        let didShareAlert = UIAlertController(title: "Success", message: "", preferredStyle:UIAlertControllerStyle.Alert)
        didShareAlert.addAction(UIAlertAction(title:"OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(didShareAlert,animated:true,completion:nil)
    }
    
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        let failedToShareAlert = UIAlertController(title: "Post Failed", message: "", preferredStyle:UIAlertControllerStyle.Alert)
        failedToShareAlert.addAction(UIAlertAction(title:"OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(failedToShareAlert,animated:true,completion:nil)
    }
    
    func sharerDidCancel(sharer: FBSDKSharing!) {
        let cancelShareAlert = UIAlertController(title: "Post Canceled", message: "", preferredStyle:UIAlertControllerStyle.Alert)
        cancelShareAlert.addAction(UIAlertAction(title:"OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(cancelShareAlert,animated:true,completion:nil)
    }
    
//    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool
//    {
//        return FBSDKApplicationDelegate.sharedInstance().application(
//            app,
//            openURL: url,
//            sourceApplication: options["UIApplicationOpenURLOptionsSourceApplicationKey"] as! String,
//            annotation: nil)
//    }


}
