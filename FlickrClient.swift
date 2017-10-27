//
//  FlickrClient.swift
//  VirtualMapTour
//
//  Created by Cece Soudaly on 9/2/17.
//  Copyright © 2017 CeceMobile. All rights reserved.
//

import Foundation


class FlickrClient : NSObject {
    
    var session: URLSession
    
    override init() {
        session = URLSession.shared
        super.init()
    }
    
    // Call HTTP Get Method to download data
    func taskForGETMethod(parameters: [String:AnyObject], completionHandler: @escaping (_ result:AnyObject?, _ error:NSError?) -> Void) -> URLSessionDataTask {
        
        // Set the parameters
        var mutableParameters = parameters
    
        //Build URL and configure Request
        let urlString = Constant.BaseURL  + FlickrClient.escapedParameters(parameters: mutableParameters)
        let url1 = URL(string: urlString)!
        
        print("make the request", url1)
        
        let request = URLRequest(url: url1 as URL)
        
        //Make the Request
        let task = session.dataTask(with: request) {data,response,downloadError in
            //Parse the data and use the data
            if let error = downloadError {
                let newError = FlickrClient.manageErrors(data: data as NSData?, response: response, error: error as NSError?, completionHandler: completionHandler)
                completionHandler(data as AnyObject, nil)
            } else {
                FlickrClient.parseJSONWithmpletionHandler(data: data! as NSData, completionHandler: completionHandler)
            }
        }
        //Start the request
        task.resume()
        return task
        
    }
    
//    // Display error
    class func manageErrors(data: NSData?, response: URLResponse?, error: NSError?, completionHandler: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        /* GUARD: Was there an error? */
        guard (error == nil) else {
            print("Error: There was an error with your request: \(error)")
            let modifiedError = NSError(domain: "Error", code: 0, userInfo: [NSLocalizedDescriptionKey: error!.localizedDescription])
            completionHandler(nil, modifiedError)
            return
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 403 {
                    print("Authentication Error: Status code: \(response.statusCode)!")
                    completionHandler(nil, NSError(domain: "Authentication Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Status code: \(response.statusCode)!"]))
                } else {
                    print("Server Error: Your request returned an invalid response! Status code: \(response.statusCode)!")
                    completionHandler(nil, NSError(domain: "Server Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Your request returned an invalid response! Status code: \(response.statusCode)!"]))
                }
            } else if let response = response {
                print("Server Error: Your request returned an invalid response! Response: \(response)!")
                completionHandler(nil, NSError(domain: "Server Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Your request returned an invalid response! Response: \(response)!"]))
            } else {
                print("Server Error: Your request returned an invalid response!")
                completionHandler(nil, NSError(domain: "Server Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Your request returned an invalid response!"]))
            }
            return
        }
        
        /* GUARD: Was there any data returned? */
        guard let _ = data else {
            print("Network Error: No data was returned by the request!")
            completionHandler(nil, NSError(domain: "Network Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data was returned by the request!"]))
            return
        }
    }
    
    //Parse JSON response
    class func parseJSONWithmpletionHandler(data:NSData, completionHandler:(_ result:AnyObject?, _ error:NSError?) -> Void) {
        var parsedResult: AnyObject!
        do {
            
            let json = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? [String : Any]
            
            parsedResult = json as AnyObject
            
            let posts = parsedResult["posts"] as? [[String: Any]] ?? []
            
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(nil, NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(parsedResult, nil)
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
    }

    //MARK:- SharedInstance
    
    class func sharedInstance()-> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
    
    //MARK:- Shared Image Cache
    
    struct Caches {
        static let imageCache = ImageCache()
    }
}
