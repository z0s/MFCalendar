 //
//  CreateEventVC.swift
//  Simplify
//
//  Created by Vishal Rana on 9/15/16.
//  Copyright © 2016 2359 Media Pte Ltd. All rights reserved.
//

import UIKit
import Parse
import SVProgressHUD
import AlamofireImage
import EventKit
import SwiftDate

 

 
class CreateEventVC: UIViewController,TaskSelector,NoteSelector,PeopleSelector,DocSelector,UICollectionViewDelegate,UICollectionViewDataSource,ReminderSelector,RecurrenceSelector,UIGestureRecognizerDelegate,UITextFieldDelegate{

    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var viewDelete: UIView!
    @IBOutlet weak var viewbadgeNote: UIView!
    
    var eventUnique:String!
    var isStartime:Bool = true
    /// Return existing or create family calendar
    
    @IBOutlet weak var collectPeople: UICollectionView!
    var familyMembers = [String]()
    var isSaveOnly:Bool = false
    var arrDocs:NSMutableArray!
    var taskObjects : [PFObject] = [PFObject]()
    var docObjects  :[PFObject] = [PFObject]()
    var arrInvitees = [PFObject]()

    var isEdit:Bool = false
    var arrPeople = NSMutableArray()
    var arrTasklist:NSMutableArray!
    var strLoc:String!
    var eventStartDate,evnetEndDate:NSDate!
    var isRecurrenceSelected:Bool = false
    var offsetAlarm:Int = 0
    var eventPfobj:PFObject!
    var peoplePreviousCount:Int = 0
    var previousTitle:String = ""
    
    var tasksPreviousCount:Int = 0
    var docsPreviousCount:Int = 0
    
    var peopleIndexes =  NSMutableArray()
    
    var editedEvent:EKEvent!
    let eventStore: EKEventStore = EKEventStore()
    var arrDaysRec = NSMutableArray()
    var isWeekly:Bool = false
    var isMonthly:Bool = false
    var isDays:Bool = false
    var isFromCallib:Bool = false
    var calLibStartDate:NSDate!
    var isAlrmOn:Bool = false
    var strNotes:String = ""
    
    var oldUniquestr:String!
    var lastStartDateStr,lastEndDateStr:String!
    var lastStartDate,lastEndDate:NSDate!

    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblStartDate: UILabel!

    @IBOutlet weak var lblDocCounter: UILabel!
    @IBOutlet weak var lblTaskCounter: UILabel!
    @IBOutlet weak var lblEndDate: UILabel!
    @IBOutlet weak var pickerDateTime: UIDatePicker!
    @IBOutlet weak var viewPopup: UIView!
    @IBOutlet weak var viewLayer: UIView!
    @IBOutlet weak var txtTitle: UITextField!
   
    @IBOutlet weak var lblRepeat: UILabel!
    @IBOutlet weak var txtLocation: UITextField!
    
    @IBOutlet weak var lblReminders: UILabel!
    
