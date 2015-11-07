//
//  SpeciesWrapper.swift
//  StarWarsCharacters
//
//  Created by Heather Connery on 2015-11-07.
//  Copyright © 2015 HConnery. All rights reserved.
//

import UIKit

//top level of JSON result from API has 4 fields, the species array is further broken down in StarWarsSpecies class
class SpeciesWrapper: NSObject {
    //var species: Array<StarWarsSpecies>?
    var species: [StarWarsSpecies]?
    var count: Int?
    var next: String?
    var previous: String?
    
}
