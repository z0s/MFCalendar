//
//  AddTaskVC.swift
//  Simplify
//
//  Created by Vishal Rana on 6/13/16.
//  Copyright © 2016 2359 Media Pte Ltd. All rights reserved.
//

import UIKit

protocol TaskSelector {
    
    func setAddedTask(addTasks:NSMutableArray)
}

class AddTaskVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {

    var delegate: TaskSelector?

    @IBOutlet weak var txtTask: UITextField!
    @IBOutlet weak var tblTask: UITableView!
    var arrTask:NSMutableArray!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Add Task"
        // Do any additional setup after loading the view.
        txtTask.delegate = self
        tblTask.estimatedRowHeight = 60.0
        tblTask.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(animated: Bool) {
        delegate?.setAddedTask(arrTask)

    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        self.view.endEditing(true)
    }

    @IBAction func btnAddTaskAction(sender: UIButton) {
        
        if(!(txtTask.text?.isEmpty)!)
        {
            if(!arrTask.containsObject(txtTask.text!))
            {
                arrTask.addObject(txtTask.text!)
                txtTask.text = ""
                tblTask.reloadData()
                txtTask.becomeFirstResponder()
            }
        }
    }
    
    
    func textFieldShouldReturn(aTextField: UITextField) -> Bool {
        aTextField.resignFirstResponder()
        
        if(aTextField == txtTask)
        {
            if(!(txtTask.text?.isEmpty)!)
            {
                if(!arrTask.containsObject(txtTask.text!))
                {
                    arrTask.addObject(txtTask.text!)
                    txtTask.text = ""
                    tblTask.reloadData()
                    txtTask.becomeFirstResponder()
                }
            }
        }
        return true
    }
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrTask.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let aCell = tableView.dequeueReusableCellWithIdentifier("TaskCell", forIndexPath: indexPath) as! TaskCell
        
        aCell.lblTask.text = arrTask.objectAtIndex(indexPath.row) as! String
        
        aCell.btnCheckBox.addTarget(self, action: #selector(btnCheckmarkAction), forControlEvents: .TouchUpInside)
        
        
        return aCell
    }
    
    func btnCheckmarkAction(sender: UIButton!) {
        let aBtn: UIButton = sender as UIButton
        aBtn.selected = !(aBtn.selected)
        
        let buttonPosition = sender.convertPoint(CGPointZero, toView: self.tblTask)
        let tappedIP: NSIndexPath = self.tblTask.indexPathForRowAtPoint(buttonPosition)!
        
        if(arrTask.count > 0)
        {
            arrTask.removeObjectAtIndex(tappedIP.row)
//            let indexPath = NSIndexPath(forRow: tappedIP.row, inSection: 1)
//            tblTask.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            tblTask.reloadData()
        }
        
    }

    @IBAction func btnDoneAction(sender: UIButton) {
        delegate?.setAddedTask(arrTask)
        self.navigationController?.popViewControllerAnimated(true)
    }
}