    var textOutsideTap:UIGestureRecognizer!
    var  newCalendar:EKCalendar!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        delegate.isSavedEvent = false
        isAlrmOn = false

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CreateEventVC.save))
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CreateEventVC.cancel))
        strNotes = ""
        arrTasklist = NSMutableArray()
        arrDocs = NSMutableArray()

        self.askPermission()   
        self.setUp()
        

    }

    override func viewDidAppear(animated: Bool) {
        if strNotes == "" {
            viewbadgeNote.hidden = true
        }else{
            viewbadgeNote.hidden = false
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func askPermission()
    {
        let eventStore = EKEventStore()
        

        // EKSourceTypeCalDAV
        eventStore.requestAccessToEntityType(.Event) { (granted, error) in
            if(granted) && (error == nil)
            {
                let calendars = self.eventStore.calendarsForEntityType(.Event)
                let index = calendars.indexOf({ calendar in
                    return calendar.title == NSLocalizedString("MobileFirst", comment: "")
                })
                
                if let calendarIndex = index {
                    self.newCalendar = calendars[calendarIndex]
                    return
                }
                
                self.newCalendar = EKCalendar(forEntityType: .Event, eventStore: self.eventStore)
                
                
                let eventSourceIndex = self.eventStore.sources.indexOf { source in
                    return source.title == "iCloud"
                }
                
                
                var sourceIndex:Int
                var source:EKSource!
                if let index = eventSourceIndex{
                    sourceIndex = index
                    source = self.eventStore.sources[sourceIndex]
                } else {
                    let eventLocalSourceIndex = self.eventStore.sources.indexOf { source in
                        return source.title == "Default"
                    }
                    
                    if eventLocalSourceIndex == nil {
                        source = self.eventStore.defaultCalendarForNewEvents.source
                    }else{
                        sourceIndex = eventLocalSourceIndex!
                        source = self.eventStore.sources[sourceIndex]
                    }
                    
                }
                
                self.newCalendar.title = NSLocalizedString("MobileFirst", comment: "")
                if(source != nil){
                    self.newCalendar.source = source
                }
                self.newCalendar.CGColor = UIColor.blueColor().CGColor
                do {
                    try self.eventStore.saveCalendar(self.newCalendar, commit: true)
                } catch let error as NSError {
                    //self.presentOneTimeAlert(title: "Error", message: "Unable to save calendar")
                }
            }
            else
            {
                print(error?.localizedDescription)
            }
        }
    }
    
    
        
    func save(){
        
        if(self.txtTitle.text!.isEmpty){
            //self.presentOneTimeAlert(title: "Error", message: "Please enter title.")
            return
        }
    
        if(isEdit == true){
            eventStartDate = lastStartDate
            evnetEndDate = lastEndDate
        }else{
            
            if(lastStartDate == nil || lastEndDate == nil){
               // self.presentOneTimeAlert(title: "Error", message: "Start date and End date both are required")
                return
            }else{
                eventStartDate = lastStartDate
                evnetEndDate = lastEndDate
            }
        }
        
        strLoc = txtLocation.text
        
        
        
                var newEvent:EKEvent!
            
                
                eventUnique = self.generateUniqueId(self.txtTitle.text!, startDate: eventStartDate)
                
                guard let urlU = NSURL(string:eventUnique) else { return }
                
                let urlUnique:NSURL = urlU
                
                if(isEdit == true){
                    newEvent = eventStore.eventWithIdentifier(self.editedEvent.eventIdentifier)!
                    oldUniquestr = newEvent.URL?.absoluteString
                }else{
                    newEvent = EKEvent(eventStore: eventStore)
                    newEvent.URL = urlUnique
                }

        
                newEvent.calendar = newCalendar
                newEvent.title = self.txtTitle.text!
//                newEvent.startDate = eventStartDate
//                newEvent.endDate = evnetEndDate
                newEvent.location = strLoc
                newEvent.timeZone = NSTimeZone.localTimeZone()
                newEvent.notes = strNotes
                
                if(isEdit){
                    if(isWeekly || isDays || isMonthly){
                        if(newEvent.hasRecurrenceRules){
                            newEvent.removeRecurrenceRule(editedEvent.recurrenceRules![0])
                        }
                    }
                }
                
 
                if(isWeekly || isDays || isMonthly){
                    newEvent.addRecurrenceRule(self.generateRecurranceRule())
                }
                
                if(offsetAlarm != 0){
                    let Offset: NSTimeInterval = NSTimeInterval(Int(offsetAlarm))
                    
                    let alarm:EKAlarm = EKAlarm(relativeOffset: -Offset)
                    newEvent.alarms = [alarm]
                }else{
                    if(newEvent.hasAlarms && newEvent.alarms?.count > 0){
                      newEvent.removeAlarm(newEvent.alarms![0])
                    }
                }
                
                if(isEdit){
                    if let recurrenceRule = editedEvent!.recurrenceRules?.first {
                        self.openActionSheetSave(newEvent)
                    }else{
                        self.saveNormalEvent(newEvent)
                    }
                }else{
                    self.saveNormalEvent(newEvent)
                }
                
                
                
    }
    
    
    func generateRecurranceRule()->EKRecurrenceRule{
        
        var ruleToEvent:EKRecurrenceRule!
        let repeatDays = NSMutableArray()

        if(isWeekly){
            ruleToEvent = EKRecurrenceRule(recurrenceWithFrequency: .Weekly, interval: 1, end: nil)
        }else if(isMonthly){
            ruleToEvent = EKRecurrenceRule(recurrenceWithFrequency: .Monthly, interval: 1, end: nil)
        }else if(isDays){
            for i in 0 ..< self.arrDaysRec.count {
                
                switch (self.arrDaysRec.objectAtIndex(i) as! Int){
                case 1:
                    
                    let everyMon = EKRecurrenceDayOfWeek(.Monday)
                    
                    if(!repeatDays.containsObject(everyMon)){
                        repeatDays.addObject(everyMon)
                    }
                    
                    
                case 2:
                    
                    let everyTue = EKRecurrenceDayOfWeek(.Tuesday)
                    if(!repeatDays.containsObject(everyTue)){
                        repeatDays.addObject(everyTue)
                    }
                    
                    
                case 3:
                    
                    let everyWed = EKRecurrenceDayOfWeek(.Wednesday)
                    if(!repeatDays.containsObject(everyWed)){
                        repeatDays.addObject(everyWed)
                    }
                    
                case 4:
                    let everyThu = EKRecurrenceDayOfWeek(.Thursday)
                    if(!repeatDays.containsObject(everyThu)){
                        repeatDays.addObject(everyThu)
                    }
                    
                case 5:
                    let everyFri = EKRecurrenceDayOfWeek(.Friday)
                    if(!repeatDays.containsObject(everyFri)){
                        repeatDays.addObject(everyFri)
                    }
                    
                    
                case 6:
                    let everySat = EKRecurrenceDayOfWeek(.Saturday)
                    if(!repeatDays.containsObject(everySat))
                    {
                        repeatDays.addObject(everySat)
                    }
                    
                case 7:
                    let everySun = EKRecurrenceDayOfWeek(.Sunday)
                    if(!repeatDays.containsObject(everySun))
                    {
                        repeatDays.addObject(everySun)
                    }
                    
                default:
                    break;
                }
                
                
            }
            
            ruleToEvent = EKRecurrenceRule(
                recurrenceWithFrequency:.Weekly,
                interval:1,
                daysOfTheWeek:repeatDays as! [EKRecurrenceDayOfWeek] ,
                daysOfTheMonth:nil,
                monthsOfTheYear:nil,
                weeksOfTheYear:nil,
                daysOfTheYear:nil,
                setPositions: nil,
                end:nil)
            
        }else{
            if(isEdit){
                if(editedEvent.hasRecurrenceRules && editedEvent.recurrenceRules?.count > 0){
                    ruleToEvent = editedEvent.recurrenceRules![0]
                }
            }
        }
        
        return ruleToEvent

    }

    func cancel(){
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: TextField
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.view.addGestureRecognizer(self.textOutsideTap)
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    // MARK: view Touches
    
    
    func handletextOutsideMainTap(sender: UITapGestureRecognizer)
    {
        self.view.endEditing(true)
        self.view.removeGestureRecognizer(self.textOutsideTap)
    }
    
    // MARK: - SetUps

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
    func setUp(){
        familyMembers = ["Member 1","Member 2","Member 3","Member 4"]

        
        viewbadgeNote.layer.cornerRadius    =  viewbadgeNote.frame.size.width/2
        viewbadgeNote.layer.masksToBounds   =  true
        
        self.textOutsideTap = UITapGestureRecognizer(target: self, action: #selector(CreateEventVC.handletextOutsideMainTap(_:)))
        self.textOutsideTap.delegate = self
        
        let dateFormatterDate = NSDateFormatter()
        dateFormatterDate.dateStyle = NSDateFormatterStyle.FullStyle
        dateFormatterDate.timeStyle = NSDateFormatterStyle.NoStyle
        
        let dateFormatterTime = NSDateFormatter()
        dateFormatterTime.dateStyle = NSDateFormatterStyle.NoStyle
        dateFormatterTime.timeStyle = NSDateFormatterStyle.ShortStyle
        
        let dateFormatterDateTime = NSDateFormatter()
        dateFormatterDateTime.dateStyle = NSDateFormatterStyle.FullStyle
        dateFormatterDateTime.timeStyle = NSDateFormatterStyle.ShortStyle

        
        
        if(isEdit == true){
            
            self.title = "Edit Event"
                
            viewDelete.hidden = false
            if(editedEvent.URL != nil){
                let string = "\(editedEvent.URL!)"
            }
            
            if(editedEvent.hasNotes){
                strNotes = editedEvent.notes!
              }
            
            txtTitle.text = editedEvent.title
            
            previousTitle = editedEvent.title
            if let str = editedEvent.location{
                strLoc = editedEvent.location
            }
            
            txtLocation.text = strLoc

            if let arrAlarm = editedEvent.alarms?.first{
                isAlrmOn  = true
                offsetAlarm = 600
                lblReminders.text = "10 minutes before"
            }else{
                isAlrmOn = false
                offsetAlarm = 0
                lblReminders.text = "Set Reminder"
            }
            
            evnetEndDate = editedEvent.endDate
            eventStartDate = editedEvent.startDate
            
            var strU = ""
            if(editedEvent.URL != nil){
                strU = "\(editedEvent.URL!)"
            }
            
            self.setRepeatLabel()
            
            self.getEventTask(strU)
            self.getEventAttendees(strU)
            self.getEventDocs(strU)
            
        }else{
            
            self.title = "Create Event"

            viewDelete.hidden = true
            
            strNotes = ""
            strLoc = ""
            
            isWeekly = false
            isDays = false
            isMonthly = false
            
            //SetUp screen
            isRecurrenceSelected = false
            
            if(isFromCallib){
                eventStartDate = calLibStartDate
                evnetEndDate = eventStartDate.dateByAddingTimeInterval(3600)
            }else{
                eventStartDate = NSDate()
                evnetEndDate = NSDate()
            }
            

            self.txtTitle.becomeFirstResponder()
           
            for name in familyMembers {
                arrPeople.addObject(name)
            }
            collectPeople.reloadData()
        }
        
        isStartime = true
        
        if(isEdit == true ){
            
            lastStartDateStr = dateFormatterDateTime.stringFromDate(editedEvent.startDate)
            lastEndDateStr = dateFormatterDateTime.stringFromDate(editedEvent.endDate)
            lastStartDate = editedEvent.startDate
            lastEndDate = editedEvent.endDate
            
        }else{
            
            if(isFromCallib){
                
                lastStartDateStr = dateFormatterDateTime.stringFromDate(eventStartDate)
                lastEndDateStr = dateFormatterDateTime.stringFromDate(evnetEndDate)
                lastStartDate = eventStartDate
                lastEndDate = evnetEndDate
            }else{
                lastStartDateStr = "Select Start Date and Time"
                lastEndDateStr = "Select End Date and Time"

            }
            
            }
        
        lblStartDate.text = lastStartDateStr
        lblEndDate.text = lastEndDateStr

    }
    
    
    // MARK: - EditEvent
    
    
    func getEventAttendees(strEvent:String)
    {
        
        arrPeople = NSMutableArray()
        //get attendees
        let query: PFQuery = PFQuery(className:"Peoples")
        // query.whereKey("eventId", equalTo: strEvent)
        query.whereKey("eventUnique", equalTo: strEvent)
        
        
        query.findObjectsInBackgroundWithBlock{(objects: [PFObject]?, error: NSError?) -> Void in
            SVProgressHUD.dismiss()
            if error == nil
            {
                for object: PFObject in objects!{
                    if(!self.arrPeople.containsObject(object.objectForKey("Name") as! String)){
                        self.arrPeople.addObject(object.objectForKey("Name") as! String)
                    }
                    
                }
                
            }
            else
            {
                NSLog("%@", error!.description)
            }
            
            self.collectPeople.reloadData()
        }
        
    }
    
    func getEventTask(strEvent:String)
    {
        SVProgressHUD.show()
        
        arrTasklist  = NSMutableArray()
        let queryTask: PFQuery = PFQuery(className:"Tasks")
        queryTask.whereKey("eventUnique", equalTo: strEvent)
        
        queryTask.findObjectsInBackgroundWithBlock{(objects: [PFObject]?, error: NSError?) -> Void in
            SVProgressHUD.dismiss()
            if error == nil
            {
                for object: PFObject in objects!
                {
                    
                    if(!self.arrTasklist.containsObject(object.valueForKey("Name") as! String)){
                        self.arrTasklist.addObject(object.valueForKey("Name") as! String)
                    }
                    
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.lblTaskCounter.text = "\( self.arrTasklist.count)"
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
        self.arrDocs = NSMutableArray()
        
        let queryDoc: PFQuery = PFQuery(className:"Docs")
        
        queryDoc.whereKey("eventUnique", equalTo: strEvent)
        
        queryDoc.findObjectsInBackgroundWithBlock{(objects: [PFObject]?, error: NSError?) -> Void in
            SVProgressHUD.dismiss()
            if error == nil{
                
                for object: PFObject in objects!{
                    
                    let url = object.valueForKey("Name") as! String
                    if(!self.arrDocs.containsObject(url)){
                        self.arrDocs.addObject(url)
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.lblDocCounter.text = "\( self.arrDocs.count)"
                }
            }
            else
            {
                NSLog("%@", error!.description)
            }
        }
    }
    
    func setRepeatLabel(){
        
        let rruleRegex = "RRULE .*"
        var recurrenceRuleString = ""
        
        if let recurrenceRule = editedEvent.recurrenceRules?.first {
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
        
                    self.arrDaysRec = NSMutableArray()
                    recurrenceRuleString = "repeats every week on "
                    
                    let arrDays:[String] = strRuleDays.componentsSeparatedByString(",")
        
                    if(arrDays.count > 0){
                        for i in 0 ..< arrDays.count {
                            
                            switch (arrDays[i]){
                            case "MO":
                                recurrenceRuleString =  recurrenceRuleString.stringByAppendingString("Monday,")
                                
                                if(!self.arrDaysRec.containsObject(1)){
                                    self.arrDaysRec.addObject(1)
                                }
                            case "TU":
                                recurrenceRuleString =  recurrenceRuleString.stringByAppendingString("Tuesday,")
                                
                                if(!self.arrDaysRec.containsObject(2)){
                                    self.arrDaysRec.addObject(2)
                                }
                                
                            case "WE":
                                recurrenceRuleString = recurrenceRuleString.stringByAppendingString("Wednesday,")
                                
                                if(!self.arrDaysRec.containsObject(3)){
                                    self.arrDaysRec.addObject(3)
                                }
                                
                            case "TH":
                                recurrenceRuleString = recurrenceRuleString.stringByAppendingString("Thursday,")
                                
                                if(!self.arrDaysRec.containsObject(4)){
                                    self.arrDaysRec.addObject(4)
                                }
                                
                                
                            case "FR":
                                recurrenceRuleString =  recurrenceRuleString.stringByAppendingString("Friday,")
                                
                                if(!self.arrDaysRec.containsObject(5)){
                                    self.arrDaysRec.addObject(5)
                                }
                                
                                
                            case "SA":
                                recurrenceRuleString = recurrenceRuleString.stringByAppendingString("Saturday,")
                                
                                if(!self.arrDaysRec.containsObject(6)){
                                    self.arrDaysRec.addObject(6)
                                }
                                
                                
                            case "SU":
                                recurrenceRuleString = recurrenceRuleString.stringByAppendingString("Sunday,")
                                
                                if(!self.arrDaysRec.containsObject(7)){
                                    self.arrDaysRec.addObject(7)
                                }
                                
                                
                            default:
                                break;
                            }
                            
                            
                        }
                        
                        recurrenceRuleString = recurrenceRuleString.substringToIndex(recurrenceRuleString.endIndex.predecessor())
                        
                    }else{
                        recurrenceRuleString = "repeats every week"
                    }
                    
                    lblRepeat.text = recurrenceRuleString

                   
                }
                
                
            }
        }else{
            lblRepeat.text = "No Repeat"
        }
        
        
        

        
    }
    
    
    // MARK: - OutletAction
    
    @IBAction func btnRepeatAction(sender: UIButton) {
        let sb = UIStoryboard(name: "Calender_v2", bundle: nil)
        let vc = sb.instantiateViewControllerWithIdentifier("RecurrenceVC") as! RecurrenceVC
        vc.arrDays = arrDaysRec
        vc.delegate = self
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnReminderAction(sender: UIButton) {
        let sb = UIStoryboard(name: "Calender_v2", bundle: nil)
        let vc = sb.instantiateViewControllerWithIdentifier("ReminderSelcectionVC") as! ReminderSelcectionVC
        vc.delegate = self
        vc.isAlrmOn = self.isAlrmOn
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnPeopleAction(sender: UIButton) {
        
        let sb = UIStoryboard(name: "Calender_v2", bundle: nil)
        let vc = sb.instantiateViewControllerWithIdentifier("AddPeopleVC") as! AddPeopleVC
        
        vc.selectedMembers = self.arrPeople
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func btnTaskAction(sender: UIButton) {
        
        let sb = UIStoryboard(name: "Calender_v2", bundle: nil)
        let vc = sb.instantiateViewControllerWithIdentifier("AddTaskVC") as! AddTaskVC
        vc.arrTask = arrTasklist
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func btnDocumentAction(sender: UIButton) {
      
        
        let sb = UIStoryboard(name: "Calender_v2", bundle: nil)
        let vc = sb.instantiateViewControllerWithIdentifier("AddDocVc") as! AddDocVc
        vc.arrLst = arrDocs
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnNotesAction(sender: UIButton) {
        
        let sb = UIStoryboard(name: "Calender_v2", bundle: nil)
        let vc = sb.instantiateViewControllerWithIdentifier("AddNoteVc") as! AddNoteVc
        vc.strNoteslst = strNotes
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func btnDeleteEventAction(sender: UIButton) {
        
        let event = eventStore.eventWithIdentifier(self.editedEvent.eventIdentifier)
        if (event != nil){
            if let recurrenceRule = event!.recurrenceRules?.first {
                self.openActionSheet(event!)
            }else{
                self.deleteNormalEvent(event!)
            }
            
        }
    }
    // MARK: - Reccurence
    func setRecurrence(isWeekly:Bool,is4Week:Bool,isDay:Bool, arrDay:NSMutableArray)
    {
        var strRecurrence = ""
        if((isWeekly == true)||(is4Week == true)||(isDay == true)){
            isRecurrenceSelected = true
        }else{
            isRecurrenceSelected = false
            strRecurrence = "No Repeat"
        }
        
        self.isMonthly = is4Week
        self.isDays = isDay
        self.isWeekly = isWeekly
        self.arrDaysRec = arrDay
        
        if( self.isMonthly){
           strRecurrence = "repeats monthly"
        }else if(self.isWeekly){
            strRecurrence = "repeats weekly"
        }else{
            
            if(self.arrDaysRec.count > 0){
                let strArr = NSMutableArray()
                for i in 0 ..< self.arrDaysRec.count{
                    strArr.addObject(self.getDayStringFromIndex(self.arrDaysRec.objectAtIndex(i) as! Int))
                }
                
                let str = strArr.componentsJoinedByString(",")
                
                strRecurrence = String(format: "repeats every week on %@", str)
            }
            
        }
        
        lblRepeat.text = strRecurrence
    }
    
    func getDayStringFromIndex(value:Int)-> String{
        
        var strDay = ""
        switch (value) {
        case 1:
            strDay = "Monday"
            break;
        case 2:
            strDay = "Tuesday"
            break;
        case 3:
            strDay = "Wednesday"
            break;
        case 4:
            strDay = "Thursday"
            break;
        case 5:
            strDay = "Friday"
            break;
        case 6:
            strDay = "Saturday"
            break;
            
        default:
            strDay = "Sunday"
            break;
        }
        
        return strDay
    }
    
    // MARK: - Reminder
    func setRemindervalue(isReminder: Bool)
    {
        if(isReminder == true){
            offsetAlarm = 600
            lblReminders.text = "10 minutes before"
        }else{
            offsetAlarm = 0
            lblReminders.text = "No Alarm"
        }
    }
    
    
    // MARK: - Note
    func setAddednote(strNote: String) {
        strNotes = strNote
    }

    
    // MARK: - Task
    func setAddedTask(addTasks: NSMutableArray) {
        arrTasklist = addTasks
        self.lblTaskCounter.text = String(format: "%d", self.arrTasklist.count)
    }
    
    
    // MARK: - Doc

    
    func setAddedDoc(addDocs:NSMutableArray){
        arrDocs = addDocs
        self.lblDocCounter.text = String(format: "%d", self.arrDocs.count)
    }

   
    
    // MARK: - People

    func setSelectedPeople(selectedPeople:NSMutableArray,selectedIndexs:NSMutableArray){
        self.arrPeople = NSMutableArray()
        self.arrPeople = selectedPeople
        self.collectPeople.reloadData()
    }

    
    // MARK: - CollectionView

    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrPeople.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let aCell : peopleCell = collectionView.dequeueReusableCellWithReuseIdentifier("peopleCell", forIndexPath: indexPath) as! peopleCell
        if(arrPeople.count > 0){
            
            aCell.lblPeople.text = familyMembers[indexPath.row] as? String
            
            if(arrPeople.containsObject(familyMembers[indexPath.row ])){
                aCell.imgPeople.layer.borderWidth = 4
                aCell.imgPeople.layer.borderColor =  UIColor.blueColor().CGColor
            }else{
                aCell.imgPeople.layer.borderWidth = 0
                aCell.imgPeople.layer.borderColor =  UIColor.clearColor().CGColor
            }
                
        }
        
        aCell.setNeedsUpdateConstraints()
        aCell.layoutIfNeeded()
        aCell.contentView.frame = aCell.bounds
        aCell.contentView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
    
        return aCell
    }


    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        

        let aCell = collectionView.cellForItemAtIndexPath(indexPath) as! peopleCell

    
            if(!arrPeople.containsObject(self.familyMembers[indexPath.row ])){
                arrPeople.addObject(self.familyMembers[indexPath.row])
                aCell.imgPeople.layer.borderWidth = 4
                aCell.imgPeople.layer.borderColor =  UIColor.blueColor().CGColor
            }else{
                arrPeople.removeObject(self.familyMembers[indexPath.row])
                aCell.imgPeople.layer.borderWidth = 0
                aCell.imgPeople.layer.borderColor =  UIColor.clearColor().CGColor
            }
    
        
    }
    
    // MARK: - TimeSelection
    
    
    @IBAction func btnStartTimeAction(sender: UIButton) {
        
        self.viewLayer.hidden = false
        self.viewPopup.hidden = false
        isStartime = true
        
        self.view.endEditing(true)
        
        if(isStartime == true){
            lblHeader.text = "Select Start Date and Time "
        }else{
            lblHeader.text = "Select End Date and Time"
        }
        
        lblStartDate.text = "Select Start Date and Time"
        lblEndDate.text = "Select End Date and Time"
        pickerDateTime.datePickerMode = .DateAndTime
        if((lastStartDate) != nil){
            pickerDateTime.setDate(lastStartDate, animated: true)
        }
        
        let calendar = NSCalendar.currentCalendar()
        let comps = NSDateComponents()
        comps.day = -14
        
        pickerDateTime.minimumDate = calendar.dateByAddingComponents(comps, toDate: NSDate(), options: [])!
        
    }
    
    
    @IBAction func btnEndTimeAction(sender: UIButton) {
        
        isStartime = false
        
        let newDFormatter = NSDateFormatter()
        newDFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        if(lastStartDateStr == "Select Start Date and Time"){
           // self.presentOneTimeAlert(title: "Error", message: "Please select start date and time first")
            return
        }
        
        if(isStartime == false){
            lblHeader.text = "Select End Date and Time"
        }
        
        if((lastStartDate) != nil){
            pickerDateTime.setDate(lastStartDate.dateByAddingTimeInterval(3600), animated: true)
        }
        
        let calendar = NSCalendar.currentCalendar()
        let comps = NSDateComponents()
        comps.day = -14
        
       // pickerDateTime.minimumDate = calendar.dateByAddingComponents(comps, toDate: NSDate(), options: [])!


        self.viewLayer.hidden = false
        self.viewPopup.hidden = false
        
    }

    

    @IBAction func btnTimeDoneAction(sender: UIButton) {
        
        self.viewLayer.hidden = true
        self.viewPopup.hidden = true
        
        let dateFormatter = NSDateFormatter()
        
            dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
            if(isStartime == true){
                
                lastStartDate = pickerDateTime.date
                lastStartDateStr = dateFormatter.stringFromDate(pickerDateTime.date)
                lblStartDate.text = dateFormatter.stringFromDate(pickerDateTime.date)
                lastEndDate = pickerDateTime.date.dateByAddingTimeInterval(3600)
                
                lblEndDate.text = dateFormatter.stringFromDate(lastEndDate)

                lastEndDateStr = dateFormatter.stringFromDate(pickerDateTime.date.dateByAddingTimeInterval(3600))
               
            }
            else{
                
                lastEndDate = pickerDateTime.date
                lastEndDateStr = dateFormatter.stringFromDate(pickerDateTime.date)
                lblEndDate.text = dateFormatter.stringFromDate(pickerDateTime.date)
            }
            
            
        
    }
    
    @IBAction func btnCancelTimeAction(sender: UIButton) {
        
        self.viewLayer.hidden = true
        self.viewPopup.hidden = true
        
        lblEndDate.text = lastEndDateStr
        lblStartDate.text = lastStartDateStr
    }
    

   
    
    func checkCalNotificationsPermission(key:String)->Bool
    {
        if(NSUserDefaults.standardUserDefaults().boolForKey(key) == true){
            return false
        }else{
            return true
        }
    }
    
    // MARK: - Parse
    
    
    
    
    func combineDateAndTime(date1:NSDate,date2:NSDate)->NSDate
    {
        
        let gregorianCalendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        // Extract date components into components1
        let components1: NSDateComponents = gregorianCalendar.components([.Year, .Month, .Day], fromDate: date1)
        // Extract time components into components2
        let components2: NSDateComponents = gregorianCalendar.components([.Hour, .Minute, .Second], fromDate: date2)
        // Combine date and time into components3
        let components3: NSDateComponents = NSDateComponents()
        components3.year = components1.year
        components3.month = components1.month
        components3.day = components1.day
        components3.hour = components2.hour
        components3.minute = components2.minute
        components3.second = components2.second
        // Generate a new NSDate from components3.
        let combinedDate: NSDate = gregorianCalendar.dateFromComponents(components3)!
        
        return combinedDate
        
    }
    
    func addEventOnDay(strTitle:String, start:NSDate, end:NSDate,strLoc:String,strNotes:String,strUrl:NSURL,arrAlarm:[EKAlarm]){
        
        
        do{
                var newEvent:EKEvent!
                newEvent = EKEvent(eventStore: eventStore)
                newEvent.calendar = newCalendar
                newEvent.title = strTitle
                newEvent.URL = strUrl

//                newEvent.startDate = self.combineDateAndTime(NSDate(), date2:start)
//                newEvent.endDate = self.combineDateAndTime(NSDate(), date2: end)
                
                newEvent.startDate = start
                newEvent.endDate = end
                newEvent.location = strLoc
                newEvent.timeZone = NSTimeZone.localTimeZone()
                newEvent.notes = strNotes
                newEvent.alarms = arrAlarm
                try eventStore.saveEvent(newEvent, span: .ThisEvent, commit: true)
            
                if(isEdit == true){
                    delegate.isSavedEvent = true
                   // self.postCalendaEventWithAttendees(newEvent, action: "edit",arrAttendees: arrAttendees,familyMembers:self.familyMembers)
                }else{
                   // self.postCalendaEventWithAttendees(newEvent, action: "add",arrAttendees: arrAttendees,familyMembers:self.familyMembers)
                }
            
            self.saveOnParse(newEvent)

            
        }catch{
            print((error as NSError).localizedDescription)
        }

    }
    
    
    
    func generateUniqueId(strTitle:String,startDate:NSDate) -> String{
        
        var strUnique:String!
        
        let user = PFUser.currentUser()
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'TIME'HH:mm:ss.SSS"
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let dateAndTime = formatter.stringFromDate(NSDate())
        
        let strU = String(format: "%@_%@_%@", strTitle,dateAndTime,"MF")
        
        strUnique = strU.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        return strUnique
    }
    
    
    // MARK: - EKEVENT

    
    
    
    func openActionSheet(eventDe:EKEvent)
    {
        let optionMenu = UIAlertController(title: nil, message: "This is a repeating event.", preferredStyle: .ActionSheet)
        
        let CameraAction = UIAlertAction(title: "Delete this event only", style: .Default, handler:
            {
                (alert: UIAlertAction!) -> Void in
                
                self.deleteNormalEvent(eventDe)
        })
        
        let GalleryAction = UIAlertAction(title: "Delete all events", style: .Default, handler:
            {
                (alert: UIAlertAction!) -> Void in
                
                self.deleteEventFuture(eventDe)
        })
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        
        optionMenu.addAction(CameraAction)
        optionMenu.addAction(GalleryAction)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
    }
    
    
    func openActionSheetSave(eventSave:EKEvent)
    {
        let optionMenu = UIAlertController(title: nil, message: "This is a repeating event.", preferredStyle: .ActionSheet)
        
        let action1 = UIAlertAction(title: "More options", style: .Default, handler:
        {
                (alert: UIAlertAction!) -> Void in
                self.openAlertSaveOnly(eventSave)
        })
        
        let action2 = UIAlertAction(title: "Save for all events", style: .Default, handler:
        {
                (alert: UIAlertAction!) -> Void in
                self.isSaveOnly = false
                self.saveEventFuture(eventSave)
        })
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        
        optionMenu.addAction(action1)
        optionMenu.addAction(action2)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
    }
    
    func openAlertSaveOnly(eventSave:EKEvent)
    {
        let optionMenu = UIAlertController(title: "Save for this event only", message: "Warning, You will create a single event without connections to the previous repeated events.\nStill want to save?", preferredStyle: .Alert)
        
        let action1 = UIAlertAction(title: "Yes", style: .Default, handler:
            {
                (alert: UIAlertAction!) -> Void in
                
                self.isSaveOnly = true
                self.saveNormalEvent(eventSave)
        })
        

        let cancelAction = UIAlertAction(title: "No", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        
        optionMenu.addAction(action1)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
    }
    
    func duplicateSaveAll(eventNew:EKEvent)-> EKEvent{
        
        let eventFirst = eventStore.eventWithIdentifier(self.editedEvent.eventIdentifier)
        
        eventNew.startDate = self.combineDateAndTime((eventFirst?.startDate)!, date2: self.eventStartDate)
        eventNew.endDate = self.combineDateAndTime((eventFirst?.endDate)!, date2: self.evnetEndDate)
        return eventNew
        
    }
    
    
    func saveOnParse(event:EKEvent){
        

        NSUserDefaults.standardUserDefaults().setObject(event.eventIdentifier, forKey: "eventId")
        NSUserDefaults.standardUserDefaults().synchronize()
        /// add entry to new table
        if(self.arrTasklist.count > 0)
        {
            for i in 0 ..< self.arrTasklist.count {
                self.taskObjects.append(self.createTaskPFObject(self.arrTasklist[i] as! String,eventUnique:"\(event.URL!)"))
            }
        }
        self.deleteOldTaskbeforSave("\(event.URL!)", objTasks: self.taskObjects)
        
        
        
        if(self.arrDocs.count > 0){
            for i in 0 ..< self.arrDocs.count {
                self.docObjects.append(self.createDocPFObject(self.arrDocs[i] as! String,eventUnique:"\(event.URL!)"))
            }
        }
        
        self.deleteOldDocsbeforSave("\(event.URL!)", objTasks: self.docObjects)

        
        if(self.arrPeople.count > 0){
            for i in 0 ..< self.arrPeople.count {
                self.arrInvitees.append(self.createPeoplePFObject(self.arrPeople[i] as! String,eventUnique:"\(event.URL!)"))
            }
        }
        
        
        self.deleteOldPeolpesbeforSave("\(event.URL!)", objTasks: self.arrInvitees)


    }
    
    
    
   
    
    
    func deleteOldPeolpesbeforSave(strUnique:String,objTasks:[PFObject]){
        let query: PFQuery = PFQuery(className: "Peoples")
        
        query.whereKey("eventUnique", equalTo: strUnique)
        
        query.findObjectsInBackgroundWithBlock{(objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil{
                
                PFObject.deleteAllInBackground(objects, block: { (success:Bool, error:NSError?) in
                    if(success){
                        if(self.arrInvitees.count > 0){
                            PFObject.saveAllInBackground(self.arrInvitees).continueWithBlock { task in
                                
                                if let resultList = task.result {
                                }
                                return task
                            }
                        }
                    }else{
                        print("error -\(error?.localizedDescription)")
                    }
                    
                })
                
            }
        }
    }
    
    
    func deleteOldTaskbeforSave(strUnique:String,objTasks:[PFObject]){
        let query: PFQuery = PFQuery(className: "Tasks")
        
        query.whereKey("eventUnique", equalTo: strUnique)
        
        query.findObjectsInBackgroundWithBlock{(objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil{
                
                PFObject.deleteAllInBackground(objects, block: { (success:Bool, error:NSError?) in
                    if(success){
                        if(self.taskObjects.count > 0){
                            PFObject.saveAllInBackground(self.taskObjects).continueWithBlock { task in
                                
                                if let resultList = task.result {
                                }
                                return task
                            }
                        }
                    }else{
                        print("error -\(error?.localizedDescription)")
                    }
                    
                })
                
            }
        }
    }
    
    func deleteOldDocsbeforSave(strUnique:String,objTasks:[PFObject]){
        let query: PFQuery = PFQuery(className: "Docs")
        
        query.whereKey("eventUnique", equalTo: strUnique)
        
        query.findObjectsInBackgroundWithBlock{(objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil{
                
                PFObject.deleteAllInBackground(objects, block: { (success:Bool, error:NSError?) in
                    if(success){
                        print("deleted old tasks")
                        if(self.docObjects.count > 0){
                            PFObject.saveAllInBackground(self.docObjects).continueWithBlock { task in
                                
                                if let resultList = task.result {
                                    print(resultList)
                                }
                                return task
                            }
                        }
                    }else{
                        print("error -\(error?.localizedDescription)")
                    }
                    
                })
                
            }
        }
    }
    
    
    
    
    
    func createTaskPFObject(strTask:String!,eventUnique:String) -> PFObject{
        let list = PFObject(className: "Tasks")
        
        list["eventUnique"]     = eventUnique
        list["Name"]     = strTask
        
        return list
        
    }
    
    func createDocPFObject(strDoc:String!,eventUnique:String) -> PFObject{
        let Doc = PFObject(className: "Docs")
        
        Doc["eventUnique"]     = eventUnique
        Doc["Name"]     = strDoc
        
        return Doc
        
    }
    
    func createPeoplePFObject(strPeole:String!,eventUnique:String) -> PFObject{
        let people = PFObject(className: "Peoples")
        
        people["eventUnique"]     = eventUnique
        people["Name"]     = strPeole
        
        return people
        
    }

    
    func saveEventFuture(eventSave:EKEvent){
     
        do{
            
            let eventoSave = self.duplicateSaveAll(eventSave)
            try eventStore.saveEvent(eventoSave, span: .FutureEvents, commit: true)
            
            
            if(isEdit == true){
                delegate.isSavedEvent = true
           
                
            }else{
               // self.postCalendaEventWithAttendees(eventoSave, action: "add",arrAttendees: arrAttendees,familyMembers:self.familyMembers)
            }
            
            self.saveOnParse(eventSave)

            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            
        }catch{
            print((error as NSError).localizedDescription)
            
            let alert = UIAlertController(title: "Event could not save", message: (error as NSError).localizedDescription, preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(OKAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
        }

    }
    
    func deletethisSpanEvent(eventDe:EKEvent){
        do{
            try eventStore.removeEvent(eventDe, span: .ThisEvent, commit: true)
        }catch{
            print((error as NSError).localizedDescription)
        }
    }
    
    func saveNormalEvent(eventSave:EKEvent){
       
        eventSave.startDate = eventStartDate
        eventSave.endDate = evnetEndDate

        
        do{
              if(isSaveOnly && isEdit){
                
                self.deleteEventRecurSameDay(eventSave).continueWithBlock { task in
                    return task
                }
                
                var evToPassloc:String!
                if((eventSave.location) != nil){
                    evToPassloc  = eventSave.location
                }else{
                    evToPassloc  = ""
                }
                let evToPassTitle = eventSave.title
                let evToPassStart = eventSave.startDate
                let evToPassEnd = eventSave.endDate
                
                var evToPassnotes:String!
                if((eventSave.notes) != nil){
                    evToPassnotes  = eventSave.notes
                }else{
                    evToPassnotes  = ""
                }
                
                var evToAlarms:[EKAlarm]
                if(eventSave.hasAlarms && eventSave.alarms?.count > 0){
                    let alarm:EKAlarm = EKAlarm(relativeOffset: -600)
                    evToAlarms = [alarm]
                }else{
                    evToAlarms =  [EKAlarm]()
                }
                

             
                let eventU = self.generateUniqueId(self.txtTitle.text!, startDate: self.eventStartDate)
                let urlU = NSURL(string:eventU)
                //eventSave.URL = urlU
                
                let evToPassUrl  = urlU
                
                self.addEventOnDay(evToPassTitle, start: evToPassStart, end: evToPassEnd, strLoc: evToPassloc, strNotes: evToPassnotes, strUrl: evToPassUrl!, arrAlarm: evToAlarms)
                
                
            }else{
                
                //this line deletes removes today 's event
                try eventStore.saveEvent(eventSave, span: .ThisEvent, commit: true)
  
                
                
                if(isEdit == true){
                    delegate.isSavedEvent = true
                   // self.postCalendaEventWithAttendees(eventSave, action: "edit",arrAttendees: arrAttendees,familyMembers:self.familyMembers)
                }else{
                    //self.postCalendaEventWithAttendees(eventSave, action: "add",arrAttendees: arrAttendees,familyMembers:self.familyMembers)
                }
                
                self.saveOnParse(eventSave)

            }
            
           

            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            
        }catch{
            print((error as NSError).localizedDescription)
            
            let alert = UIAlertController(title: "Event could not save", message: (error as NSError).localizedDescription, preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(OKAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    func deleteEventFuture(eventDel:EKEvent)
    {
        do{
            let externalId = eventDel.calendarItemExternalIdentifier
            
            
            try eventStore.removeEvent(eventDel, span: .FutureEvents, commit: true)
            delegate.isSavedEvent = true
            
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        }
        catch
        {
            print((error as NSError).localizedDescription)
            
            let alert = UIAlertController(title: "Event could not be deleted", message: (error as NSError).localizedDescription, preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(OKAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func deleteNormalEvent(eventDe:EKEvent){
        
        let externalId = eventDe.calendarItemExternalIdentifier

        if let recurrenceRule = eventDe.recurrenceRules?.first {
            delegate.isSavedEvent = true
           
            self.deleteEventOnly(eventDe)

            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)

        }else{
            
            do{
                try eventStore.removeEvent(eventDe, span: .ThisEvent, commit: true)
                delegate.isSavedEvent = true
               
                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                
            }
            catch
            {
                print((error as NSError).localizedDescription)
                
                let alert = UIAlertController(title: "Event could not be deleted", message: (error as NSError).localizedDescription, preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(OKAction)
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        
        
    }
    
    
    func deleteEventRecurSameDay(evRecure:EKEvent)->BFTask{
        
        let stDate = evRecure.startDate.dateByAddingTimeInterval(-60*60*24)
        let enDate = stDate.dateByAddingTimeInterval(60*60*24*2)
        
        func checkingEvents(events: [EKEvent]) -> BFTask{
            
            let completion = BFTaskCompletionSource()
            
            let valueEvent:Bool = false
            
            for event in events{
                if(event.URL != nil && event.URL!.absoluteString == oldUniquestr){
                    self.deletethisSpanEvent(event)
                }
            }
            
            completion.setResult(valueEvent)
            return completion.task
        }
        
        
        return self.fetchallEventsFrom(fromDate: stDate, toDate: enDate).continueWithBlock { task in
            
            if task.result != nil{
                let familyEvents = task.result as! [EKEvent]
                return checkingEvents(familyEvents)
            }
            return task
        }
    }
    
    func deleteEventOnly(evRecure:EKEvent)->BFTask{
        
        let stDate = eventStartDate
        let enDate = evnetEndDate
        
        func checkingEvents(events: [EKEvent]) -> BFTask{
            
            let completion = BFTaskCompletionSource()
            
            let valueEvent:Bool = false
            
            for event in events{
                if(event.URL != nil && event.URL?.absoluteString == evRecure.URL?.absoluteString){
                    self.deletethisSpanEvent(event)
                }
            }
            
            completion.setResult(valueEvent)
            return completion.task
        }
        
        
        return self.fetchallEventsFrom(fromDate: stDate, toDate: enDate).continueWithBlock { task in
            
            if task.result != nil{
                let familyEvents = task.result as! [EKEvent]
                return checkingEvents(familyEvents)
            }
            return task
        }
    }
    
    
    func checkEventIsAlreadyThereOrNot(evRecureUrl:NSURL)->BFTask{
        
        let stDate = NSDate()
        let enDate = stDate.dateByAddingTimeInterval(60*60*24*1)
        
        func checkingEvents(events: [EKEvent]) -> BFTask{
            
            let completion = BFTaskCompletionSource()
            
            var valueEvent:Bool = false
            
            for event in events{
                
                if(event.URL != nil && event.URL!.absoluteString == evRecureUrl.absoluteString){
                    valueEvent = true
                    break
                }
            }
            
            completion.setResult(valueEvent)
            return completion.task
        }
        
        
        return self.fetchallEventsFrom(fromDate: stDate, toDate: enDate).continueWithBlock { task in
            
            if task.result != nil{
                let familyEvents = task.result as! [EKEvent]
                return checkingEvents(familyEvents)
            }
            return task
        }
    }
    
    
    
    func fetchallEventsFrom(fromDate date: NSDate, toDate: NSDate) -> BFTask {
        let completionSource = BFTaskCompletionSource()
        
        print("fetch events from \(date) to \(toDate)")
        
        let executor = BFExecutor(dispatchQueue: dispatch_get_global_queue(QOS_CLASS_UTILITY, 0))
        let task = BFTask(fromExecutor: executor) { _ in
            
            
            let predicate = self.eventStore.predicateForEventsWithStartDate(date, endDate: toDate, calendars: [self.newCalendar])
            let events = self.eventStore.eventsMatchingPredicate(predicate)
            
            completionSource.setResult(events)
            return completionSource.task
        }
        
        return task
    }
    
    
}
