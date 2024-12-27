//
//  PolicyAddonViewController.swift
//  VehicalInsuranceProject
//
//  Created by FCI on 20/12/24.
//

import UIKit

struct PolicyAddon: Codable {
    let policyNumber: String
    let addonID: String
    let amount: Double
}

class PolicyAddonViewController: UIViewController {
    
    @IBOutlet var policyNumberField: UITextField!
    @IBOutlet var addonIDField: UITextField!
    @IBOutlet var amountField: UITextField!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var updateButton: UIButton!
    @IBOutlet var showButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Save Policy Add-On
    @IBAction func savePolicyAddon() {
        guard let policyAddonData = createPolicyAddonData() else {
            displayAlert(alertTitle: "Error", alertMessage: "All fields must be filled.")
            return
        }
        
        performRequest(
            endpoint: "https://abzproductwebapi-akshitha.azurewebsites.net/api/PolicyAddon",
            method: "POST",
            policyAddonData: policyAddonData
        ) { _ in
            self.displayAlert(alertTitle: "Success", alertMessage: "Policy Add-On saved successfully.")
        }
    }
    
    // Update Policy Add-On
    @IBAction func updatePolicyAddon() {
        guard let policyAddonData = createPolicyAddonData(),
              let policyNumber = policyNumberField.text,
              let addonID = addonIDField.text else {
            displayAlert(alertTitle: "Error", alertMessage: "All fields must be filled, including Policy Number and Add-On ID.")
            return
        }
        
        performRequest(
            endpoint: "https://abzproductwebapi-akshitha.azurewebsites.net/api/PolicyAddon/\(policyNumber)/\(addonID)",
            method: "PUT",
            policyAddonData: policyAddonData
        ) { _ in
            self.displayAlert(alertTitle: "Success", alertMessage: "Policy Add-On updated successfully.")
        }
    }
    
    // Delete Policy Add-On
    @IBAction func deletePolicyAddon() {
        guard let policyNumber = policyNumberField.text, !policyNumber.isEmpty,
              let addonID = addonIDField.text, !addonID.isEmpty else {
            displayAlert(alertTitle: "Error", alertMessage: "Please enter a Policy Number and Add-On ID.")
            return
        }
        
        performRequest(
            endpoint: "https://abzproductwebapi-akshitha.azurewebsites.net/api/PolicyAddon/\(policyNumber)/\(addonID)",
            method: "DELETE"
        ) { _ in
            self.displayAlert(alertTitle: "Success", alertMessage: "Policy Add-On deleted successfully.")
        }
    }
    
    // Show Policy Add-On
    @IBAction func showPolicyAddon() {
        guard let policyNumber = policyNumberField.text, !policyNumber.isEmpty,
              let addonID = addonIDField.text, !addonID.isEmpty else {
            displayAlert(alertTitle: "Error", alertMessage: "Please enter a Policy Number and Add-On ID.")
            return
        }
        
        performRequest(
            endpoint: "https://abzproductwebapi-akshitha.azurewebsites.net/api/PolicyAddon/\(policyNumber)/\(addonID)",
            method: "GET"
        ) { response in
            guard let policyAddon = self.parsePolicyAddonResponse(response) else {
                self.displayAlert(alertTitle: "Error", alertMessage: "Failed to fetch policy add-on details.")
                return
            }
            
            DispatchQueue.main.async {
                self.populateFields(with: policyAddon)
            }
        }
    }
    
    // Helper Methods
    private func createPolicyAddonData() -> PolicyAddon? {
        guard let policyNumber = policyNumberField.text, !policyNumber.isEmpty,
              let addonID = addonIDField.text, !addonID.isEmpty,
              let amountText = amountField.text, let amount = Double(amountText) else {
            return nil
        }
        
        return PolicyAddon(policyNumber: policyNumber, addonID: addonID, amount: amount)
    }
    
    private func performRequest(endpoint: String, method: String, policyAddonData: PolicyAddon? = nil, completion: @escaping (Data?) -> Void) {
        guard let url = URL(string: endpoint) else {
            displayAlert(alertTitle: "Error", alertMessage: "Invalid URL.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let policyAddonData = policyAddonData {
            do {
                let jsonData = try JSONEncoder().encode(policyAddonData)
                request.httpBody = jsonData
            } catch {
                displayAlert(alertTitle: "Error", alertMessage: "Failed to encode policy add-on data.")
                return
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.displayAlert(alertTitle: "Error", alertMessage: "Request failed: \(error.localizedDescription)")
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    self.displayAlert(alertTitle: "Error", alertMessage: "Server error or invalid response.")
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(data)
            }
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
        policyNumberField.text = policyAddon.policyNumber
        addonIDField.text = policyAddon.addonID
        amountField.text = "\(policyAddon.amount)"
    }
    
    private func displayAlert(alertTitle: String, alertMessage: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}


    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

