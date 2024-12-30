//
//  ProposalViewController.swift
//  VehicalInsuranceProject
//
//  Created by shamitha on 26/12/24.
//

import UIKit
struct Proposal: Codable {
    let proposalNo: String
    let regNo: String
    let productID: String
    let customerID: String
    let fromDate: String
    let toDate: String
    let idv: Int
    let agentID: String
    let basicAmount: Int
    let totalAmount: Int

    
}
class ProposalViewController: UIViewController {
    @IBOutlet var proposalNo: UITextField!
    @IBOutlet var registrationNo: UITextField!
    @IBOutlet var ProductID: UITextField!
    @IBOutlet var CustomerID: UITextField!
    @IBOutlet var FromDate: UITextField!
    @IBOutlet var ToDate: UITextField!
    @IBOutlet var Idv: UITextField!
    @IBOutlet var AgentID: UITextField!
    @IBOutlet var BasicAmount: UITextField!
    @IBOutlet var TotalAmount: UITextField!
    
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var updateButton: UIButton!
    @IBOutlet var showButton: UIButton!
    
    var vehiclePicker: UIPickerView!
    var productPicker: UIPickerView!
    var agentPicker: UIPickerView!
    var customerPicker: UIPickerView!
    
    var vehiclesList:[String] =  []
    var productsList:[String] =  []
    var agentsList:[String] =  []
    var customersList:[String] =  []
    
    let accessToken="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoibW0iLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJrayIsImV4cCI6MTczNTQ2NTc0MiwiaXNzIjoiaHR0cHM6Ly93d3cudGVhbTIuY29tIiwiYXVkIjoiaHR0cHM6Ly93d3cudGVhbTIuY29tIn0.mlSWJrMVfX1S0UmvnwuhnYdli9tKz3mSo9wx8WQxCbY"
    
    private var datePicker: UIDatePicker!
    var activeDateField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getVehicleIds()
        getProductIds()
        getAgentIds()
        getCustomerIds()
        
        setupDatePicker()
        
