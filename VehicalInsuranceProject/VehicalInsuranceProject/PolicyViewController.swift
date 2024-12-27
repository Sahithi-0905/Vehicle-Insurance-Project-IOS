//
//  PolicyViewController.swift
//  VehicalInsuranceProject
//
//  Created by shamitha on 24/12/24.
//

import UIKit

struct Policy: Codable {
    let policyNumber: String
    let proposalNumber: String
    let noClaimBonus: String
    let receiptNumber: String
    let receiptDate: String
    let paymentMode: String
    let amount: String
}

class PolicyViewController: UIViewController {

    @IBOutlet var policyNumberField: UITextField!
    @IBOutlet var proposalNumberField: UITextField!
    @IBOutlet var noClaimBonusField: UITextField!
    @IBOutlet var receiptNumberField: UITextField!
    @IBOutlet var receiptDateField: UITextField!
    @IBOutlet var paymentModeField: UITextField!
    @IBOutlet var amountField: UITextField!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var updateButton: UIButton!
    @IBOutlet var showButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    
    private var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDatePicker()
    }
    
    // MARK: - Date Picker Setup
    private func setupDatePicker() {
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        receiptDateField.inputView = datePicker
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        receiptDateField.text = formatter.string(from: sender.date)
    }
    
    // MARK: - Button Actions
    
    @IBAction func savePolicy() {
        guard let policyData = createPolicyData() else {
            displayAlert(alertTitle: "Error", alertMessage: "All fields must be filled.")
            return
        }
        
        performRequest(
            endpoint: "https://abzpolicywebapi-akshitha.azurewebsites.net/api/Policy",
            method: "POST",
            policyData: policyData
        ) { response in
            self.displayAlert(alertTitle: "Success", alertMessage: "Policy saved successfully.")
        }
    }
    
    @IBAction func updatePolicy() {
        guard let policyData = createPolicyData(), let policyNumber = policyNumberField.text else {
            displayAlert(alertTitle: "Error", alertMessage: "All fields must be filled, including Policy Number.")
            return
        }
        
        performRequest(
            endpoint: "https://abzpolicywebapi-akshitha.azurewebsites.net/api/Policy/\(policyNumber)",
            method: "PUT",
            policyData: policyData
        ) { response in
            self.displayAlert(alertTitle: "Success", alertMessage: "Policy updated successfully.")
        }
    }
    
    @IBAction func showPolicy() {
        guard let policyNumber = policyNumberField.text, !policyNumber.isEmpty else {
            displayAlert(alertTitle: "Error", alertMessage: "Please enter a Policy Number.")
            return
        }
        
        performRequest(
            endpoint: "https://abzpolicywebapi-akshitha.azurewebsites.net/api/Policy/\(policyNumber)",
            method: "GET"
        ) { response in
            guard let policy = self.parsePolicyResponse(response) else {
                self.displayAlert(alertTitle: "Error", alertMessage: "Failed to fetch policy details.")
                return
            }
            
            DispatchQueue.main.async {
                self.populateFields(with: policy)
            }
        }
    }
    
    @IBAction func deletePolicy() {
        guard let policyNumber = policyNumberField.text, !policyNumber.isEmpty else {
            displayAlert(alertTitle: "Error", alertMessage: "Please enter a Policy Number.")
            return
        }
        
        performRequest(
            endpoint: "https://abzpolicywebapi-akshitha.azurewebsites.net/api/Policy/\(policyNumber)",
            method: "DELETE"
        ) { _ in
            self.displayAlert(alertTitle: "Success", alertMessage: "Policy deleted successfully.")
        }
    }
    
    // MARK: - Helper Functions
    
    private func createPolicyData() -> Policy? {
        guard let policyNumber = policyNumberField.text, !policyNumber.isEmpty,
              let proposalNumber = proposalNumberField.text, !proposalNumber.isEmpty,
              let noClaimBonus = noClaimBonusField.text, !noClaimBonus.isEmpty,
              let receiptNumber = receiptNumberField.text, !receiptNumber.isEmpty,
              let receiptDate = receiptDateField.text, !receiptDate.isEmpty,
              let paymentMode = paymentModeField.text, !paymentMode.isEmpty,
              let amount = amountField.text, !amount.isEmpty else {
            return nil
        }
        
        return Policy(
            policyNumber: policyNumber,
            proposalNumber: proposalNumber,
            noClaimBonus: noClaimBonus,
            receiptNumber: receiptNumber,
            receiptDate: receiptDate,
            paymentMode: paymentMode,
            amount: amount
        )
    }
    
    private func performRequest(
        endpoint: String,
        method: String,
        policyData: Policy? = nil,
        completion: @escaping (Data?) -> Void
    ) {
        guard let url = URL(string: endpoint) else {
            displayAlert(alertTitle: "Error", alertMessage: "Invalid URL.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let policyData = policyData {
            do {
                let jsonData = try JSONEncoder().encode(policyData)
                request.httpBody = jsonData
            } catch {
                displayAlert(alertTitle: "Error", alertMessage: "Failed to encode policy data.")
                return
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.displayAlert(alertTitle: "Error", alertMessage: "Request failed: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                self.displayAlert(alertTitle: "Error", alertMessage: "Server error or invalid response.")
                return
            }
            
            completion(data)
        }
        task.resume()
    }
    
    private func parsePolicyResponse(_ data: Data?) -> Policy? {
        guard let data = data else { return nil }
        do {
            return try JSONDecoder().decode(Policy.self, from: data)
        } catch {
            print("Error decoding policy data: \(error)")
            return nil
        }
    }
    
    private func populateFields(with policy: Policy) {
        policyNumberField.text = policy.policyNumber
        proposalNumberField.text = policy.proposalNumber
        noClaimBonusField.text = policy.noClaimBonus
        receiptNumberField.text = policy.receiptNumber
        receiptDateField.text = policy.receiptDate
        paymentModeField.text = policy.paymentMode
        amountField.text = policy.amount
    }
    
    func displayAlert(alertTitle: String, alertMessage: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}

