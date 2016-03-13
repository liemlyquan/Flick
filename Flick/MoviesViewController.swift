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
import Foundation

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
  @IBOutlet weak var moviesTableView: UITableView!
  @IBOutlet weak var movieSearchBar: UISearchBar!
  @IBOutlet weak var noNetworkConnectionLabel: UILabel!
  var moviesData:[NSDictionary]?
  var haveNetworkConnection:Bool?
  var filteredData = [NSDictionary]()
  var isSearching:Bool = false
  var endpoint = String()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    moviesTableView.dataSource = self
    moviesTableView.delegate = self
    movieSearchBar.delegate = self
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
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let moviesData = moviesData {
      if (isSearching){
        return filteredData.count
      } else {
        return moviesData.count
      }
    } else {
      return 0
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
    let backgroundView = UIView()
    backgroundView.backgroundColor = UIColor.init(red: 0.2, green: 0.7, blue: 0.1, alpha: 0.7)
    cell.selectedBackgroundView = backgroundView
    
    var movie = NSDictionary()
    if (isSearching) {
      movie = filteredData[indexPath.row]
    } else {
      movie = moviesData![indexPath.row]
    }
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
    let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
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
            self.moviesData = responseDictionary["results"] as! [NSDictionary]!
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

    var movie:NSDictionary
    
    if (isSearching) {
      movie = filteredData[indexPath!.row]
    } else {
      movie = moviesData![indexPath!.row]
    }
    
    let title = movie["title"] as! String
    let overview = movie["overview"] as! String
    let posterPath = movie["poster_path"] as! String
    vc.movieDetailsTitleString = title
    vc.movieDetailsOverviewString = overview
    let imageUrl = NSURL(string: baseUrl + posterPath)
    vc.movieDetailsImageUrl = imageUrl
    
  }
  
  func fetchData(){
    EZLoadingActivity.show("Loading", disableUI: true)
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
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
            self.moviesData = responseDictionary["results"] as! [NSDictionary]!
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
  
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText.isEmpty {
      isSearching = false
    } else {
      isSearching = true
      filteredData = moviesData!.filter({(dataItem) -> Bool in
        let tmp:NSDictionary = dataItem
        let range = tmp["title"]!.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
        return range.location != NSNotFound
      })
    }
    moviesTableView.reloadData()
  }
  
  func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    searchBar.text = ""
    searchBar.resignFirstResponder()
  }
  
  
  
}
