//
//  CustomerQueryViewController.swift
//  VehicalInsuranceProject
//
//  Created by FCI on 31/12/24.
//

import UIKit

class CustomerQueryViewController: UIViewController {
    @IBOutlet var queryID: UITextField!
    @IBOutlet var custID: UITextField!
    @IBOutlet var descript: UITextField!
    @IBOutlet var queryDate: UITextField!
    @IBOutlet var status: UITextField!
    
    @IBOutlet var save: UIButton!
    @IBOutlet var show: UIButton!
    
    var dp1: UIDatePicker!
    var df1: DateFormatter!
    var token:String = " "
    override func viewDidLoad() {
        
        super.viewDidLoad()
        AppConstants.generateToken { success in
            DispatchQueue.main.async {
                if success {
                    print("Token generated successfully: \(AppConstants.bearerToken)")
                    // Proceed with further API calls or UI setup
                    self.token=AppConstants.bearerToken
                    print(self.token)
                } else {
                    print("Failed to generate token")
                    

                }
            }
        }
        dp1 = UIDatePicker()
        dp1.datePickerMode = .date
        dp1.preferredDatePickerStyle = .wheels
        dp1.addTarget(self, action: #selector(dp1Click), for: .valueChanged)
        queryDate.inputView = dp1
        // Do any additional setup after loading the view.
    }
    
    @objc func dp1Click() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" // ISO 8601 format with milliseconds
        
        // Convert the selected date into the formatted string
        let formattedDate = dateFormatter.string(from: dp1.date)
        queryDate.text = formattedDate
    }
    @IBAction func saveQuery(_ sender: UIButton) {
        guard let QID = queryID.text, !QID.isEmpty,
              let CID = custID.text, !CID.isEmpty,
              let DES = descript.text, !DES.isEmpty,
              let QDATE = queryDate.text, !QDATE.isEmpty,
              let STATUS = status.text, !STATUS.isEmpty else {
            print("Invalid input: All fields must be filled.")
            return
        }
        
        guard let webserviceURL = URL(string: "\(AppConstants.queryAPI)/api/CustomerQuery") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: webserviceURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let queryinfo: [String: Any] = [
            "QueryID": QID,
            "CustomerID": CID,
            "Description": DES,
            "QueryDate": QDATE,
            "Status": STATUS
        ]
        

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: queryinfo, options: [])
            request.httpBody = jsonData
        } catch {
            showAlert(title: "Error", message: "Failed to serialize JSON: \(error.localizedDescription)")
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                self.showAlert(title: "Error", message: "Request failed: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")

                if !(200...299).contains(httpResponse.statusCode) {
                    if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
                        self.showAlert(title: "Error", message: "Server Error (\(httpResponse.statusCode)): \(errorMessage)")
                    } else {
                        self.showAlert(title: "Error", message: "Server returned an error: \(httpResponse.statusCode)")
                    }
                    return
                }
            }
        
        
            
            if let data = data {
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        self.showAlert(title: "Success", message: "Customer Query saved")
                    }
                } catch {
                    self.showAlert(title: "Error", message: "Failed to parse JSON: \(error.localizedDescription)")
                }
            }
            if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
                print("Server Response: \(errorMessage)")
            }

        }
        task.resume()
    }
        @IBAction func getQuery(_ sender: UIButton) {
        

        guard let QID = queryID.text, !QID.isEmpty else {
            print("Invalid input: Product ID must be filled.")
            return
        }
        
        // Construct the URL
        guard let webserviceURL = URL(string: "\(AppConstants.queryAPI)/api/CustomerQuery/\(QID)") else {
            print("Invalid URL")
            return
        }
        // Debug print the URL
        print("Request URL: \(webserviceURL)")

        // Create the GET request
        var request = URLRequest(url: webserviceURL)
        request.httpMethod = "GET"
        
        // Ensure the authorization header is set correctly
        request.setValue("Bearer \(AppConstants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Debug print the headers to ensure token is being passed
        print("Authorization Header: \(request.allHTTPHeaderFields?["Authorization"] ?? "No Authorization Header")")

        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            // Handle connection errors
            if let error = error {
                self.showAlert(title: "Error", message: "Request failed: \(error.localizedDescription)")
                return
            }
            
            // Handle HTTP response
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                
                if !(200...299).contains(httpResponse.statusCode) {
                    if httpResponse.statusCode == 401 {
                        self.showAlert(title: "Error", message: "Unauthorized: Check your access token.")
                    } else if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
                        self.showAlert(title: "Error", message: "Server Error (\(httpResponse.statusCode)): \(errorMessage)")
                    } else {
                        self.showAlert(title: "Error", message: "Server returned an error: \(httpResponse.statusCode)")
                    }
                    return
                }
            }
            
            // Handle response data
            guard let data = data else {
                self.showAlert(title: "Error", message: "No data received from server.")
                return
            }
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    print("Response from server: \(jsonResponse)")
                    DispatchQueue.main.async {
                        //                             Safely unwrap and update the UI with the fetched data
                        self.queryID.text = jsonResponse["queryID"] as? String ?? "N/A"
                        self.custID.text = jsonResponse["customerID"] as? String ?? "N/A"
                        self.descript.text = jsonResponse["description"] as? String ?? "N/A"
                        self.queryDate.text = jsonResponse["queryDate"] as? String ?? "N/A"
                        self.status.text = jsonResponse["status"] as? String ?? "N/A"
                   
                    }
                    
                }
                
            } catch {
                DispatchQueue.main.async {
                    print("Failed to parse JSON: \(error.localizedDescription)")
                }
            }
            
        }
        task.resume()
    }
    
    
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}

    

