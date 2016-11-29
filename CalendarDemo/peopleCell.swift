//
//  peopleCell.swift
//  Simplify
//
//  Created by Vishal Rana on 9/16/16.
//  Copyright © 2016 2359 Media Pte Ltd. All rights reserved.
//

import UIKit

class peopleCell: UICollectionViewCell {
    
    @IBOutlet weak var imgPeople: UIImageView!
    
    @IBOutlet weak var lblPeople: UILabel!
    
   
    override var bounds : CGRect {
        didSet {
            self.layoutIfNeeded()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.makeItCircle()
    }
    
    func makeItCircle() {
        self.imgPeople.layer.masksToBounds = true
        self.imgPeople.layer.cornerRadius  = CGFloat(roundf(Float(self.imgPeople.frame.size.width/2.0)))
    }
}
