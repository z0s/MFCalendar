//
//  ViewController.swift
//  CalendarDemo
//
//  Created by Vishal Rana on 11/11/16.
//  Copyright © 2016 MobileFirst. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI

class ViewController: UIViewController,EKEventEditViewDelegate {

    let eventStore: EKEventStore = EKEventStore()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func viewEventAction(sender: UIButton) {
        
        var eventObj:EKEvent!
        var strId:String = ""
        if(NSUserDefaults.standardUserDefaults().objectForKey("eventId") != nil){
            
            strId = NSUserDefaults.standardUserDefaults().objectForKey("eventId") as! String
            if let eventOb =  eventStore.eventWithIdentifier(strId){
              
                let sb = UIStoryboard(name: "Calender_v2", bundle: nil)
                let navVc = sb.instantiateViewControllerWithIdentifier("ViewEventNav") as! UINavigationController
                let eventViewVc = navVc.topViewController as! ViewEventVc
                eventViewVc.eventView = eventOb
                self.presentViewController(navVc, animated: true, completion: nil)
            }

        }
        

        
        
       

    }

    @IBAction func viewDefaultAction(sender: UIButton) {
        
        
        var eventObj:EKEvent!
        var strId:String = ""
        if(NSUserDefaults.standardUserDefaults().objectForKey("eventId") != nil){
            
            strId = NSUserDefaults.standardUserDefaults().objectForKey("eventId") as! String
            if let eventOb =  eventStore.eventWithIdentifier(strId){
                let editEventViewController = EKEventEditViewController()
                editEventViewController.editViewDelegate = self
                editEventViewController.eventStore = eventStore
                editEventViewController.event = eventOb
                self.presentViewController(editEventViewController, animated: true, completion: nil)
            }
            
        }
        
        
    }
    
    
    func eventEditViewController(controller: EKEventEditViewController, didCompleteWithAction action: EKEventEditViewAction) {
        
        defer {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        guard let editedEvent = controller.event else {
            return
        }
        
        switch action {
        case .Canceled:
//            guard let pendingEventId = self.pendingEventId else { return }
//            
//            if let pendingEvent = self.eventStore.eventWithIdentifier(pendingEventId) {
//                do {
//                    try self.eventStore.removeEvent(pendingEvent, span: .ThisEvent)
//                } catch let error as NSError {
//                    DDLogError("Failed to delete event with identifier \(pendingEventId) error: \(error)")
//                }
//            }
            break
            
        case .Saved:
//            self.postCalendarEditEvent(editedEvent, action: "add")
//            Analytics.sharedInstance.calendar(.Calendar, metaData: ["Calendar Title":editedEvent.title], calendarEvent: .Add)
            break
            
        case .Deleted:
//            self.postCalendarDeleteEvent(editedEvent, eventIdentifier: self.pendingEventId, eventExternalId:"")
            break
        }
    }
    
//    func eventEditViewControllerDefaultCalendarForNewEvents(controller: EKEventEditViewController) -> EKCalendar {
//        return self.familyCalendar
//    }
    @IBAction func createDefaultEvent(sender: UIButton) {
        
        let eventViewController = EKEventEditViewController()
        eventViewController.editViewDelegate = self
        eventViewController.eventStore = self.eventStore
        
        self.presentViewController(eventViewController, animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func createEventAction(sender: UIButton) {
        
        
        let sb = UIStoryboard(name: "Calender_v2", bundle: nil)
        let navVc = sb.instantiateViewControllerWithIdentifier("CreateNav") as! UINavigationController
        let eventViewVc = navVc.topViewController as! CreateEventVC
        eventViewVc.isEdit = false
        eventViewVc.isFromCallib = false
        self.presentViewController(navVc, animated: true, completion: nil)
    }
}

