//
//  RecurrenceVC.swift
//  Simplify
//
//  Created by Vishal Rana on 6/13/16.
//  Copyright © 2016 2359 Media Pte Ltd. All rights reserved.
//

import UIKit


protocol RecurrenceSelector {
    func setRecurrence(isWeekly:Bool,is4Week:Bool,isDay:Bool, arrDay:NSMutableArray)
}


class RecurrenceVC: UIViewController {
    @IBOutlet weak var btnMon: UIButton!

    @IBOutlet weak var btnTue: UIButton!
    
    @IBOutlet weak var btnWed: UIButton!
    
    
    @IBOutlet weak var btnSun: UIButton!
    @IBOutlet weak var btnThu: UIButton!
    
    @IBOutlet weak var btnSat: UIButton!
    
    @IBOutlet weak var btnFri: UIButton!
    var delegate: RecurrenceSelector?

    var arrDays:NSMutableArray!
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let gregorian = NSCalendar(calendarIdentifier: NSGregorianCalendar)
//        let comps = gregorian!.components(.NSWeekdayCalendarUnit, fromDate: NSDate())
//        let weekday = comps.weekday
//        
//        if(weekday == 1){
//            if(!arrDays.containsObject(7)){
//                arrDays.addObject(7)
//            }
//        }else{
//            if(!arrDays.containsObject(weekday-1)){
//                arrDays.addObject(weekday-1)
//            }
//        }
        
       self.setUpView()
        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var btnWeekly: UIButton!

    @IBOutlet weak var btnRecur4Weeks: UIButton!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnBackAction(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func setUpView(){
        

        
//        if(self.arrDays.count == 7){
//            btnWeekly.selected = true
//            btnRecur4Weeks.selected = false
//        }else{
            for i in 0 ..< self.arrDays.count{
                
                switch (self.arrDays.objectAtIndex(i) as! Int) {
                    
                case 1:
                    
                    if(arrDays.containsObject(1)){
                        btnMon.selected = true
                    }else{
                        btnMon.selected = false
                    }
                    
                case 2:
                    if(arrDays.containsObject(2)){
                        btnTue.selected = true
                    }else{
                        btnTue.selected = false
                    }
                    
                case 3:
                    
                    if(arrDays.containsObject(3)){
                        btnWed.selected = true
                    }else{
                        btnWed.selected = false
                    }
                    
                case 4:
                    if(arrDays.containsObject(4)){
                        btnThu.selected = true
                    }else{
                        btnThu.selected = false
                    }
                    
                case 5:
                    
                    if(arrDays.containsObject(5)){
                        btnFri.selected = true
                    }else{
                        btnFri.selected = false
                    }
                    
                case 6:
                    if(arrDays.containsObject(6)){
                        btnSat.selected = true
                    }else{
                        btnSat.selected = false
                    }
                    
                case 7:
                    if(arrDays.containsObject(7)){
                        btnSun.selected = true
                    }else{
                        btnSun.selected = false
                    }
                default:
                    break;
                    
                }
                
            //}
        }
        
      
    }
    @IBAction func btnWeeklyAction(sender: UIButton) {
        
        let aBtn: UIButton = sender as UIButton
        aBtn.selected = !(aBtn.selected)

        btnRecur4Weeks.selected = false
        
        btnMon.selected = false
        btnTue.selected = false
        btnWed.selected = false
        btnThu.selected = false
        btnFri.selected = false
        btnSat.selected = false
        btnSun.selected = false

    }
    
    @IBAction func btnRecur4weeksAction(sender: UIButton) {
        
        let aBtn: UIButton = sender as UIButton
        aBtn.selected = !(aBtn.selected)
        
        btnWeekly.selected = false
        
        btnMon.selected = false
        btnTue.selected = false
        btnWed.selected = false
        btnThu.selected = false
        btnFri.selected = false
        btnSat.selected = false
        btnSun.selected = false
        
    }
    
    
    @IBAction func btnDoneAction(sender: UIButton) {
        
        if(btnWeekly.selected == true){
            delegate?.setRecurrence(true, is4Week: false,isDay:false, arrDay: arrDays)
        }else if(btnRecur4Weeks.selected == true){
            delegate?.setRecurrence(false, is4Week: true,isDay:false, arrDay: arrDays)
        }else if(btnMon.selected == true||btnTue.selected == true||btnWed.selected == true||btnThu.selected == true||btnFri.selected == true||btnSun.selected == true||btnSat.selected == true )
        {
            delegate?.setRecurrence(false, is4Week: false,isDay:true, arrDay: arrDays)
        }else{
            delegate?.setRecurrence(false, is4Week: false,isDay:false, arrDay: arrDays)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func btnWeeksDayAction(sender: UIButton) {
        
        let aBtn: UIButton = sender as UIButton
        aBtn.selected = !(aBtn.selected)

        btnWeekly.selected = false
        btnRecur4Weeks.selected = false
        
        
        switch (sender.tag)
        {
        case 10:
            btnMon.selected = aBtn.selected
            
            if(btnMon.selected == true)
            {
                if(!arrDays.containsObject(1))
                {
                    arrDays.addObject(1)
                }
             }
            else
            {
                arrDays.removeObject(1)
            }
            
        case 11:
            btnTue.selected = aBtn.selected
            if(btnTue.selected == true)
            {
                if(!arrDays.containsObject(2))
                {
                    arrDays.addObject(2)
                }
            }
            else
            {
                arrDays.removeObject(2)
            }

        case 12:
            btnWed.selected = aBtn.selected
            if(btnWed.selected == true)
            {
                if(!arrDays.containsObject(3))
                {
                    arrDays.addObject(3)
                }
            }
            else
            {
                arrDays.removeObject(3)
            }

        case 13:
            btnThu.selected = aBtn.selected
            if(btnThu.selected == true)
            {
                if(!arrDays.containsObject(4))
                {
                    arrDays.addObject(4)
                }
            }
            else
            {
                arrDays.removeObject(4)
            }

        case 14:
            btnFri.selected = aBtn.selected
            
            if(btnFri.selected == true)
            {
                if(!arrDays.containsObject(5))
                {
                    arrDays.addObject(5)
                }
            }
            else
            {
                arrDays.removeObject(5)
            }

        case 15:
            btnSat.selected = aBtn.selected
            if(btnSat.selected == true)
            {
                if(!arrDays.containsObject(6))
                {
                    arrDays.addObject(6)
                }
            }
            else
            {
                arrDays.removeObject(6)
            }

        case 16:
            btnSun.selected = aBtn.selected
            if(btnSun.selected == true)
            {
                if(!arrDays.containsObject(7))
                {
                    arrDays.addObject(7)
                }
            }
            else
            {
                arrDays.removeObject(7)
            }
            
        default:
            break;
        }

        
        if(btnMon.selected == true && btnTue.selected == true && btnWed.selected == true && btnThu.selected == true && btnFri.selected == true && btnSat.selected == true && btnSun.selected == true )
        {
            btnWeekly.selected = true
        }
        else
        {
            btnWeekly.selected = false
        }
        
    }
}