        let toolbar2 = UIToolbar()
        toolbar2.sizeToFit()
        let done2 = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissFunc))
        toolbar2.setItems([done2], animated: true)
    }
    private func setupDatePicker() {
        datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .date
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(datePickerValueChanged))
        toolbar.setItems([doneButton], animated: true)
        
        FromDate.inputView = datePicker
        FromDate.inputAccessoryView = toolbar
        ToDate.inputView = datePicker
        ToDate.inputAccessoryView = toolbar
        
        FromDate.delegate = self
        ToDate.delegate = self
    }
    @objc func dismissFunc(){
        view.endEditing(true)
    }
    func formatDateToISO8601WithMilliseconds(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC time
        return formatter.string(from: date)
    }

    @objc func datePickerValueChanged() {
        guard let activeField = activeDateField else { return }
        activeField.text = formatDateToISO8601WithMilliseconds(datePicker.date)
        view.endEditing(true)
    }
    @IBAction func saveProposal() {
        guard let proposalData = createPolicyData() else {
            displayAlert(alertTitle: "Error", alertMessage: "All fields must be filled.")
            return
        }
        
        performRequest(
            endpoint: "https://abzproposalwebapi-akshitha.azurewebsites.net/api/Proposal/\(accessToken)",
            method: "POST",
            proposalData: proposalData
        ) { response in
            self.displayAlert(alertTitle: "Success", alertMessage: "Proposal saved successfully.")
        }
    }
    @IBAction func updateProposal() {
        guard let proposalData = createPolicyData(), let proposalId = proposalNo.text else {
            displayAlert(alertTitle: "Error", alertMessage: "All fields must be filled.")
            return
        }
        
        performRequest(
            endpoint: "https://abzproposalwebapi-akshitha.azurewebsites.net/api/Proposal/\(proposalId)",
            method: "PUT",
            proposalData: proposalData
        ) { response in
            self.displayAlert(alertTitle: "Success", alertMessage: "Proposal updated successfully.")
        }
    }
    @IBAction func deleteProposal() {
        guard let proposalId = proposalNo.text, !proposalId.isEmpty else {
            displayAlert(alertTitle: "Error", alertMessage: "Please enter a Product ID.")
            return
        }
        
        performRequest(
            endpoint: "https://abzproposalwebapi-akshitha.azurewebsites.net/api/Proposal/\(proposalId)",
            method: "DELETE"
        ) { response in
            self.displayAlert(alertTitle: "Success", alertMessage: "Proposal deleted successfully.")
        }
    }
    @IBAction func showProposalDetails(){
        guard let proposalId = proposalNo.text, !proposalId.isEmpty else {
            displayAlert(alertTitle: "Error", alertMessage: "Please enter a Proposal ID.")
            return
        }
        
        performRequest(
            endpoint: "https://abzproductwebapi-akshitha.azurewebsites.net/api/Product/\(proposalId)",
            method: "GET"
        ) { response in
            guard let product = self.parseProductResponse(response) else {
                self.displayAlert(alertTitle: "Error", alertMessage: "Failed to fetch product details.")
                return
            }
            
            DispatchQueue.main.async {
                //show proposal details in text fields
                self.populateFields(with: product)
            }
        }
    }
    private func parseProductResponse(_ data: Data?) -> Proposal? {
        guard let data = data else { return nil }
        do {
            return try JSONDecoder().decode(Proposal.self, from: data)
        } catch {
            print("Error decoding product data: \(error)")
            return nil
        }
    }
    
    private func populateFields(with proposalFields: Proposal) {
        proposalNo.text = proposalFields.proposalNo
        registrationNo.text = proposalFields.regNo
        CustomerID.text = proposalFields.customerID
        FromDate.text = proposalFields.fromDate
        ToDate.text = proposalFields.toDate
        Idv.text = String(proposalFields.idv)
        AgentID.text = proposalFields.agentID
        BasicAmount.text = String(proposalFields.basicAmount)
        TotalAmount.text = String(proposalFields.totalAmount)
    }

    private func createPolicyData() -> Proposal? {
        guard let proposalNumber = proposalNo.text, !proposalNumber.isEmpty,
              let registrationNo = registrationNo.text, !registrationNo.isEmpty,
              let prodId = ProductID.text, !prodId.isEmpty,
              let customerID = CustomerID.text, !customerID.isEmpty,
              let fromDate = FromDate.text, !fromDate.isEmpty,
              let toDate = ToDate.text, !toDate.isEmpty,
              let idv = Int(Idv.text!), (idv != 0),
              let agentID = AgentID.text, !agentID.isEmpty,
              let basicAmount = Int(BasicAmount.text!),
              let totalamount = Int(TotalAmount.text!) else {
        return nil
        }
        return Proposal(
            proposalNo: proposalNumber,
            regNo: registrationNo,
            productID: prodId,
            customerID: customerID,
            fromDate: fromDate,
            toDate: toDate,
            idv: idv,
            agentID: agentID,
            basicAmount: basicAmount,
            totalAmount: totalamount
            )
        }
    private func performRequest(
        endpoint: String,
        method: String,
        proposalData: Proposal? = nil,
        completion: @escaping (Data?) -> Void
    ) {
        guard let url = URL(string: endpoint) else {
            displayAlert(alertTitle: "Error", alertMessage: "Invalid URL.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let proposalData = proposalData {
            do {
                let jsonData = try JSONEncoder().encode(proposalData)
                request.httpBody = jsonData
            } catch {
                displayAlert(alertTitle: "Error", alertMessage: "Failed to encode product data.")
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
    private func getVehicleIds(){
        
    }
    private func getProductIds(){
        
    }
    private func getAgentIds(){
        
    }
    private func getCustomerIds(){
        
    }
    func displayAlert(alertTitle: String, alertMessage: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    
}
extension ProposalViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == FromDate || textField == ToDate {
            activeDateField = textField
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == activeDateField {
            activeDateField = nil
        }
    }
}
