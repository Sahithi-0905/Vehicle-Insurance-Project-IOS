//
//  Appconstants.swift
//  VehicalInsuranceProject
//
//  Created by FCI on 03/01/25.
//

import Foundation
struct AppConstants{
    
    static let customerAPI = "https://abzcustomerwebapi-akshitha.azurewebsites.net"
    static let productAPI = "https://abzproductwebapi-akshitha.azurewebsites.net"
    static let queryAPI = "https://abzcustomerquerywebapi-akshitha.azurewebsites.net"
    static let agentAPI = "https://abzagentwebapi-akshitha.azurewebsites.net"
    static let claimAPI = "https://abzclaimwebapi-akshitha.azurewebsites.net"
    static let policyAPI = "https://abzpolicywebapi-akshitha.azurewebsites.net"
    
    static let proposalAPI = "https://abzproposalwebapi-akshitha.azurewebsites.net"
    static let vehicleAPI = "https://abzvehiclewebapi-akshitha.azurewebsites.net"
    static let authAPI = "https://authenticationwebapi-akshitha.azurewebsites.net"
    
    static var bearerToken:String =  " "
    
    static func generateToken(completion: @escaping (Bool) -> Void) {
        let url = URL(string: "\(AppConstants.authAPI)/api/Auth/userName/role/My%20name%20is%20Bond%2C%20James%20Bond%20the%20great")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Perform the API Request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error during token generation: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server error. Status code: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                if let data = data {
                    print("Response data: \(String(data: data, encoding: .utf8) ?? "No data")")
                }
                completion(false)
                return
            }
            
            guard let data = data, let token = String(data: data, encoding: .utf8) else {
                print("Failed to decode token")
                completion(false)
                return
            }
            
            // Assign token to static variable
            DispatchQueue.main.async {
                bearerToken = token.trimmingCharacters(in: .whitespacesAndNewlines)
                //print("Token generated and set: \(bearerToken)")
                completion(true)
            }
        }
        task.resume()
    }

}
