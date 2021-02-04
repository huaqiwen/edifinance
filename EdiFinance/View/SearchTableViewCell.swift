//
//  SearchTableViewCell.swift
//  EdiFinance
//
//  Created by Peter Ke on 2018-05-22.
//  Copyright © 2018 QiwenHua. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    var index: Int = -1
    var delegate: SearchTableViewCellDelegate?
    
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBAction func addButtonPressed(_ sender: Any) {
        delegate?.didPressAddButton(index: index)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

protocol SearchTableViewCellDelegate {
    func didPressAddButton(index: Int)
}
