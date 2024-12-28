import UIKit

// MARK: - Policy Model
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
    
    let accessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoibm4iLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJtbSIsImV4cCI6MTczNTM4NjQyMSwiaXNzIjoiaHR0cHM6Ly93d3cudGVhbTIuY29tIiwiYXVkIjoiaHR0cHM6Ly93d3cudGVhbTIuY29tIn0.yZbVCj2bGuCvFcIcGyR9Nt9fdDhV9JGd6fu-aEZzYTE"
    
    let baseURL = "https://abzpolicywebapi-akshitha.azurewebsites.net/api/Policy"
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
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
        guard let url = URL(string: "\(baseURL)/\(accessToken)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
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
        guard let url = URL(string: "\(baseURL)/\(policy.policyNumber)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(policy)
        
        performRequest(request, action: "default") { success in
            self.showAlert(message: success ? "Policy updated successfully" : "Failed to update policy")
        }
    }
    
    private func fetchPolicy(policyNumber: String) {
        guard let url = URL(string: "\(baseURL)/\(policyNumber)") else { return }
        
        let request = URLRequest(url: url)
        
        performRequestWithData(request) { data in
            guard let data = data else {
                DispatchQueue.main.async {
                    self.showAlert(message: "Failed to fetch policy")
                }
                return
            }
            
            do {
                let policy = try JSONDecoder().decode(Policy.self, from: data)
                DispatchQueue.main.async {
                    self.navigateToPolicyDisplay(with: policy)
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(message: "Failed to parse policy data")
                }
            }
        }
    }
    
    private func deletePolicy(policyNumber: String) {
        guard let url = URL(string: "\(baseURL)/\(policyNumber)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        performRequest(request, action: "delete") { success in
            if success {
                self.showAlert(message: "Policy deleted successfully!")
            } else {
                self.showAlert(message: "Failed to delete policy!")
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
              let noClaim = noClaimBonus.text, !noClaim.isEmpty,
              let receiptNo = receiptNumber.text, !receiptNo.isEmpty,
              let receiptDateText = receiptDate.text, !receiptDateText.isEmpty,
              let paymentModeText = paymentMode.text, !paymentModeText.isEmpty,
              let amountText = amount.text, !amountText.isEmpty else { return nil }
        
        return Policy(policyNumber: policyNo, proposalNumber: proposalNo, noClaimBonus: noClaim, receiptNumber: receiptNo, receiptDate: receiptDateText, paymentMode: paymentModeText, amount: amountText)
    }
    
    private func navigateToPolicyDisplay(with policy: Policy) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let displayVC = storyboard.instantiateViewController(withIdentifier: "showPolicyID") as? PolicyDetailsViewController else {
            showAlert(message: "Unable to navigate to Policy Display")
            return
        }
        displayVC.policy = policy
        navigationController?.present(displayVC, animated: true)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

