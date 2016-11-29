//
//  docCell.swift
//  CalendarDemo
//
//  Created by Vishal Rana on 11/11/16.
//  Copyright © 2016 MobileFirst. All rights reserved.
//

import UIKit

class docCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var lbl: UILabel!

    @IBOutlet weak var btnCheckMark: UIButton!
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
