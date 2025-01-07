//
//  PolicyAddonViewController.swift
//  VehicalInsuranceProject
//
//  Created by FCI on 20/12/24.
//

import UIKit

struct PolicyAddon: Codable {
    let addonID: String
    let policyNo: String
    let amount: Int
    
}

class PolicyAddonViewController: UIViewController {
    
    @IBOutlet var policyNumberField: UITextField!
    @IBOutlet var addonIDField: UITextField!
    @IBOutlet var amountField: UITextField!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var updateButton: UIButton!
    @IBOutlet var showButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    
    var token: String=" "
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppConstants.generateToken { success in
            DispatchQueue.main.async {
                if success {
                    self.token=AppConstants.bearerToken
                    print("Token generated successfully: \(AppConstants.bearerToken)")
                    
                } else {
                    print("Failed to generate token")
                    self.showAlert(
                        alertTitle: "Error",
                        alertMessage: "Failed to generate token. Please try again."
                    )
                }
            }
        }
    }
    
    // Save Policy Add-On
    @IBAction func savePolicyAddon() {
        guard let policyAddonData = createPolicyAddonData() else {
            showAlert(alertTitle: "Error", alertMessage: "All fields must be filled.")
            return
        }
        
        performRequest(
            endpoint: "\(AppConstants.policyAPI)/api/PolicyAddon/\(token)",
            method: "POST",
            policyAddonData: policyAddonData
        ) { _ in
            self.showAlert(alertTitle: "Success", alertMessage: "Policy Add-On saved successfully.")
        }
    }
    
    // Update Policy Add-On
    @IBAction func updatePolicyAddon() {
        guard let policyAddonData = createPolicyAddonData(),
              let policyNumber = policyNumberField.text,
              let addonID = addonIDField.text else {
            showAlert(alertTitle: "Error", alertMessage: "All fields must be filled, including Policy Number and Add-On ID.")
            return
        }
        
        performRequest(
            endpoint: "\(AppConstants.policyAPI)/api/PolicyAddon/\(policyNumber)/\(addonID)",
            method: "PUT",
            policyAddonData: policyAddonData
        ) { _ in
            self.showAlert(alertTitle: "Success", alertMessage: "Policy Add-On updated successfully.")
        }
    }
    
    // Delete Policy Add-On
    @IBAction func deletePolicyAddon() {
        guard let policyNumber = policyNumberField.text, !policyNumber.isEmpty,
              let addonID = addonIDField.text, !addonID.isEmpty else {
            showAlert(alertTitle: "Error", alertMessage: "Please enter a Policy Number and Add-On ID.")
            return
        }
        
        performRequest(
            endpoint: "\(AppConstants.policyAPI)/api/PolicyAddon/\(policyNumber)/\(addonID)",
            method: "DELETE"
        ) { _ in
            self.showAlert(alertTitle: "Success", alertMessage: "Policy Add-On deleted successfully.")
        }
    }
    
    // Show Policy Add-On
    @IBAction func showPolicyAddon() {
        guard let policyNumber = policyNumberField.text, !policyNumber.isEmpty,
              let addonID = addonIDField.text, !addonID.isEmpty else {
            showAlert(alertTitle: "Error", alertMessage: "Please enter a Policy Number and Add-On ID.")
            return
        }
        
        performRequest(
            endpoint: "\(AppConstants.policyAPI)/api/PolicyAddon/\(policyNumber)/\(addonID)",
            method: "GET"
        ) { response in
            guard let policyAddon = self.parsePolicyAddonResponse(response) else {
                self.showAlert(alertTitle: "Error", alertMessage: "Failed to fetch policy add-on details.")
                return
            }
            
            DispatchQueue.main.async {
                self.populateFields(with: policyAddon)
            }
        }
    }
    
    // Helper Methods
    private func createPolicyAddonData() -> PolicyAddon? {
        guard let addonID = addonIDField.text, !addonID.isEmpty,
              let policyNo = policyNumberField.text, !policyNo.isEmpty,
              let amountText = Int(amountField.text!) else {
            return nil
        }
        
        return PolicyAddon( addonID: addonID,
                            policyNo: policyNo,
                            amount: amountText)
    }
    
    private func performRequest(endpoint: String,
                                method: String,
                                policyAddonData: PolicyAddon? = nil,
                                completion: @escaping (Data?) -> Void
    ) {
        guard let url = URL(string: endpoint) else {
            showAlert(alertTitle: "Error", alertMessage: "Invalid URL.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(AppConstants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let policyaddonFetchData = policyAddonData {
            do {
                let jsonData = try JSONEncoder().encode(policyaddonFetchData)
                
                print("Request Body: \(String(data: jsonData, encoding: .utf8) ?? "")")
                
                request.httpBody = jsonData
            } catch {
                showAlert(alertTitle: "Error", alertMessage: "Failed to encode product data.")
                return
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.showAlert(alertTitle: "Error", alertMessage: "Request failed: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                self.showAlert(alertTitle: "Error", alertMessage: "Server error or invalid response.")
                return
            }
            
            completion(data)
        }
        task.resume()
        
    }
    
    private func parsePolicyAddonResponse(_ data: Data?) -> PolicyAddon? {
        guard let data = data else { return nil }
        do {
            return try JSONDecoder().decode(PolicyAddon.self, from: data)
        } catch {
            print("Error decoding policy add-on data: \(error)")
            return nil
        }
    }
    
    private func populateFields(with policyAddon: PolicyAddon) {
        policyNumberField.text = policyAddon.policyNo
        addonIDField.text = policyAddon.addonID
        amountField.text = "\(policyAddon.amount)"
    }
    
    private func showAlert(alertTitle: String, alertMessage: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}

