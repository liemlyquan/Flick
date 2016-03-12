//
//  MovieDetailsViewController.swift
//  Flick
//
//  Created by Liem Ly Quan on 3/11/16.
//  Copyright © 2016 Liem Ly Quan. All rights reserved.
//

import UIKit
import AFNetworking

class MovieDetailsViewController: UIViewController {
  @IBOutlet weak var movieDetailsImageView: UIImageView!
  @IBOutlet weak var metaScrollView: UIScrollView!
  @IBOutlet weak var movieDetailsTitleLabel: UILabel!
  @IBOutlet weak var movieDetailsOverviewLabel: UILabel!
  
  var movieDetailsImageUrl:NSURL?
  var movieDetailsTitleString:String?
  var movieDetailsOverviewString:String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    movieDetailsImageView.setImageWithURL(movieDetailsImageUrl!)
    movieDetailsTitleLabel.text = movieDetailsTitleString!
    movieDetailsOverviewLabel.text = movieDetailsOverviewString!
    movieDetailsOverviewLabel.sizeToFit()

    let contentWidth = metaScrollView.bounds.width
    let contentHeight = metaScrollView.bounds.height * 1.25
    metaScrollView.contentSize = CGSizeMake(contentWidth, contentHeight)
  
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
}
