//
//  NoteCell.swift
//  NoteApp
//
//  Created by 王冠之 on 2020/4/17.
//  Copyright © 2020 Wangkuanchih. All rights reserved.
//

import UIKit

class NoteCell: UITableViewCell {

    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
