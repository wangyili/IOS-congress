//
//  ViewController.swift
//  csci571_HW9
//
//  Created by Shiqi Wei on 4/19/16.
//  Copyright © 2016 Shiqi Wei. All rights reserved.
//

import UIKit
import CCAutocomplete
import CoreData

class ViewController: UIViewController, UITableViewDataSource,UITableViewDelegate{

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var autofresh_switch: UISwitch!
    @IBOutlet weak var fav_table: UITableView!

    @IBOutlet weak var StocksTextField: UITextField!
    
    var lookupstocks_array = [String]()
    var isFirstLoad: Bool = true
    var json_getquote: AnyObject?
    var symbol: String?
    var favourites = [NSManagedObject]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor(red: 0.125, green: 0.909, blue: 0.623, alpha: 1)
        //activityIndicator.hidden = true
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("favourite_cell", forIndexPath: indexPath) as! FavouritesTableViewCell
        
        let Favourite_stock = favourites[indexPath.row]
        let fav_symbol = Favourite_stock.valueForKey("symbol") as? String
        cell.fav_table_symbol.text = fav_symbol
        
        // get the data of the symbol in favourite table
        let requestURL: NSURL = NSURL(string: "http://csci571-hw8-weishiqi.appspot.com/?symbol=\(fav_symbol!)")!
        
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        let session = NSURLSession.sharedSession()
        
