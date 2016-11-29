//
//  PeopleSelectionCell.swift
//  Simplify
//
//  Created by Vishal Rana on 6/14/16.
//  Copyright © 2016 2359 Media Pte Ltd. All rights reserved.
//

import UIKit

class PeopleSelectionCell: UITableViewCell {

    @IBOutlet weak var imgPeople: UIImageView!
    
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var btnCheckMark: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
