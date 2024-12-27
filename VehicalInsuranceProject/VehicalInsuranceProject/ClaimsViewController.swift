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
        let claimsBaseURL = "https://abzclaimwebapi-akshitha.azurewebsites.net/swagger/index.html"

        override func viewDidLoad() {
            super.viewDidLoad()
            setupDatePickers()
        }

        func setupDatePickers() {
            [claimDateTextField, incidentDateTextField, surveyDateTextField].forEach { textField in
                textField?.inputView = datePicker
                datePicker.datePickerMode = .date
                datePicker.preferredDatePickerStyle = .wheels
                datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
            }
        }

        @objc func dateChanged(_ sender: UIDatePicker) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
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
        guard let url = URL(string: claimsBaseURL) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
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
        guard let url = URL(string: "\(claimsBaseURL)/\(claimNoTextField.text!)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(Claim)
        
        performRequest(request,action: "default") { success in
            self.showAlert(title: "Error",message: success ? "Claim updated successfully" : "Failed to update claim")
        }
    }
    
    private func showClaim(claimNo: String) {
        guard let url = URL(string: "\(claimsBaseURL)/(claimNoTextField.text!)") else { return }
        
        let request = URLRequest(url: url)
        
        performRequestWithData(request) { data in
            guard let data = data else {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Failed to retrieve claim")
                }
                return
            }
            
            do {
                let claim = try JSONDecoder().decode(ClaimDetails.self, from: data)
                DispatchQueue.main.async {
                    self.navigateToClaimsDisplay(with: claim)
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error",message: "Failed to parse claim data")
                }
            }
        }
    }
    
    private func deleteClaim(claimNo: String) {
        guard let url = URL(string: "\(claimsBaseURL)/(claimNoTextField)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
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

       private func populateClaimFields(with claim: ClaimDetails) {
           claimNoTextField.text = claim.claimNo
           claimDateTextField.text = claim.claimDate
           policyNoTextField.text = claim.policyNo
           incidentDateTextField.text = claim.incidentDate
           incidentLocationTextField.text = claim.incidentLocation
           incidentDescriptionTextField.text = claim.incidentDescription
           claimAmountTextField.text = claim.claimAmount
           surveyorNameTextField.text = claim.surveyorName
           surveyorPhoneTextField.text = claim.surveyorPhone
           surveyDateTextField.text = claim.surveyDate
           surveyDescriptionTextField.text = claim.surveyDescription
           claimStatusTextField.text = claim.claimStatus
       }
    private func navigateToClaimsDisplay(with claim: ClaimDetails) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Use your storyboard name
        guard let claimsDisplayVC = storyboard.instantiateViewController(withIdentifier: "ClaimsDisplayViewController") as? ClaimsDisplayViewController else {
            showAlert(title: "Error", message: "Failed to navigate to the claims display screen.")
            return
        }
        claimsDisplayVC.claim = claim
        navigationController?.present(claimsDisplayVC, animated: true)
    }

       private func showAlert(title: String, message: String) {
           DispatchQueue.main.async {
               let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "OK", style: .default))
               self.present(alert, animated: true)
           }
       }
   }