        let semaphore = dispatch_semaphore_create(0)
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            if (statusCode == 200) {
                do{
                    
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    
                    let lastprice_orginal : Float? = json["LastPrice"] as? Float
                    let lastprice = "$ "+String(format: "%.2f", lastprice_orginal!)
                    cell.fav_table_price.text = lastprice
                    
                    let change_orginal : Float? = json["Change"] as? Float
                    
                    let changePercent_orginal : Float? = json["ChangePercent"] as? Float
                    
                    let changePercent_color = Float(String(format: "%.2f", changePercent_orginal!))
                    var change = String(format: "%.2f", change_orginal!)+"(\(String(format: "%.2f", changePercent_orginal!))%)"
                    if(changePercent_color > 0){
                        cell.fav_table_change.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1)
                        change = "+"+change
                    }
                    if(changePercent_color < 0){
                        cell.fav_table_change.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
                    }
                    cell.fav_table_change.text = change
                    
                    let name : String? = json["Name"] as? String
                    cell.fav_table_company.text = name
                    
                    let marketCap_orginal : Float? = json["MarketCap"] as? Float
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

                    cell.fav_table_marketcap.text = "Market Cap: "+marketCap!
                    
                    
                    dispatch_semaphore_signal(semaphore)
                    
                }catch {
                    dispatch_semaphore_signal(semaphore)
                    print("Error with Json: \(error)")
                }
            }
        }
        
        task.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)


        
        return cell
        
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return favourites.count
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let Favourite_stock = favourites[indexPath.row]
        let fav_symbol = Favourite_stock.valueForKey("symbol") as? String
        
        let requestURL: NSURL = NSURL(string: "http://csci571-hw8-weishiqi.appspot.com/?symbol=\(fav_symbol!)")!
        
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        let session = NSURLSession.sharedSession()
        
        let semaphore = dispatch_semaphore_create(0)
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            if (statusCode == 200) {
                do{
                    
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    self.json_getquote = json
                    self.symbol = fav_symbol
                    
                    
                    
                    dispatch_semaphore_signal(semaphore)
                    
                }catch {
                    dispatch_semaphore_signal(semaphore)
                    print("Error with Json: \(error)")
                }
            }
        }
        
        task.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        self.performSegueWithIdentifier("ShowCurrentSegue", sender: self)
        
    }
    // remove data to coredata
    func removestock(index: Int) {
        //1
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        //3
       
        managedContext.deleteObject(favourites[index])
        favourites.removeAtIndex(index)
        //4
        do {
            try managedContext.save()
            //5
        } catch let error as NSError  {
            print("Could not remove \(error), \(error.userInfo)")
        }
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            removestock(indexPath.row)
            fav_table.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.isFirstLoad {
            self.isFirstLoad = false
            Autocomplete.setupAutocompleteForViewcontroller(self)
        }
    }
    var SwitchTimer : NSTimer?
    func autofresh()
    {
        
        self.activityIndicator.hidden = false
        self.activityIndicator.center = self.view.center
        self.activityIndicator.startAnimating()
        print("start animating")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),{ () -> Void in
            
            self.fav_table.reloadData()
            print("refresh")
            sleep(1)

            dispatch_after(DISPATCH_TIME_NOW, dispatch_get_main_queue(), { ()->() in
                
                self.activityIndicator.stopAnimating()

                print("stop animating")
                
                self.activityIndicator.hidden = true
            })
        });

    }

    @IBAction func switch_autofresh(sender: AnyObject) {
        if autofresh_switch.on {
           

            
            SwitchTimer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(ViewController.autofresh), userInfo: nil, repeats: true)
            print("start")
            
            
        } else {
            if(SwitchTimer != nil){
                SwitchTimer!.invalidate()
                SwitchTimer = nil
                print("killed")
                dispatch_after(DISPATCH_TIME_NOW, dispatch_get_main_queue(), { ()->() in
                    
                    self.activityIndicator.stopAnimating()
                    //sleep(1)
                    print("stop animating")
                    
                    self.activityIndicator.hidden = true
                })
            }
            
        }
    }
    
    func refreshdata() //refresh-animating stop
    {
        dispatch_after(DISPATCH_TIME_NOW, dispatch_get_main_queue(), { ()->() in
            
            self.activityIndicator.stopAnimating()
            sleep(1)
            print("stop animating")
            
            self.activityIndicator.hidden = true
             })
    }
    @IBAction func OnclickRefresh(sender: AnyObject) {
        self.activityIndicator.hidden = false
        self.activityIndicator.center = self.view.center

        activityIndicator.startAnimating()
        print("start animating")

        fav_table.reloadData()
        print("refresh")
        refreshdata()
        
        
        
    }
    @IBAction func OnclickGetquote(sender: AnyObject) {
        
        if(self.StocksTextField.text == ""){
            if self.presentedViewController == nil{
            let alertController = UIAlertController(title: "Please Enter a Stock Name or Symbol.", message:
                nil, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        if(lookupstocks_array.contains(self.StocksTextField.text!)){
            let StocksTextFieldArr = self.StocksTextField.text!.componentsSeparatedByString("-")
            symbol = StocksTextFieldArr[0];
            print("http://csci571-hw8-weishiqi.appspot.com/?symbol=\(StocksTextFieldArr[0])")
            let requestURL: NSURL = NSURL(string: "http://csci571-hw8-weishiqi.appspot.com/?symbol=\(StocksTextFieldArr[0])")!

            let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
            let session = NSURLSession.sharedSession()
            
            let semaphore = dispatch_semaphore_create(0)
            let task = session.dataTaskWithRequest(urlRequest) {
                (data, response, error) -> Void in
                
                let httpResponse = response as! NSHTTPURLResponse
                let statusCode = httpResponse.statusCode
                if (statusCode == 200) {
                    do{
                        
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                        self.json_getquote = json
                                


                        dispatch_semaphore_signal(semaphore)
                        
                    }catch {
                        dispatch_semaphore_signal(semaphore)
                        print("Error with Json: \(error)")
                    }
                }
            }
            
            task.resume()
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            
            if(self.json_getquote!["Status"] as! String != "SUCCESS")
            {
                let alertController_3 = UIAlertController(title: "No detail for the stock", message:
                    nil, preferredStyle: UIAlertControllerStyle.Alert)
                alertController_3.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController_3, animated: true, completion: nil)
            
            }
            else{
            
                self.performSegueWithIdentifier("ShowCurrentSegue", sender: self)
            }
            
        }
        else
        {
            if self.presentedViewController == nil{

            let alertController_2 = UIAlertController(title: "Invalid Symbol", message:
                nil, preferredStyle: UIAlertControllerStyle.Alert)
            alertController_2.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
            
                self.presentViewController(alertController_2, animated: true, completion: nil)
            }
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowCurrentSegue" {
            if let destinationVC = segue.destinationViewController as? current{
                destinationVC.json = self.json_getquote!
                destinationVC.symbol = self.symbol!
            }
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = true
        super.viewWillAppear(animated)
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
        
        fav_table.reloadData()
        
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        if (navigationController?.topViewController != self) {
            navigationController?.navigationBarHidden = false
        }
        super.viewWillDisappear(animated)
    }

}

extension ViewController: AutocompleteDelegate {
    
    func autoCompleteTextField() -> UITextField {
        return self.StocksTextField
    }
    
    func autoCompleteThreshold(textField: UITextField) -> Int {
        return 0
    }
    
    func autoCompleteItemsForSearchTerm(term: String) -> [AutocompletableOption] {
        var textwithoutspace = StocksTextField.text!.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet())
        var tempArray = textwithoutspace.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        tempArray = tempArray.filter{
            $0 != ""
        }
        textwithoutspace = tempArray.joinWithSeparator("")
        print(textwithoutspace)
        let requestURL: NSURL = NSURL(string: "http://csci571-hw8-weishiqi.appspot.com/?input=\(textwithoutspace)")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        let session = NSURLSession.sharedSession()
        self.lookupstocks_array.removeAll()
        let semaphore = dispatch_semaphore_create(0)
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            if (statusCode == 200) {
                do{
                    
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    if(json.count != 0){
                        for index in 0...json.count-1 {
                            let lookup_stocks : AnyObject? = json[index]
                            
                            let collection = lookup_stocks! as! Dictionary<String, AnyObject>
                            
                            let symbol : AnyObject? = collection["Symbol"]
                            let name : AnyObject? = collection["Name"]
                            let exchange : AnyObject? = collection["Exchange"]
                            
                            //print("\(symbol!)-\(name!)-\(exchange!)");
                            self.lookupstocks_array.append("\(symbol!)-\(name!)-\(exchange!)")
                            
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
        //print(lookupstocks_array)
        
        let lookupstocks: [AutocompletableOption] = self.lookupstocks_array.map {
            (var stock) -> AutocompleteCellData in
            stock.replaceRange(stock.startIndex...stock.startIndex, with: String(stock.characters[stock.startIndex]).capitalizedString)
            return AutocompleteCellData(text: stock,image: nil)
            }.map( { $0 as AutocompletableOption })
        
        return lookupstocks

    }
    
    func autoCompleteHeight() -> CGFloat {
        return CGRectGetHeight(self.view.frame) / 3.0
    }
    
    
    func didSelectItem(item: AutocompletableOption) {
        self.StocksTextField.text = item.text
    }
}

