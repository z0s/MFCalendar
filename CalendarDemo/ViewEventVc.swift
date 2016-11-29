 //
//  ViewEventVc.swift
//  Simplify
//
//  Created by Vishal Rana on 6/17/16.
//  Copyright © 2016 2359 Media Pte Ltd. All rights reserved.
//

import UIKit
import EventKit
import Parse
import SVProgressHUD
import AlamofireImage
import SwiftDate

 
class ViewEventVc: UIViewController,UITableViewDataSource,UICollectionViewDataSource,UICollectionViewDelegate {
   

    
    @IBOutlet weak var viewBadgeNote: UIView!
    //--------Outlets------------//
    
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let eventStore: EKEventStore = EKEventStore()

    @IBOutlet weak var viewNotes: UIView!
    
    var objDict:NSMutableDictionary = NSMutableDictionary()
   
    @IBOutlet weak var txtWeb: UIWebView!
    
    @IBOutlet weak var viewDocs: UIView!
    
    @IBOutlet weak var viewTasks: UIView!
    var eventView:EKEvent!
    @IBOutlet weak var viewNoAttendees: UIView!
    @IBOutlet var scrollViewBottomHeight: NSLayoutConstraint!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var viewDetails: UIView!
    @IBOutlet var viewSegment: UIView!
    @IBOutlet var viewChat: UIView!
    
    @IBOutlet var lblDateAndTime: UILabel!
    @IBOutlet var imgRefresh: UIImageView!
    @IBOutlet var collectionFamilyMembers: UICollectionView!
    
    @IBOutlet weak var viewNoTask: UIView!
    
    @IBOutlet weak var viewNoDocs: UIView!
    
    @IBOutlet weak var viewNoNotes: UIView!
    @IBOutlet var lblLocation: UILabel!
    @IBOutlet var lblRemainder: UILabel!
    
    @IBOutlet var viewTasksSegment: UIView!
    @IBOutlet var viewDocsSegment: UIView!
    @IBOutlet var viewNotesSegment: UIView!
    
    @IBOutlet var lblTask: UILabel!
    @IBOutlet var imgTasks: UIImageView!
    
    @IBOutlet var viewTaskBadge: UIView!
    
    @IBOutlet var imgDocs: UIImageView!
    @IBOutlet var lblDocs: UILabel!
    
    
    @IBOutlet var viewDocsBadge: UIView!
    
    @IBOutlet var imgNotes: UIImageView!
        
    @IBOutlet weak var lblGroup: UILabel!
    @IBOutlet var lblDoctCounter: UILabel!
    @IBOutlet var lblTaskCounter: UILabel!
    @IBOutlet var lblNotes: UILabel!
    
    @IBOutlet var tblTask: UITableView!
    
    @IBOutlet var imgChatPerson: UIImageView!
    
    @IBOutlet var lblChat: UILabel!
    var taskCounter = 0
    //--------Outlets Over------------//
    var arrTaskPFobj = [PFObject]()
    let arrDocList = NSMutableArray()

    var eventConversionId:String = ""
    @IBOutlet weak var tblDocs: UITableView!
    var arrPhotos = NSMutableArray()
    
    var familyMembers = [PFObject]()
 
    var isWeeklyOnly:Bool = false
    override func viewDidLoad() {
                
        super.viewDidLoad()
        
         self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont.boldSystemFontOfSize(17)]
        
        tblTask.tableFooterView = UIView()
        tblDocs.tableFooterView = UIView()

        if(self.view.frame.size.height > 568){
            scrollViewBottomHeight.constant += (667-568)
        }
        if(self.view.frame.size.height > 667){
            scrollViewBottomHeight.constant += (736-568)
        }
        
        

        viewSegment.layer.cornerRadius = 5
        viewSegment.layer.masksToBounds = true
        
        viewTasks.hidden = false
        viewNotes.hidden = true
        viewDocs.hidden = true
        self.badgesSetUp()
            
        if let strN = eventView.notes{
            self.txtWeb.loadHTMLString(strN, baseURL: nil)
            viewBadgeNote.hidden = false
            self.viewNoNotes.hidden = true

        }else{
            viewBadgeNote.hidden = true
            self.viewNoNotes.hidden = false

        }
        
