//
//  ReminderSelcectionVC.swift
//  Simplify
//
//  Created by Vishal Rana on 6/13/16.
//  Copyright © 2016 2359 Media Pte Ltd. All rights reserved.
//

import UIKit

protocol ReminderSelector {
    func setRemindervalue(isReminder:Bool)
}

class ReminderSelcectionVC: UIViewController {

    
    var delegate: ReminderSelector?
    var isAlrmOn:Bool!
    @IBOutlet weak var btnTime: UIButton!
    @IBOutlet weak var btnLoction: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if(isAlrmOn == true)
        {
            btnTime.selected = true
        }else
        {
            btnTime.selected = false
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnBackAction(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }


    @IBAction func btnDoneAction(sender: UIButton) {
        
        delegate?.setRemindervalue(btnTime.selected)
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    @IBAction func btnTimeAction(sender: UIButton) {
        
        let aBtn: UIButton = sender as UIButton
        aBtn.selected = !(aBtn.selected)
    }
    
    @IBAction func btnLocAction(sender: UIButton) {
        
        let aBtn: UIButton = sender as UIButton
        aBtn.selected = !(aBtn.selected)
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
