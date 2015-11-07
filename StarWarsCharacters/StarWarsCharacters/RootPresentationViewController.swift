//
//  RootPresentationViewController.swift
//  StarWarsCharacters
//
//  Created by Heather Connery on 2015-11-07.
//  Copyright © 2015 HConnery. All rights reserved.
//

import UIKit

class RootPresentationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var species:Array<StarWarsSpecies>?
    var speciesWrapper:SpeciesWrapper? // holds the last wrapper that we've loaded
    var isLoadingSpecies = false


    @IBOutlet weak var tableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView?.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0)
        self.loadFirstSpecies()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.species == nil
        {
            return 0
        }
        return self.species!.count
    }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        if self.species != nil && self.species!.count >= indexPath.row
        {
            let species = self.species![indexPath.row]
            cell.textLabel?.text = species.name
            cell.detailTextLabel?.text = species.classification
            
            // See if we need to load more species
            let rowsToLoadFromBottom = 5;
            let rowsLoaded = self.species!.count
            if (!self.isLoadingSpecies && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom)))
            {
                let totalRows = self.speciesWrapper!.count!
                let remainingSpeciesToLoad = totalRows - rowsLoaded;
                if (remainingSpeciesToLoad > 0)
                {
                    self.loadMoreSpecies()
                }
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func loadFirstSpecies()
    {
        isLoadingSpecies = true
        StarWarsSpecies.getSpecies { wrapper, error in
            if let error = error
            {
                // TODO: improved error handling
                self.isLoadingSpecies = false
                let alert = UIAlertController(title: "Error", message: "Could not load first species \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            self.addSpeciesFromWrapper(wrapper)
            self.isLoadingSpecies = false
            self.tableView.reloadData()
        }
    }
    
    func loadMoreSpecies()
    {
        self.isLoadingSpecies = true
        if self.species != nil && self.speciesWrapper != nil && self.species!.count < self.speciesWrapper!.count
        {
            // there are more species out there!
            StarWarsSpecies.getMoreSpecies(self.speciesWrapper, completionHandler: { wrapper, error in
                if let error = error
                {
                    // TODO: improved error handling
                    self.isLoadingSpecies = false
                    let alert = UIAlertController(title: "Error", message: "Could not load more species \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                print("got more!")
                self.addSpeciesFromWrapper(wrapper)
                self.isLoadingSpecies = false
                self.tableView.reloadData()
            })
        }
    }
    
    func addSpeciesFromWrapper(wrapper: SpeciesWrapper?)
    {
        self.speciesWrapper = wrapper
        if self.species == nil
        {
            self.species = self.speciesWrapper?.species
        }
        else if self.speciesWrapper != nil && self.speciesWrapper!.species != nil
        {
            self.species = self.species! + self.speciesWrapper!.species!
        }
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