        if let arrAlarm = eventView.alarms?.first{
            lblRemainder.text = "Reminder 10 minutes before"
        }else{
            lblRemainder.text = "No Reminder"
        }

        var strU = ""
        if(eventView.URL != nil){
            strU = "\(eventView.URL!)"
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ViewEventVc.EditEvent))
        
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ViewEventVc.Cancel))
        self.title = eventView.title
        
        if(eventView.location! == ""){
            lblLocation.text = ""
        }
        else{
            lblLocation.text = eventView.location
        }

        self.getEventTask(strU)
        self.getEventAttendees(strU)
        self.getEventDocs(strU)
    
        self.setEventDateAndRecurrence(eventView.startDate, end: eventView.endDate)
        
    }
    
    
    
    
    
    
    func getEventAttendees(strEvent:String)
    {
        self.arrPhotos = NSMutableArray()
        //get attendees
        let query: PFQuery = PFQuery(className:"Peoples")
       // query.whereKey("eventId", equalTo: strEvent)
        query.whereKey("eventUnique", equalTo: strEvent)

        let user = PFUser.currentUser()

        query.findObjectsInBackgroundWithBlock{(objects: [PFObject]?, error: NSError?) -> Void in
            SVProgressHUD.dismiss()
            if error == nil
            {
                for object: PFObject in objects!{
                    if(!self.arrPhotos.containsObject(object.objectForKey("Name") as! String)){
                        self.arrPhotos.addObject(object.objectForKey("Name") as! String)
                    }
                    
                }
            
            }
            else
            {
                NSLog("%@", error!.description)
            }
            
            self.collectionFamilyMembers.reloadData()
        }
        
    }
    
    
    func setEventDateAndRecurrence(start:NSDate,end:NSDate)
    {
        var stroccurance = ""

        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let startDate = dateFormatter.dateFromString(dateFormatter.stringFromDate(start))
        
        let endDate = dateFormatter.dateFromString(dateFormatter.stringFromDate(end))
        

        let dateFormatterSD = NSDateFormatter()
        dateFormatterSD.dateStyle = NSDateFormatterStyle.FullStyle
        dateFormatterSD.timeStyle = NSDateFormatterStyle.NoStyle
        let strSD = dateFormatterSD.stringFromDate(start)
        
        let dateFormatterST = NSDateFormatter()
        dateFormatterST.dateStyle = NSDateFormatterStyle.NoStyle
        dateFormatterST.timeStyle = NSDateFormatterStyle.ShortStyle
        let strST = dateFormatterST.stringFromDate(start)
        
        let dateFormatterED = NSDateFormatter()
        dateFormatterED.dateStyle = NSDateFormatterStyle.FullStyle
        dateFormatterED.timeStyle = NSDateFormatterStyle.NoStyle
        let strED = dateFormatterED.stringFromDate(end)
        
        let dateFormatterET = NSDateFormatter()
        dateFormatterET.dateStyle = NSDateFormatterStyle.NoStyle
        dateFormatterET.timeStyle = NSDateFormatterStyle.ShortStyle
        let strET = dateFormatterET.stringFromDate(end)
    
        if(startDate?.isEqualToDate(endDate!) == true){
            stroccurance = String(format: "%@\nfrom %@ to %@",strSD,strST,strET)
        }else{
            stroccurance = String(format: "from %@ %@\nto %@ %@",strST,strSD,strET,strED)
        }

        lblDateAndTime.text = stroccurance
        lblDateAndTime.adjustsFontSizeToFitWidth = true
        lblDateAndTime.sizeToFit()
        
        if let recurrenceRule = eventView.recurrenceRules?.first {
            self.setRepeatLabel(stroccurance)
        }
        
       

    }
    
    func setRepeatLabel(strRepeat:String){
        
        let rruleRegex = "RRULE .*"
        var recurrenceRuleString = ""
        
        if let recurrenceRule = eventView.recurrenceRules?.first {
            let rruleDescription = "\(recurrenceRule)"
            if let range = rruleDescription.rangeOfString(rruleRegex, options: .RegularExpressionSearch) {
                recurrenceRuleString = rruleDescription.substringWithRange(range)
                
                let arrRrule:[String] = recurrenceRuleString.componentsSeparatedByString(";")
                let strRuleFrq:String!
                let strRuleDays:String!
                strRuleFrq = arrRrule.first!.componentsSeparatedByString("=").last!
                strRuleDays = arrRrule.last!.componentsSeparatedByString("=").last!
                
                if(strRuleFrq == "MONTHLY" || strRuleFrq == "Monthly"){
                    recurrenceRuleString = "repeats monthly"
                }
                else if(strRuleFrq == "YEARLY" || strRuleFrq == "Yearly"){
                    recurrenceRuleString = "repeats yearly"
                    
                }else if(strRuleFrq == "DAILY" || strRuleFrq == "Daily"){
                    recurrenceRuleString = "repeats daily"
                    
                }else{
                    
                    
                    if(arrRrule.count ==  2){
                        recurrenceRuleString = "repeats every week "
                        
                        isWeeklyOnly = true
                        
                    }else{
                       
                        recurrenceRuleString = "repeats every week on "
                        
                        isWeeklyOnly = false

                        let arrDays:[String] = strRuleDays.componentsSeparatedByString(",")
                        
                        for i in 0 ..< arrDays.count {
                            
                            switch (arrDays[i]){
                            case "MO":
                                recurrenceRuleString =  recurrenceRuleString.stringByAppendingString("Monday,")
                                
                            case "TU":
                                recurrenceRuleString =  recurrenceRuleString.stringByAppendingString("Tuesday,")
                                
                            case "WE":
                                recurrenceRuleString = recurrenceRuleString.stringByAppendingString("Wednesday,")
                                
                            case "TH":
                                recurrenceRuleString = recurrenceRuleString.stringByAppendingString("Thursday,")
                                
                            case "FR":
                                recurrenceRuleString =  recurrenceRuleString.stringByAppendingString("Friday,")
                                
                            case "SA":
                                recurrenceRuleString = recurrenceRuleString.stringByAppendingString("Saturday,")
                                
                            case "SU":
                                recurrenceRuleString = recurrenceRuleString.stringByAppendingString("Sunday,")
                                
                            default:
                                break;
                            }
                            
                            
                        }
                        
                        recurrenceRuleString = recurrenceRuleString.substringToIndex(recurrenceRuleString.endIndex.predecessor())

                    }
                    
                    
                    let strFinal = String(format: "%@\n%@",strRepeat,recurrenceRuleString)

                    
                    lblDateAndTime.text = strFinal
                    lblDateAndTime.adjustsFontSizeToFitWidth = true
                    lblDateAndTime.sizeToFit()
                }
                
            }
        }
    
        
    }
    
    
    func getEventTask(strEvent:String)
    {
        SVProgressHUD.show()

        let queryTask: PFQuery = PFQuery(className:"Tasks")
        queryTask.whereKey("eventUnique", equalTo: strEvent)

        queryTask.findObjectsInBackgroundWithBlock{(objects: [PFObject]?, error: NSError?) -> Void in
            SVProgressHUD.dismiss()
            if error == nil
            {
                for object: PFObject in objects!
                {
                    
                    if(!self.arrTaskPFobj.contains(object)){
                        self.arrTaskPFobj.append(object)
                    }

                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.lblTaskCounter.text = "\( self.arrTaskPFobj.count)"
                    self.tblTask.reloadData()
                }
            }
            else
            {
                NSLog("%@", error!.description)
            }
        }
    }
    
    func getEventDocs(strEvent:String)
    {
        SVProgressHUD.show()

        
        let queryDoc: PFQuery = PFQuery(className:"Docs")
        
        queryDoc.whereKey("eventUnique", equalTo: strEvent)

        queryDoc.findObjectsInBackgroundWithBlock{(objects: [PFObject]?, error: NSError?) -> Void in
            SVProgressHUD.dismiss()
            if error == nil{
                
                for object: PFObject in objects!{
                    
                    let url = object.valueForKey("Name") as! String
                    if(!self.arrDocList.containsObject(url)){
                        self.arrDocList.addObject(url)
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.lblDoctCounter.text = "\( self.arrDocList.count)"
                    self.tblDocs.reloadData()
                }
            }
            else
            {
                NSLog("%@", error!.description)
            }
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = true
        
        
        if(delegate.isSavedEvent == true){
            delegate.isSavedEvent = false
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        }
        
        
    
    }
    
    
    
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.hidden = false
      
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if(tableView == tblTask){
            if(arrTaskPFobj.count == 0){
                self.viewNoTask.hidden = false
            }else{
                self.viewNoTask.hidden = true
            }
            
            return arrTaskPFobj.count
        }else{
            
            if(arrDocList.count == 0){
                self.viewNoDocs.hidden = false
            }else{
                self.viewNoDocs.hidden = true
            }
            
            return arrDocList.count
        }
        
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if(tableView == tblDocs){

                   }
        
    }

    func Cancel(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func EditEvent(){
        
        let sb = UIStoryboard(name: "Calender_v2", bundle: nil)
        let navVc = sb.instantiateViewControllerWithIdentifier("CreateNav") as! UINavigationController
        let eventViewVc = navVc.topViewController as! CreateEventVC
        eventViewVc.editedEvent = eventView
        eventViewVc.isEdit = true
        eventViewVc.isFromCallib = false
        self.presentViewController(navVc, animated: true, completion: nil)
    }
    
    internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        if(tableView == tblTask){
            let aCell :TaskCell = tableView.dequeueReusableCellWithIdentifier("task") as! TaskCell
            aCell.lblTask.text = arrTaskPFobj[indexPath.row].valueForKey("Name") as? String
            
//            if(arrTaskPFobj[indexPath.row].valueForKey("taskComplete") as? Bool == true){
//               aCell.btnCheckBox.selected = true
//            }else{
//                aCell.btnCheckBox.selected = false
//             }
//            aCell.btnCheckBox.addTarget(self, action: #selector(ViewEventVc.btnCheckBoxAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            return aCell
 
        }else{
            
            
            let cell = tableView.dequeueReusableCellWithIdentifier("docTableViewCell") as UITableViewCell!
            
            let lblItem:UILabel!
            lblItem = cell.contentView.viewWithTag(2222) as! UILabel

            let imgItem:UIImageView!
            imgItem = cell.contentView.viewWithTag(1111) as! UIImageView
            
            let strTemp:String = self.arrDocList.objectAtIndex(indexPath.row).componentsSeparatedByString("/").last!
            let strFile:String = strTemp.componentsSeparatedByString("||||").last!

            let strType = strFile.componentsSeparatedByString(".").last

//            if(strType == "pdf" || strType == "PDF"){
//                imgItem.image = UIImage(named:"PDF")
//            }else if(strType == "ppt" || strType == "pptx" || strType == "PPT" || strType == "PPTX"){
//                imgItem.image = UIImage(named:"PPT")
//            }else if(strType == "png" || strType == "PNG"||strType == "jpg" || strType == "JPG"||strType == "jpeg" || strType == "JPEG"){
//                imgItem.image = UIImage(named:"JPG")
//            }else if(strType == "txt" || strType == "TXT"){
//                imgItem.image = UIImage(named:"TXT")
//            }else if(strType == "zip" || strType == "ZIP"){
//                imgItem.image = UIImage(named:"ZIP")
//            }else if(strType == "doc" || strType == "DOC"){
//                imgItem.image = UIImage(named:"DOC")
//            }else{
//                imgItem.image = UIImage(named:"normalfile")
//            }

            lblItem.text = strFile
            

            return cell
        }
    }
    
    internal func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.arrPhotos.count
    }
    
    internal func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        
        let aCell : FamilyMemberCell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! FamilyMemberCell
        
        
