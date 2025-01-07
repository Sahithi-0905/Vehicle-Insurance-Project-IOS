import UIKit

// MARK: - Policy Model
struct Policy: Codable {
    let policyNo: String
    let proposalNo: String
    let noClaimBonus: Int
    let receiptNo: String
    let receiptDate: String
    let paymentMode: String
    let amount: Int
}

class PolicyViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet var policyNumber: UITextField!
    @IBOutlet var proposalNumber: UITextField!
    @IBOutlet var noClaimBonus: UITextField!
    @IBOutlet var receiptNumber: UITextField!
    @IBOutlet var receiptDate: UITextField!
    @IBOutlet var paymentMode: UITextField!
    @IBOutlet var amount: UITextField!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var updateButton: UIButton!
    @IBOutlet var showButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    
    var token: String=" "
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        AppConstants.generateToken { success in
            DispatchQueue.main.async {
                if success {
                    self.token=AppConstants.bearerToken
                    print("Token generated successfully: \(AppConstants.bearerToken)")
                    
                } else {
                    print("Failed to generate token")
                    self.showAlert(message: "no token")
                }
            }
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let policy = getPolicyFromFields() else {
            showAlert(message: "Please fill all fields")
            return
        }
        savePolicy(policy: policy)
    }
    
    @IBAction func updateButtonTapped(_ sender: UIButton) {
        guard let policy = getPolicyFromFields() else {
            showAlert(message: "Please fill all fields")
            return
        }
        updatePolicy(policy: policy)
    }
    
    @IBAction func showButtonTapped(_ sender: UIButton) {
        guard let policyNo = policyNumber.text, !policyNo.isEmpty else {
            showAlert(message: "Please enter the policy number to fetch details")
            return
        }
        fetchPolicy(policyNumber: policyNo)
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        guard let policyNo = policyNumber.text, !policyNo.isEmpty else {
            showAlert(message: "Please enter the policy number to delete")
            return
        }
        deletePolicy(policyNumber: policyNo)
    }
    // MARK: - API Methods
    private func savePolicy(policy: Policy) {
        guard let url = URL(string: "\(AppConstants.policyAPI)/api/Policy/\(AppConstants.bearerToken)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(AppConstants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        do {
            let requestBody = try JSONEncoder().encode(policy)
            request.httpBody = requestBody
        } catch {
            print("Error encoding policy: \(error)")
            return
        }
        
        performRequest(request, action: "save") { success in
            DispatchQueue.main.async {
                if success {
                    self.showAlert(message: "Policy saved successfully!")
                } else {
                    self.showAlert(message: "Failed to save policy. Please try again.")
                }
            }
        }
    }
    
    private func updatePolicy(policy: Policy) {
        guard let url = URL(string: "\(AppConstants.policyAPI)/api/Policy/\(policy.policyNo)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(AppConstants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(policy)
        
        performRequest(request, action: "default") { success in
            DispatchQueue.main.async {
                self.showAlert(message: success ? "Policy updated successfully" : "Failed to update policy")
            }
        }
    }
    
    private func fetchPolicy(policyNumber: String) {
        guard !policyNumber.isEmpty else {
                showAlert(message: "Please enter a valid policy number.")
                return
            }
            
            // Step 2: Construct the URL for the API request
            guard let url = URL(string: "\(AppConstants.policyAPI)/api/Policy/\(policyNumber)") else {
                showAlert(message: "Invalid URL for fetching policy.")
                return
            }
            
            // Log the constructed URL
            print("Fetching policy from URL: \(url)")
            
            // Step 3: Prepare the URLRequest with necessary headers
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Step 4: Check if the bearer token is valid
            if AppConstants.bearerToken.isEmpty {
                showAlert(message: "Bearer token is missing or invalid.")
                print("Error: Bearer token is missing or invalid.")
                return
            } else {
                print("Bearer Token: \(AppConstants.bearerToken)")
            }
            
            // Step 5: Perform the network request
            URLSession.shared.dataTask(with: request) { data, response, error in
                
                // Step 6: Handle network error
                if let error = error {
                    print("Network Error: \(error.localizedDescription)") // Log error
                    DispatchQueue.main.async {
                        self.showAlert(message: "Network Error: \(error.localizedDescription)")
                    }
                    return
                }
                
                // Step 7: Handle response status code
                if let httpResponse = response as? HTTPURLResponse {
                    print("HTTP Status Code: \(httpResponse.statusCode)") // Log status code
                    
                    switch httpResponse.statusCode {
                    case 200...299:
                        // Success: Proceed to parse the response data
                        if let data = data {
                            do {
                                // Step 8: Decode the response data into a Policy object
                                let policy = try JSONDecoder().decode(Policy.self, from: data)
                                DispatchQueue.main.async {
                                    // Step 9: Populate the UI fields with the fetched policy data
                                    self.populateFields(with: policy)
                                }
                            } catch {
                                // Step 10: Handle JSON decoding failure
                                print("JSON Decoding Error: \(error.localizedDescription)") // Log error
                                DispatchQueue.main.async {
                                    self.showAlert(message: "Failed to parse policy data. Please try again.")
                                }
                            }
                        }
                        
                    case 400...499:
                        // Client-side error (e.g., 404 Not Found)
                        DispatchQueue.main.async {
                            self.showAlert(message: "Policy not found. Please check the policy number.")
                        }
                        
                    case 500...599:
                        // Server-side error
                        DispatchQueue.main.async {
                            self.showAlert(message: "Server error occurred. Please try again later.")
                        }
                        
                    default:
                        // Handle unexpected status codes
                        DispatchQueue.main.async {
                            self.showAlert(message: "Request failed with status code: \(httpResponse.statusCode)")
                        }
                    }
                } else {
                    // Step 11: Handle invalid or no response
                    DispatchQueue.main.async {
                        self.showAlert(message: "Invalid or no response from the server.")
                    }
                }
            }.resume()
    }
    
    private func deletePolicy(policyNumber: String) {
        guard let url = URL(string: "\(AppConstants.policyAPI)/api/Policy/\(policyNumber)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(AppConstants.bearerToken)", forHTTPHeaderField: "Authorization")
        performRequest(request, action: "delete") { success in
            DispatchQueue.main.async {
                if success {
                    self.showAlert(message: "Policy deleted successfully!")
                } else {
                    self.showAlert(message: "Failed to delete policy!")
                }
            }
            
        }
    }
    
    private func performRequest(_ request: URLRequest, action: String, completion: @escaping (Bool) -> Void) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Request Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert(message: "Network Error: \(error.localizedDescription)")
                }
                completion(false)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200...299: // Success range
                    DispatchQueue.main.async {
                        print("Success Bearer Token: \(AppConstants.bearerToken)")
                        switch action {
                        case "save":
                            self.showAlert(message: "Policy saved successfully!")
                        case "delete":
                            self.showAlert(message: "Policy deleted successfully!")
                        default:
                            self.showAlert(message: "Action performed successfully!")
                        }
                    }
                    completion(true)
                default:
                    DispatchQueue.main.async {
                        self.showAlert(message: "Failed to perform action. Status code: \(httpResponse.statusCode)")
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
    private func getPolicyFromFields() -> Policy? {
        guard let policyNo = policyNumber.text, !policyNo.isEmpty,
              let proposalNo = proposalNumber.text, !proposalNo.isEmpty,
              let noClaim = Int(noClaimBonus.text!),
              let receiptNo = receiptNumber.text, !receiptNo.isEmpty,
              let receiptDateText = receiptDate.text, !receiptDateText.isEmpty,
              let paymentModeText = paymentMode.text, !paymentModeText.isEmpty,
              let amountText = Int(amount.text!) else { return nil }
       
        
        return Policy(policyNo: policyNo, proposalNo: proposalNo, noClaimBonus: noClaim, receiptNo: receiptNo, receiptDate: receiptDateText, paymentMode: paymentModeText, amount: amountText)
    }
    
    private func populateFields(with policy: Policy) {
        policyNumber.text = policy.policyNo
        proposalNumber.text = policy.proposalNo
        noClaimBonus.text = String(policy.noClaimBonus)
        receiptNumber.text = policy.receiptNo
        receiptDate.text = policy.receiptDate
        paymentMode.text=policy.paymentMode
        amount.text = String(policy.amount)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
