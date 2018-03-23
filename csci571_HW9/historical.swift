//
//  historical.swift
//  csci571_HW9
//
//  Created by Shiqi Wei on 4/23/16.
//  Copyright © 2016 Shiqi Wei. All rights reserved.
//

import UIKit

class historical: UIViewController {

    @IBOutlet var Webview: UIWebView!
 
    var json: AnyObject?
    var symbol : String?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = self.symbol
       
        let url = NSURL (string: "http://www.seefabao.com/highchart.html?symbol=\(symbol!)");
        let requestObj = NSURLRequest(URL: url!);
        Webview.loadRequest(requestObj);
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Onclickcurrent(sender: AnyObject) {
        
        //self.performSegueWithIdentifier("ShowCurrentSegueOne", sender: self)
        //没用的函数

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowNewsSegueOne" {
            if let destinationVC = segue.destinationViewController as? news{
                destinationVC.symbol = self.symbol!
                destinationVC.json = self.json!
                
            }
        }
        if segue.identifier == "ShowCurrentSegueOne" {
            if let destinationVC = segue.destinationViewController as? current{
                destinationVC.symbol = self.symbol!
                destinationVC.json = self.json!
                //print("testw4324234324324 json"+(self.json! as! String))
            }
        }
    }

    
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        
        let marr: NSMutableArray = NSMutableArray(array: self.navigationController!.viewControllers)
        for vc in marr {
            if vc.isKindOfClass(historical) {
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