//        let user = familyMembers[indexPath.row]
//        if let url = user.valueForKey("avatarImageURL") {
//            let size = CGSize(width: 50 , height: 50)
//            let imageFilter = AspectScaledToFillSizeCircleFilter(size: size)
//            aCell.imgFamilyMember.af_setImageWithURL(url as! NSURL, placeholderImage: UIImage(named: "user_picture"), filter: imageFilter)
//        }
        
        aCell.layer.cornerRadius = aCell.frame.size.width/2
        aCell.layer.masksToBounds = true
        
        return aCell
    }
    
    internal  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        
        
//        var cell = collectionView.cellForItemAtIndexPath(indexPath)
//        if(cell == nil){
//            
//            cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! FamilyMemberCell
//        }
//        
//        cell!.layer.borderWidth = 2
//        cell!.layer.borderColor =  UIColor.init(colorLiteralRed: 0.075, green: 0.533, blue: 0.58, alpha: 1).CGColor
//        let temp: NSMutableDictionary =  ["image":arrPhotos.objectAtIndex(indexPath.item).valueForKey("image")!,"imageSelected":"Y"]
//        arrPhotos.replaceObjectAtIndex(indexPath.row, withObject: temp)
//        print(temp)
        
        
    }
    internal  func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath)
    {
//        
//        var cell = collectionView.cellForItemAtIndexPath(indexPath)
//        if(cell == nil){
//            
//            cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! FamilyMemberCell
//        }
//        print("task\(indexPath.item)")
//        cell!.layer.borderWidth = 0
//        let temp: NSMutableDictionary =  ["image":arrPhotos.objectAtIndex(indexPath.item).valueForKey("image")!,"imageSelected":"N"]
//        arrPhotos.replaceObjectAtIndex(indexPath.row, withObject: temp)
    }
    
    

    func btnCheckBoxAction(sender:UIButton!)
    {
        let aBtn: UIButton = sender as UIButton
        aBtn.selected = !(aBtn.selected)
        
        let buttonPosition = sender.convertPoint(CGPointZero, toView: tblTask)
        let indexPath = tblTask.indexPathForRowAtPoint(buttonPosition)

        let obj = self.arrTaskPFobj[(indexPath?.row)!] 

        if(aBtn.selected)
        {
            obj["taskComplete"] = true
        }
        else
        {
            obj["taskComplete"] = false
        }
        
        obj.saveInBackground()
    }
    
    @IBAction func btnSegmentAction(sender: UIButton)
    {
        //First Clean Up
        viewTasksSegment.backgroundColor    = UIColor.whiteColor()
        viewDocsSegment.backgroundColor     = UIColor.whiteColor()
        viewNotesSegment.backgroundColor    = UIColor.whiteColor()
        lblTask.textColor   =   UIColor.darkGrayColor()
        lblDocs.textColor   =   UIColor.darkGrayColor()
        lblNotes.textColor  =   UIColor.darkGrayColor()
        lblTask.font        =   UIFont.systemFontOfSize(14.0)
        lblDocs.font        =   UIFont.systemFontOfSize(14.0)
        lblNotes.font        =   UIFont.systemFontOfSize(14.0)
        //----- Clean Up Complete -------//
        
        if(sender.tag == 1){
            
            viewTasksSegment.backgroundColor    =   UIColor.init(colorLiteralRed: 0.075, green: 0.533, blue: 0.58, alpha: 1)
            lblTask.textColor                   =   UIColor.whiteColor()
            lblTask.font        =   UIFont.boldSystemFontOfSize(14.0)
            
            viewTasks.hidden = false
            viewNotes.hidden = true
            viewDocs.hidden = true
            
        }
        if(sender.tag == 2){
            
            viewDocsSegment.backgroundColor    =   UIColor.init(colorLiteralRed: 0.075, green: 0.533, blue: 0.58, alpha: 1)
            lblDocs.textColor                   =   UIColor.whiteColor()
            lblDocs.font        =   UIFont.boldSystemFontOfSize(14.0)
            
            viewTasks.hidden = true
            viewNotes.hidden = true
            viewDocs.hidden = false
            
        }
        if(sender.tag == 3){
            
            viewNotesSegment.backgroundColor    =   UIColor.init(colorLiteralRed: 0.075, green: 0.533, blue: 0.58, alpha: 1)
            lblNotes.textColor                   =   UIColor.whiteColor()
            lblNotes.font        =   UIFont.boldSystemFontOfSize(14.0)
            
            viewTasks.hidden = true
            viewNotes.hidden = false
            viewDocs.hidden = true
            
        }
        
    }
    
    func badgesSetUp(){
        
        viewDocsBadge.layer.cornerRadius    =  viewDocsBadge.frame.size.width/2
        viewTaskBadge.layer.cornerRadius    =  viewTaskBadge.frame.size.width/2
        viewDocsBadge.layer.masksToBounds   =  true
        
        viewBadgeNote.layer.cornerRadius    =  viewBadgeNote.frame.size.width/2
        viewBadgeNote.layer.masksToBounds   =  true
        
        viewTaskBadge.layer.masksToBounds   =  true
        
    }
    
    @IBAction func btnCancelAction(sender: UIButton) {
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
       
   
}

