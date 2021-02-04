//
//  NewCompactTableViewCell.swift
//  EdiFinance
//
//  Created by Peter Ke on 2018-05-28.
//  Copyright © 2018 QiwenHua. All rights reserved.
//

import UIKit

class NewsCompactTableViewCell: UITableViewCell {

    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
