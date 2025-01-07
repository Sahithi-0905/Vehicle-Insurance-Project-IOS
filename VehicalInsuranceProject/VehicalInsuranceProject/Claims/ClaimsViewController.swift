//
//  ClaimsViewController.swift
//  VehicalInsuranceProject
//
//  Created by FCI on 20/12/24.
//

import UIKit

// MARK: - Claim Model
struct ClaimDetails: Codable {
    var claimNo: String
    var claimDate: String
    var policyNo: String
    var incidentDate: String
    var incidentLocation: String
    var incidentDescription: String
    var claimAmount: String
    var surveyorName: String
    var surveyorPhone: String
    var surveyDate: String
    var surveyDescription: String
    var claimStatus: String
}

class ClaimsViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet var claimNoTextField: UITextField!
    @IBOutlet var claimDateTextField: UITextField!
    @IBOutlet var policyNoTextField: UITextField!
    @IBOutlet var incidentDateTextField: UITextField!
    @IBOutlet var incidentLocationTextField: UITextField!
    @IBOutlet var incidentDescriptionTextField: UITextField!
    @IBOutlet var claimAmountTextField: UITextField!
    @IBOutlet var surveyorNameTextField: UITextField!
    @IBOutlet var surveyorPhoneTextField: UITextField!
    @IBOutlet var surveyDateTextField: UITextField!
    @IBOutlet var surveyDescriptionTextField: UITextField!
    @IBOutlet var claimStatusTextField: UITextField!
    
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var updateButton: UIButton!
    @IBOutlet var showButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    
    let datePicker = UIDatePicker()
    let accessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoibW0iLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJubiIsImV4cCI6MTczNTg5NzY1OSwiaXNzIjoiaHR0cHM6Ly93d3cudGVhbTIuY29tIiwiYXVkIjoiaHR0cHM6Ly93d3cudGVhbTIuY29tIn0.XIHY3tb-BQ0s_OFBMFcre95dIxgWuZ7MZu1SX7IOVMQ"
    
    let baseURL = "https://abzclaimwebapi-akshitha.azurewebsites.net/api/claim"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDatePickers()
    }

    func setupDatePickers() {
        [claimDateTextField, incidentDateTextField, surveyDateTextField].forEach { textField in
            textField?.inputView = datePicker
            datePicker.datePickerMode = .date
            datePicker.preferredDatePickerStyle = .inline
            datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        }
    }

    @objc func dateChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        if claimDateTextField.isFirstResponder {
            claimDateTextField.text = formatter.string(from: sender.date)
        } else if incidentDateTextField.isFirstResponder {
            incidentDateTextField.text = formatter.string(from: sender.date)
        } else if surveyDateTextField.isFirstResponder {
            surveyDateTextField.text = formatter.string(from: sender.date)
        }
    }

    // MARK: - Button Actions
       @IBAction func saveButtonTapped(_ sender: UIButton) {
           guard let claim = getClaimFromFields() else {
               showAlert(title: "Error", message: "Please fill all fields.")
               return
           }
           saveClaim(Claim: claim)
       }

       @IBAction func updateButtonTapped(_ sender: UIButton) {
           guard let claim = getClaimFromFields() else {
               showAlert(title: "Error", message: "Please fill all fields.")
               return
           }
           updateClaim(Claim: claim)
       }

    @IBAction func showButtonTapped(_ sender: UIButton) {
        guard let claimNo = claimNoTextField.text, !claimNo.isEmpty else {
            showAlert(title: "Error", message: "Please enter the Claim No to fetch details.")
            return
        }
        
        // Assuming you want to show claim details
        showClaim(claimNo: claimNo)
    }

    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        guard let claimNo = claimNoTextField.text, !claimNo.isEmpty else {
            showAlert(title: "Error", message: "Please enter the Claim No to delete.")
            return
        }
        
        // Assuming you want to delete the claim
        deleteClaim(claimNo: claimNo)
    }

       // MARK: - API Methods
    private func saveClaim(Claim: ClaimDetails) {
        guard let url = URL(string: "\(baseURL)/\(accessToken)") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let requestBody = try JSONEncoder().encode(Claim)
            request.httpBody = requestBody
        } catch {
            print("Error encoding claim: \(error)")
            return
        }

        performRequest(request, action: "save") { success in
            DispatchQueue.main.async {
                if success {
                    self.showAlert(title: "Error",message: "Claim saved successfully!")
                } else {
                    self.showAlert(title: "Error",message: "Failed to save claim. Please try again.")
                }
            }
        }
    }

    private func updateClaim(Claim: ClaimDetails) {
        guard let url = URL(string: "\(baseURL)/\(claimNoTextField.text!)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(Claim)
        
        performRequest(request,action: "default") { success in
            self.showAlert(title: "Error",message: success ? "Claim updated successfully" : "Failed to update claim")
        }
    }
    
    private func showClaim(claimNo: String) {
        guard !claimNo.isEmpty else {
            DispatchQueue.main.async {
                self.showAlert(title: "Error", message: "Please enter a valid Claim No.")
            }
            return
        }
        
        guard let url = URL(string: "\(baseURL)/\(claimNo)") else {
            DispatchQueue.main.async {
                self.showAlert(title: "Error", message: "Invalid URL")
            }
            return
        }
        
        print("Constructed URL: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Network Error: \(error.localizedDescription)")
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("No data received.")
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "No data received.")
                }
                return
            }
            
            // Print the raw response to inspect the data
            print("Raw Response: \(String(data: data, encoding: .utf8) ?? "Invalid data")")
            
            do {
                // Attempt to parse the JSON response
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    DispatchQueue.main.async {
                        // Log the JSON structure to inspect the keys
                        print("Parsed JSON: \(jsonResponse)")
                        
                        // Call function to populate text fields with the data
                        self.populateTextFieldsFromJSON(jsonResponse)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: "Unexpected response format.")
                    }
                }
            } catch {
                print("Decoding Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Failed to parse claim data.")
                }
            }
        }.resume()
    }
    
    private func deleteClaim(claimNo: String) {
        guard let url = URL(string: "\(baseURL)/\(claimNo)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        performRequest(request, action: "delete") { success in
            if success {
            // Handle success if needed
                self.showAlert(title: "Error",message: "Claim deleted successfully!")
            } else {
            // Handle failure if needed
                self.showAlert(title: "Error",message: "Failed to delete Claim!")
            }
        }
    }
       // MARK: - Network Request Helpers
    private func performRequest(_ request: URLRequest, action: String, completion: @escaping (Bool) -> Void) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Request Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert(title: "Error",message: "Network Error: \(error.localizedDescription)")
                }
                completion(false)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200...299: // Success range
                    DispatchQueue.main.async {
                        switch action {
                        case "save":
                            self.showAlert(title: "Error",message: "Claim saved successfully!")
                        case "delete":
                            self.showAlert(title: "Error",message: "Claim deleted successfully!")
                        default:
                            self.showAlert(title: "Error",message: "Action performed successfully!")
                        }
                    }
                    completion(true)
                default:
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error",message: "Failed to perform action. Status code: \(httpResponse.statusCode)")
                    }
                    completion(false)
                }
            }
        }.resume()
    }

       private func performRequestWithData(_ request: URLRequest, completion: @escaping (Data?) -> Void) {
           URLSession.shared.dataTask(with: request) { data, response, error in
               if let error = error {
                   print("Error: \(error.localizedDescription)")
                   completion(nil)
                   return
               }
               guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                   completion(nil)
                   return
               }
               completion(data)
           }.resume()
       }

       // MARK: - Helper Methods
       private func getClaimFromFields() -> ClaimDetails? {
           guard let claimNo = claimNoTextField.text, !claimNo.isEmpty,
                 let claimDate = claimDateTextField.text, !claimDate.isEmpty,
                 let policyNo = policyNoTextField.text, !policyNo.isEmpty,
                 let incidentDate = incidentDateTextField.text, !incidentDate.isEmpty,
                 let incidentLocation = incidentLocationTextField.text, !incidentLocation.isEmpty,
                 let incidentDescription = incidentDescriptionTextField.text, !incidentDescription.isEmpty,
                 let claimAmount = claimAmountTextField.text, !claimAmount.isEmpty,
                 let surveyorName = surveyorNameTextField.text, !surveyorName.isEmpty,
                 let surveyorPhone = surveyorPhoneTextField.text, !surveyorPhone.isEmpty,
                 let surveyDate = surveyDateTextField.text, !surveyDate.isEmpty,
                 let surveyDescription = surveyDescriptionTextField.text, !surveyDescription.isEmpty,
                 let claimStatus = claimStatusTextField.text, !claimStatus.isEmpty else { return nil }

           return ClaimDetails(
               claimNo: claimNo,
               claimDate: claimDate,
               policyNo: policyNo,
               incidentDate: incidentDate,
               incidentLocation: incidentLocation,
               incidentDescription: incidentDescription,
               claimAmount: claimAmount,
               surveyorName: surveyorName,
               surveyorPhone: surveyorPhone,
               surveyDate: surveyDate,
               surveyDescription: surveyDescription,
               claimStatus: claimStatus
           )
       }

       private func populateTextFieldsFromJSON(_ jsonResponse: [String: Any]) {
           // Use safe optional binding to ensure keys are correct in the JSON response
           if let claimNo = jsonResponse["claimNo"] as? String {
               self.claimNoTextField.text = claimNo
           } else {
               print("Claim No not found in the response")
           }
           
           if let claimDate = jsonResponse["claimDate"] as? String {
               self.claimDateTextField.text = claimDate
           } else {
               print("Claim Date not found in the response")
           }
           
           if let policyNo = jsonResponse["policyNo"] as? String {
               self.policyNoTextField.text = policyNo
           } else {
               print("Policy No not found in the response")
           }
           
           if let incidentDate = jsonResponse["incidentDate"] as? String {
               self.incidentDateTextField.text = incidentDate
           } else {
               print("Incident Date not found in the response")
           }
           
           if let incidentLocation = jsonResponse["incidentLocation"] as? String {
               self.incidentLocationTextField.text = incidentLocation
           } else {
               print("Incident Location not found in the response")
           }
           
           if let incidentDescription = jsonResponse["incidentDescription"] as? String {
               self.incidentDescriptionTextField.text = incidentDescription
           } else {
               print("Incident Description not found in the response")
           }
           
           if let claimAmount = jsonResponse["claimAmount"] as? Int {
               self.claimAmountTextField.text = String(claimAmount)
           } else {
               print("Claim Amount not found in the response")
           }
           
           if let surveyorName = jsonResponse["surveyorName"] as? String {
               self.surveyorNameTextField.text = surveyorName
           } else {
               print("Surveyor Name not found in the response")
           }
           
           if let surveyorPhone = jsonResponse["surveyorPhone"] as? String {
               self.surveyorPhoneTextField.text = surveyorPhone
           } else {
               print("Surveyor Phone not found in the response")
           }
           if let surveyDate = jsonResponse["surveyDate"] as? String {
               self.surveyDateTextField.text = surveyDate
           }else {
               print("Survey Date not found in the response")
           }
           
           if let surveyDescription = jsonResponse["surveyDescription"] as? String {
               self.surveyDescriptionTextField.text = surveyDescription
           } else {
               print("Survey Description not found in the response")
           }
           
           if let claimStatus = jsonResponse["claimStatus"] as? String {
               self.claimStatusTextField.text = claimStatus
           } else {
               print("Claim Status not found in the response")
           }
       }

       private func showAlert(title: String, message: String) {
           DispatchQueue.main.async {
               let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "OK", style: .default))
               self.present(alert, animated: true)
           }
       }
   }
