//
//  MoviesViewController.swift
//  Flick
//
//  Created by Liem Ly Quan on 3/7/16.
//  Copyright © 2016 Liem Ly Quan. All rights reserved.
//

import UIKit
import AFNetworking
import EZLoadingActivity
import SystemConfiguration


class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  @IBOutlet weak var moviesTableView: UITableView!
  @IBOutlet weak var movieSearchBar: UISearchBar!
  @IBOutlet weak var noNetworkConnectionLabel: UILabel!
  var moviesData:[NSDictionary]?
  var haveNetworkConnection:Bool?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    moviesTableView.dataSource = self
    moviesTableView.delegate = self
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
    moviesTableView.insertSubview(refreshControl, atIndex: 0)
    EZLoadingActivity.Settings.SuccessText = "Done"
    EZLoadingActivity.Settings.FailText = "Error"
    movieSearchBar.sizeToFit()
    navigationItem.titleView = movieSearchBar

    haveNetworkConnection = connectedToNetwork()
    if (haveNetworkConnection! == true){
      fetchData()
    } else {
      self.noNetworkConnectionLabel.layer.zPosition = 1
      // Thanks to AntiStrike12
      // stackoverflow.com/questions/28288476/fade-in-and-fade-out-in-animation-swift
      UIView.animateWithDuration(2, delay: 1, options: UIViewAnimationOptions.CurveEaseOut, animations: {
        self.noNetworkConnectionLabel.alpha = 0.0
        }, completion: nil )
    }
  }
  
  override func viewDidAppear(animated: Bool) {

  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let moviesData = moviesData {
      return moviesData.count
    } else {
      return 0
    }
  }
  
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//    let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath)
    let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
    
    let movie = moviesData![indexPath.row]
    let title = movie["title"] as! String
    let overview = movie["overview"] as! String
    
    let posterPath = movie["poster_path"] as! String
    let baseUrl = "http://image.tmdb.org/t/p/w500"
    let imageUrl = NSURL(string: baseUrl + posterPath)
    cell.movieTitleLabel.text = title
    cell.movieOverviewLabel.text = overview
    cell.movieImageView.setImageWithURL(imageUrl!)
  
    return cell
  }
  
  func refreshControlAction(refreshControl: UIRefreshControl){
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
    let request = NSURLRequest(URL: url!)
    let session = NSURLSession(
      configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
      delegate:nil,
      delegateQueue: NSOperationQueue.mainQueue()
    )
    let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
      completionHandler: { (dataOrNil, response, error) in
        if let data = dataOrNil {
          if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary {
            self.moviesData = responseDictionary["results"] as! [NSDictionary]
            self.moviesTableView.reloadData()
            refreshControl.endRefreshing()
          }
        }
      }
    )
    task.resume()
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let vc = segue.destinationViewController as! MovieDetailsViewController
    let indexPath = moviesTableView.indexPathForCell(sender as! UITableViewCell)
    let baseUrl = "http://image.tmdb.org/t/p/original"

    let movie = moviesData![(indexPath?.row)!]
    let posterPath = movie["poster_path"] as! String
    let imageUrl = NSURL(string: baseUrl + posterPath)
    vc.moviesDetailsImageUrl = imageUrl
    
  }
  
  func fetchData(){
    EZLoadingActivity.show("Loading", disableUI: true)
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
    let request = NSURLRequest(URL: url!)
    let session = NSURLSession(
      configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
      delegate:nil,
      delegateQueue: NSOperationQueue.mainQueue()
    )
    let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
      completionHandler: { (dataOrNil, response, error) in
        if let data = dataOrNil {
          if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary {
            self.moviesData = responseDictionary["results"] as! [NSDictionary]
            self.moviesTableView.reloadData()
            
            EZLoadingActivity.hide(success: true, animated: true)
          }
        } else {
          EZLoadingActivity.hide(success: false, animated: true)
        }
      }
    )
    task.resume()
  }
  
  
  func connectedToNetwork() -> Bool {
    // Thanks to Martin R
    // stackoverflow.com/questions/25623272/how-to-use-scnetworkreachability-in-swift/25623647#25623647
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
      SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
    }) else {
      return false
    }
    
    var flags : SCNetworkReachabilityFlags = []
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
      return false
    }
    
    let isReachable = flags.contains(.Reachable)
    let needsConnection = flags.contains(.ConnectionRequired)
    return (isReachable && !needsConnection)
  }
  
  
  
  
  
  
}
