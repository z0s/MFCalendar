//
//  AddPeopleVC.swift
//  Simplify
//
//  Created by Vishal Rana on 6/13/16.
//  Copyright © 2016 2359 Media Pte Ltd. All rights reserved.
//

import UIKit
import Parse
import SVProgressHUD
import AlamofireImage

protocol PeopleSelector {
    
    func setSelectedPeople(selectedPeople:NSMutableArray,selectedIndexs:NSMutableArray)
}


class AddPeopleVC: UIViewController,UITableViewDelegate,UITableViewDataSource{

    var delegate: PeopleSelector?

    @IBOutlet weak var lblHeader: UILabel!
    
    @IBOutlet weak var tblPeople: UITableView!
    var familyMembers = [String]()
    var selectedMembers = NSMutableArray()
    
    var selectedPeopleIndexes = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add People"
        // Do any additional setup after loading the view.
        
        tblPeople.tableFooterView = UIView(frame: CGRectZero)
        familyMembers = ["Member 1","Member 2","Member 3","Member 4"]
        self.updateHeader()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
      // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return familyMembers.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let aCell = tableView.dequeueReusableCellWithIdentifier("PeopleSelectionCell", forIndexPath: indexPath) as! PeopleSelectionCell
        
        aCell.imgPeople.layer.cornerRadius = aCell.imgPeople.frame.size.width/2
        
         aCell.btnCheckMark.addTarget(self, action: #selector(btnCheckmarkAction), forControlEvents: .TouchUpInside)

        
        
       
           
            aCell.lblName.text = familyMembers[indexPath.row]
            
            if(selectedMembers.containsObject(familyMembers[indexPath.row] )){
                aCell.btnCheckMark.selected = true
            }else{
                aCell.btnCheckMark.selected = false
            }
        
        return aCell
    }
    
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        let header: UIView = (NSBundle.mainBundle().loadNibNamed("tblHeader", owner: nil, options: nil)[0] as? UIView)!
        return header
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 5
    }
    

    func btnCheckmarkAction(sender: UIButton!) {
        let aBtn: UIButton = sender as UIButton
        aBtn.selected = !(aBtn.selected)
        
        let buttonPosition = sender.convertPoint(CGPointZero, toView: self.tblPeople)
        let tappedIP: NSIndexPath = self.tblPeople.indexPathForRowAtPoint(buttonPosition)!
        
       
            
            if(aBtn.selected == true){
                if(!selectedMembers.containsObject(familyMembers[tappedIP.row] ))
                {
                    selectedMembers.addObject(familyMembers[tappedIP.row] )
                    
                    if(selectedPeopleIndexes.count < 6)
                    {
                        if(!selectedPeopleIndexes.containsObject(tappedIP.row))
                        {
                            selectedPeopleIndexes.addObject(tappedIP.row)
                        }
                    }
                }
            }else{
                selectedMembers.removeObject(familyMembers[tappedIP.row])
                selectedPeopleIndexes.removeObject(tappedIP.row)

            }
        
        
        self.updateHeader()
        
        tblPeople.reloadData()
        
    }
    
    func updateHeader()
    {
        if(selectedMembers.count == 0){
            lblHeader.text = "Only You"
        }else if(selectedMembers.count == familyMembers.count){
            lblHeader.text = "You + all group members"
        }else{
            lblHeader.text = String(format: "You + %ld group member(s)", selectedMembers.count)
        }
    }

    @IBAction func btnPeopleDoneAction(sender: UIButton) {
        
        delegate?.setSelectedPeople(selectedMembers,selectedIndexs:selectedPeopleIndexes)
        
        self.navigationController?.popViewControllerAnimated(true)
    }

}




