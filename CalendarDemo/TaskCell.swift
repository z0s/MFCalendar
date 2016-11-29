//
//  TaskCell.swift
//  Simplify
//
//  Created by Rahul Chandnani on 19/04/16.
//  Copyright © 2016 Mobile First. All rights reserved.
//

import UIKit

class TaskCell: UITableViewCell {
    
    @IBOutlet var btnCheckBox: UIButton!
    
    @IBOutlet var lblTask: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
