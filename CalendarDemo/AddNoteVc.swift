//
//  AddNoteVc.swift
//  CalendarDemo
//
//  Created by Vishal Rana on 11/11/16.
//  Copyright © 2016 MobileFirst. All rights reserved.
//

import UIKit

protocol NoteSelector {
    func setAddednote(strNote:String)
}

class AddNoteVc: UIViewController {

    var delegate: NoteSelector?
    var strNoteslst = ""
    @IBOutlet weak var txtNote: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add Note"
        // Do any additional setup after loading the view.
        
      txtNote.text = strNoteslst
        
       let btnSave = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(AddNoteVc.saveNote))
        self.navigationItem.setRightBarButtonItems([btnSave], animated: true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveNote()
    {
       
        delegate?.setAddednote(txtNote.text)
        self.navigationController?.popViewControllerAnimated(true)
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
