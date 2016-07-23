//
//  LaunchTableViewCell.swift
//  HoTS
//
//  Created by Joost van den Akker on 26-01-16.
//  Copyright © 2016 JoAk. All rights reserved.
//

import UIKit

class LaunchTableViewCell: UITableViewCell {
    // MARK: Properties
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var vehicleLabel: UILabel!
    @IBOutlet weak var specialLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
