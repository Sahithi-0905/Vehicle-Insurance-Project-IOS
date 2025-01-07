//
//  QueryResponseViewController.swift
//  VehicalInsuranceProject
//
//  Created by FCI on 31/12/24.
//

import UIKit
struct QueryResponses: Codable {
    let queryID: String
    let srNo: String
    let agentID: String
    let description: String
    let responseDate: String
    
}
class QueryResponseViewController: UIViewController {
    
    @IBOutlet var queryIDField: UITextField!
    @IBOutlet var srNumberField: UITextField!
    @IBOutlet var agentIDField: UITextField!
    @IBOutlet var descriptionField: UITextField!
    @IBOutlet var responseDateField: UITextField!
    
    @IBOutlet var save: UIButton!
    @IBOutlet var update: UIButton!
    @IBOutlet var show: UIButton!
    @IBOutlet var delete: UIButton!
    var token:String = " "
    var propickerView : UIPickerView!
    var dp1: UIDatePicker!
    var df1: DateFormatter!

    var ids: [String] = [] // Array to store IDs fetched from API
    var id: String!
   
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
        // Do any additional setup after loading the view.
        dp1 = UIDatePicker()
        dp1.datePickerMode = .date
        dp1.preferredDatePickerStyle = .inline
        dp1.addTarget(self, action: #selector(dp1Click), for: .valueChanged)
        responseDateField.inputView = dp1
        // Do any additional setup after loading the view.
    }
    
    @objc func dp1Click() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS" // ISO 8601 format with milliseconds
        
        // Convert the selected date into the formatted string
        let formattedDate = dateFormatter.string(from: dp1.date)
        
        // Set the formatted date string to the regDate text field
        responseDateField.text = formattedDate
    }
    @IBAction func saveResonse() {
        guard let getqueryData = createProductData() else {
            displayAlert(alertTitle: "Error", alertMessage: "All fields must be filled.")
            return
        }
        
        performRequest(
            endpoint: "\(AppConstants.queryAPI)/api/QueryResponse",
            method: "POST",
            queryData: getqueryData
        ) { response in
            self.displayAlert(alertTitle: "Success", alertMessage: "Query saved successfully.")
        }
    }
    @IBAction func updateResonse() {
        guard let getqueryData = createProductData(),
        let queryId = queryIDField.text, !queryId.isEmpty,
        let srNum = srNumberField.text, !srNum.isEmpty else {
            displayAlert(alertTitle: "Error", alertMessage: "Please enter a Query ID and Srnumber.")
            return
        }
        
        performRequest(
            endpoint: "\(AppConstants.queryAPI)/api/QueryResponse/\(queryId)/\(srNum)",
            method: "PUT",
            queryData: getqueryData
        ) { response in
            self.displayAlert(alertTitle: "Success", alertMessage: "Query updated successfully.")
        }
    }
        
    @IBAction func showResonse() {
        guard let queryId = queryIDField.text, !queryId.isEmpty,
        let srNum = srNumberField.text, !srNum.isEmpty else {
            displayAlert(alertTitle: "Error", alertMessage: "Please enter a Query ID and Srnumber.")
            return
        }
        
        performRequest(
            endpoint: "\(AppConstants.queryAPI)/api/QueryResponse/\(queryId)/\(srNum)",
            method: "GET"
        ) { response in
            guard let product = self.parseProductResponse(response) else {
                self.displayAlert(alertTitle: "Error", alertMessage: "Failed to fetch Query details.")
                return
            }
            
            DispatchQueue.main.async {
            
                self.populateFields(with: product)
            }
        }
    }

    
    private func createProductData() -> QueryResponses? {
        guard let queryID = queryIDField.text, !queryID.isEmpty,
              let srNo = srNumberField.text, !srNo.isEmpty,
              let agentID = agentIDField.text, !agentID.isEmpty,
              let description = descriptionField.text, !description.isEmpty,
              let responseDate = responseDateField.text, !responseDate.isEmpty else {
            return nil
        }
        
        return QueryResponses(
            queryID: queryID,
            srNo: srNo,
            agentID: agentID,
            description: description,
            responseDate: responseDate
        )
    }
        
    private func performRequest(
            endpoint: String,
            method: String,
            queryData: QueryResponses? = nil,
            completion: @escaping (Data?) -> Void
    ) {
        guard let url = URL(string: endpoint) else {
            displayAlert(alertTitle: "Error", alertMessage: "Invalid URL.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let queryEncodeData = queryData {
            do {
                let jsonData = try JSONEncoder().encode(queryEncodeData)
                request.httpBody = jsonData
            } catch {
                displayAlert(alertTitle: "Error", alertMessage: "Failed to encode QueryResponses data.")
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
    private func parseProductResponse(_ data: Data?) -> QueryResponses? {
        guard let data = data else { return nil }
        do {
            return try JSONDecoder().decode(QueryResponses.self, from: data)
        } catch {
            print("Error decoding product data: \(error)")
            return nil
        }
    }
    
    
    private func populateFields(with querystruct: QueryResponses) {
        queryIDField.text = querystruct.queryID
        srNumberField.text = querystruct.srNo
        agentIDField.text = querystruct.agentID
        descriptionField.text = querystruct.description
        responseDateField.text = querystruct.responseDate
    }
    func displayAlert(alertTitle: String, alertMessage: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }

}
