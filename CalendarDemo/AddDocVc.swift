//
//  AddDocVc.swift
//  CalendarDemo
//
//  Created by Vishal Rana on 11/11/16.
//  Copyright © 2016 MobileFirst. All rights reserved.
//

import UIKit
protocol DocSelector {
    
    func setAddedDoc(addDocs:NSMutableArray)
}
class AddDocVc: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tblDoc: UITableView!
    var delegate: DocSelector?
    var arrLst = NSMutableArray()
    var  arrDocs = ["Doc1.txt","Doc2.pdf","Doc3.jpeg"]
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add Docs"

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrDocs.count
    }
    
    @IBAction func btnDoneAction(sender: UIButton) {
        
        delegate?.setAddedDoc(arrLst)
        self.navigationController?.popViewControllerAnimated(true)

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let aCell = tableView.dequeueReusableCellWithIdentifier("docCell", forIndexPath: indexPath) as! docCell
        
        aCell.lbl.text = arrDocs[indexPath.row]
        
        if(arrLst.containsObject(arrDocs[indexPath.row])){
           aCell.btnCheckMark.selected = true
        }else{
            aCell.btnCheckMark.selected = false
        }
        aCell.btnCheckMark.addTarget(self, action: #selector(btnCheckmarkAction), forControlEvents: .TouchUpInside)
        
        
        return aCell
    }
    
    func btnCheckmarkAction(sender: UIButton!) {
        let aBtn: UIButton = sender as UIButton
        aBtn.selected = !(aBtn.selected)
        
        let buttonPosition = sender.convertPoint(CGPointZero, toView: self.tblDoc)
        let tappedIP: NSIndexPath = self.tblDoc.indexPathForRowAtPoint(buttonPosition)!
        
        if(arrDocs.count > 0)
        {
            
            
            if(aBtn.selected == true){
                if(!arrLst.containsObject(arrDocs[tappedIP.row] )){
                    arrLst.addObject(arrDocs[tappedIP.row] )
                }
            }else{
                arrLst.removeObject(arrDocs[tappedIP.row])
            }
            
            tblDoc.reloadData()
        }
        
    }
    
    
}
