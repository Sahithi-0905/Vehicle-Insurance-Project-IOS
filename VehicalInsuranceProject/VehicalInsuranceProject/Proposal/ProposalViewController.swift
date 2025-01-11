//
//  ProposalViewController.swift
//  VehicalInsuranceProject
//
//  Created by shamitha on 26/12/24.
//

import UIKit

//proposal structure
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
class ProposalViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //Outlets for text fields,buttons
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
    
    //picker views
    var vehiclePicker: UIPickerView!
    var productPicker: UIPickerView!
    var agentPicker: UIPickerView!
    var customerPicker: UIPickerView!
    
    // Arrays to store IDs fetched from API
    var vehiclesList:[String] =  []
    var productsList:[String] =  []
    var agentsList:[String] =  []
    var customersList:[String] =  []
    
    private var datePicker: UIDatePicker!
    var activeDateField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AppConstants.generateToken { success in
            DispatchQueue.main.async {
                if success {
                    print("Token generated successfully: \(AppConstants.bearerToken)")
                    
                    self.getVehicleIds()
                    self.getProductIds()
                    self.getAgentIds()
                    self.getCustomerIds()
                } else {
                    print("Failed to generate token")
                    self.displayAlert(
                        alertTitle: "Error",
                        alertMessage: "Failed to generate token. Please try again."
                    )
                }
            }
        }
        
        setupDatePicker()
        
        let toolbar2 = UIToolbar()
        toolbar2.sizeToFit()
        let done2 = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissFunc))
        toolbar2.setItems([done2], animated: true)
        
        //picker views to display ids
        vehiclePicker = UIPickerView()
        vehiclePicker.delegate = self
        vehiclePicker.dataSource = self
        registrationNo.inputView = vehiclePicker
        registrationNo.inputAccessoryView = toolbar2
        
        productPicker = UIPickerView()
        productPicker.delegate = self
        productPicker.dataSource = self
        ProductID.inputView = productPicker
        ProductID.inputAccessoryView = toolbar2

        agentPicker = UIPickerView()
        agentPicker.delegate = self
        agentPicker.dataSource = self
        AgentID.inputView = agentPicker
        AgentID.inputAccessoryView = toolbar2
        
        customerPicker = UIPickerView()
        customerPicker.delegate = self
        customerPicker.dataSource = self
        CustomerID.inputView = customerPicker
        CustomerID.inputAccessoryView = toolbar2

    }
    
    //date picker
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
    func formatDateToMilliseconds(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date)
    }

    @objc func datePickerValueChanged() {
        guard let activeField = activeDateField else { return }
        activeField.text = formatDateToMilliseconds(datePicker.date)
        view.endEditing(true)
    }
    
    // MARK: - Button Actions to Save Proposal
    @IBAction func saveProposal() {
        guard let proposalData = createPolicyData() else {
            displayAlert(alertTitle: "Error", alertMessage: "All fields must be filled.")
            return
        }
        
        performRequest(
            endpoint: "\(AppConstants.proposalAPI)/api/Proposal/\(AppConstants.bearerToken)",
            method: "POST",
            proposalData: proposalData
        ) { response in
            self.displayAlert(alertTitle: "Success", alertMessage: "Proposal saved successfully.")
        }
    }
    
    // MARK: - Button Actions to update Proposal
    @IBAction func updateProposal() {
        guard let proposalData = createPolicyData(), let proposalId = proposalNo.text else {
            displayAlert(alertTitle: "Error", alertMessage: "All fields must be filled.")
            return
        }
        
        performRequest(
            endpoint: "\(AppConstants.proposalAPI)/api/Proposal/\(proposalId)",
            method: "PUT",
            proposalData: proposalData
        ) { response in
            self.displayAlert(alertTitle: "Success", alertMessage: "Proposal updated successfully.")
        }
    }
    
    // MARK: - Button Actions to Delete Proposal
    @IBAction func deleteProposal() {
        guard let proposalId = proposalNo.text, !proposalId.isEmpty else {
            displayAlert(alertTitle: "Error", alertMessage: "Please enter a Product ID.")
            return
        }
        
        performRequest(
            endpoint: "\(AppConstants.proposalAPI)/api/Proposal/\(proposalId)",
            method: "DELETE"
        ) { response in
            self.displayAlert(alertTitle: "Success", alertMessage: "Proposal deleted successfully.")
        }
    }
    
    // MARK: - Button Actions to Show Proposal
    @IBAction func showProposalDetails(){
        guard let proposalId = proposalNo.text, !proposalId.isEmpty else {
            displayAlert(alertTitle: "Error", alertMessage: "Please enter a Proposal ID.")
            return
        }
        
        performRequest(
            endpoint: "\(AppConstants.proposalAPI)/api/Proposal/\(proposalId)",
            method: "GET"
        ) { response in
            guard let proposalFields = self.parseProductResponse(response) else {
                self.displayAlert(alertTitle: "Error", alertMessage: "Failed to fetch product details.")
                return
            }
            
            DispatchQueue.main.async {
                //show proposal details in text fields
                self.populateFields(with: proposalFields)
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
    
    //function to add existing data to text fields when clicked show button
    private func populateFields(with proposalFields: Proposal) {
        proposalNo.text = proposalFields.proposalNo
        registrationNo.text = proposalFields.regNo
        ProductID.text = proposalFields.productID
        CustomerID.text = proposalFields.customerID
        FromDate.text = proposalFields.fromDate
        ToDate.text = proposalFields.toDate
        Idv.text = String(proposalFields.idv)
        AgentID.text = proposalFields.agentID
        BasicAmount.text = String(proposalFields.basicAmount)
        TotalAmount.text = String(proposalFields.totalAmount)
    }

    //function to creates a Proposal object if all required text fields are non-empty; otherwise, it returns nil.
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
    
    //function to performs an HTTP request with the given endpoint, method, and optional product data
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
        request.setValue("Bearer \(AppConstants.bearerToken)", forHTTPHeaderField: "Authorization")
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
    // MARK: - Function to fetch VehicleIds
    private func getVehicleIds(){
        //Create the URL Request
        let url = URL(string: "\(AppConstants.vehicleAPI)/api/Vehicle")! // Replace with your API URL
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(AppConstants.bearerToken)", forHTTPHeaderField: "Authorization")

        //Perform the API Request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server error")
                if let data = data {
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                        print("Response: \(jsonResponse)")
                    } catch {
                        print("Failed to decode response: \(error.localizedDescription)")
                    }
                }
                return
            }
            print("Getting the Response")
            
            if let data = data {
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                        print("Response: \(jsonResponse)")
                        for vehicle in jsonResponse{
                            if let vehicleID = vehicle["regNo"] as? String {
                                print("Vehicle ID: \(vehicleID)")
                                self.vehiclesList.append(vehicleID)
                            }
                            else {
                                    print("productID not found for product: \(vehicle)")
                                }

                       }

                    }
                } catch {
                    print("Failed to decode response: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
    // MARK: - Function to fetch Product Ids
    private func getProductIds(){
        //Create the URL Request
        let url = URL(string: "\(AppConstants.productAPI)/api/Product")! // Replace with your API URL
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(AppConstants.bearerToken)", forHTTPHeaderField: "Authorization")


        //Perform the API Request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server error")
                if let data = data {
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                        print("Response: \(jsonResponse)")
                        
                    } catch {
                        print("Failed to decode response: \(error.localizedDescription)")
                    }
                }
                return
            }
            print("Getting the Response")
            
            if let data = data {
                do {
                    
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                        print("Response: \(jsonResponse)")
                        for product in jsonResponse{
                            if let productID = product["productID"] as? String {
                                print("Product ID: \(productID)")
                                self.productsList.append(productID)
                            }
                            else {
                                print("productID not found for product: \(product)")
                            }
                            
                        }
                        
                    }
                } catch {
                    print("Failed to decode response: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
    
    // MARK: - Function to fetch Agent Ids
    private func getAgentIds(){
        //Create the URL Request
        let url = URL(string: "\(AppConstants.agentAPI)/api/Agent")! // Replace with your API URL
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(AppConstants.bearerToken)", forHTTPHeaderField: "Authorization")
        
        
        //Perform the API Request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server error")
                if let data = data {
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                        print("Response: \(jsonResponse)")
                    } catch {
                        print("Failed to decode response: \(error.localizedDescription)")
                    }
                }
                return
            }
            print("Getting the Response")
            
            if let data = data {
                do {
                    
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                        print("Response: \(jsonResponse)")
                        for agent in jsonResponse{
                            if let agentID = agent["agentID"] as? String {
                                print("Agent ID: \(agentID)")
                                self.agentsList.append(agentID)
                            }
                            else {
                                print("Agent ID not found for product: \(agent)")
                            }
                            
                        }
                    }
                } catch {
                    print("Failed to decode response: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
    
    // MARK: - Function to fetch Customer Ids
    private func getCustomerIds(){
        //Create the URL Request
        let url = URL(string: "\(AppConstants.customerAPI)/api/Customer")! // Replace with your API URL
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(AppConstants.bearerToken)", forHTTPHeaderField: "Authorization")


        //Perform the API Request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server error")
                if let data = data {
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                        print("Response: \(jsonResponse)")
                    } catch {
                        print("Failed to decode response: \(error.localizedDescription)")
                    }
                }
                return
            }
            print("Getting the Response")
            
            if let data = data {
                do {
                    
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                        print("Response: \(jsonResponse)")
                        for customer in jsonResponse{
                            if let customerID = customer["customerID"] as? String {
                                print("Customer ID: \(customerID)")
                                self.customersList.append(customerID)
                            }
                            else {
                                print("Customer ID not found for product: \(customer)")
                            }
                            
                        }
                    }

                } catch {
                    print("Failed to decode response: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
        
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == vehiclePicker{
            return vehiclesList.count
        }else if pickerView == productPicker{
            return productsList.count
        }else if pickerView == customerPicker {
            return customersList.count
        }else if pickerView == agentPicker {
            return agentsList.count
        }
        return 0
    }
        
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == vehiclePicker{
            return vehiclesList[row]
        }else if pickerView == productPicker{
            return productsList[row]
        }else if pickerView == customerPicker {
            return customersList[row]
        }else if pickerView == agentPicker {
            return agentsList[row]
        }
            return nil
        }
        
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == vehiclePicker{
            registrationNo.text = vehiclesList[row]
        }else if pickerView == productPicker {
            ProductID.text = productsList[row]
        }else if pickerView == customerPicker {
            CustomerID.text = customersList[row]
        }else if pickerView == agentPicker {
            AgentID.text = agentsList[row]
        }

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
