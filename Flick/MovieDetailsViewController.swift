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
  
  var moviesDetailsImageUrl:NSURL?
  
    override func viewDidLoad() {
        super.viewDidLoad()
        movieDetailsImageView.setImageWithURL(moviesDetailsImageUrl!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
