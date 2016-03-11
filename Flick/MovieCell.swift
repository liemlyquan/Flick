//
//  MovieCell.swift
//  Flick
//
//  Created by Liem Ly Quan on 3/10/16.
//  Copyright © 2016 Liem Ly Quan. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {
  @IBOutlet weak var movieImageView: UIImageView!
  @IBOutlet weak var movieTitleLabel: UILabel!
  @IBOutlet weak var movieOverviewLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
