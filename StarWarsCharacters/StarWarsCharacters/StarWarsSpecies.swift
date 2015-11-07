//
//  StarWarsSpecies.swift
//  StarWarsCharacters
//
//  Created by Heather Connery on 2015-11-07.
//  Copyright © 2015 HConnery. All rights reserved.
//

//import UIKit
import Foundation
import Alamofire
import SwiftyJSON

// the strings are the actual field names from the API result
enum SpeciesFields: String {
    case Name = "name"
    case Classification = "classification"
    case Designation = "designation"
    case AverageHeight = "average_height"
    case SkinColors = "skin_colors"
    case HairColors = "hair_colors"
    case EyeColors = "eye_colors"
    case AverageLifespan = "average_lifespan"
    case Homeworld = "homeworld"
    case Language = "language"
    case People = "people"
    case Films = "films"
    case Created = "created"
    case Edited = "edited"
    case Url = "url"
}


class StarWarsSpecies {

    var idNumber: Int?
    var name: String?
    var classification: String?
    var designation: String?
    var averageHeight: Int?
    var skinColors: String?
    var hairColors: String? // TODO: array
    var eyeColors: String? // TODO: array
    var averageLifespan: Int?
    var homeworld: String?
    var language: String?
    var people: Array<String>?
    var films: Array<String>?
    var created: NSDate?
    var edited: NSDate?
    var url: String?

    
    required init(json: JSON, id: Int?) {
        self.idNumber = id
        self.name = json[SpeciesFields.Name.rawValue].stringValue
        self.classification = json[SpeciesFields.Classification.rawValue].stringValue
        self.designation = json[SpeciesFields.Designation.rawValue].stringValue
        self.averageHeight = json[SpeciesFields.AverageHeight.rawValue].int
        // TODO: add all the fields!
    }
    



    // MARK: Endpoints
    class func endpointForSpecies() -> String {
        return "https://swapi.co/api/species/"
    }
    
    private class func getSpeciesAtPath(path: String, completionHandler: (SpeciesWrapper?, NSError?) -> Void) {
        Alamofire.request(.GET, path)
            .responseSpeciesArray { response in
                if let error = response.result.error
                {
                    completionHandler(nil, error)
                    return
                }
                completionHandler(response.result.value, nil)
        }
    }
    
    class func getSpecies(completionHandler: (SpeciesWrapper?, NSError?) -> Void) {
        getSpeciesAtPath(StarWarsSpecies.endpointForSpecies(), completionHandler: completionHandler)
    }
    
    class func getMoreSpecies(wrapper: SpeciesWrapper?, completionHandler: (SpeciesWrapper?, NSError?) -> Void) {
        guard var nextURLString = wrapper?.next else {
            completionHandler(nil, nil)
            return
        }
        // iOS9: Change HTTP to HTTPS
        nextURLString = nextURLString.lowercaseString.stringByReplacingOccurrencesOfString("http:", withString: "https:")
        getSpeciesAtPath(nextURLString, completionHandler: completionHandler)
    }
}
    


extension Alamofire.Request {
    func responseSpeciesArray(completionHandler: Response -> Void) -> Self {
        let responseSerializer = ResponseSerializer { request, response, data, error in
            guard error == nil else {
                return .Failure(error!)
            }
            guard let responseData = data else {
                let failureReason = "Array could not be serialized because input data was nil."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, responseData, error)
            
            switch result {
            case .Success(let value):
                let json = SwiftyJSON.JSON(value)
                let wrapper = SpeciesWrapper()
                wrapper.next = json["next"].stringValue
                wrapper.previous = json["previous"].stringValue
                wrapper.count = json["count"].intValue
                
                var allSpecies:Array = Array()
                print(json)
                let results = json["results"]
                print(results)
                for jsonSpecies in results
                {
                    print(jsonSpecies.1)
                    let species = StarWarsSpecies(json: jsonSpecies.1, id: Int(jsonSpecies.0))
                    allSpecies.append(species)
                }
                wrapper.species = allSpecies
                return .Success(wrapper)
            case .Failure(let error):
                return .Failure(error)
            }
        }
        
        return response(responseSerializer: responseSerializer,
            completionHandler: completionHandler)
    }
}

