//
//  AgentsViewController.swift
//  VehicalInsuranceProject
//
//  Created by FCI on 20/12/24.
//

import UIKit

// MARK: - Agent Model
struct Agent: Codable {
    var agentID: String
    var agentName: String
    var agentPhone: String
    var agentEmail: String
    var licenseCode: String
}

class AgentsViewController: UIViewController {
    
    @IBOutlet var agentId: UITextField!
    @IBOutlet var agentName: UITextField!
    @IBOutlet var agentPhone: UITextField!
    @IBOutlet var agentEmail: UITextField!
    @IBOutlet var licenseCode: UITextField!
    @IBOutlet var save: UIButton!
    @IBOutlet var update: UIButton!
    @IBOutlet var show: UIButton!
    @IBOutlet var delete: UIButton!
    
    let baseURL = "https://abzagentwebapi-akshitha.azurewebsites.net/api/Agent"
    let accessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoic2RmZ2giLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJkdGZoZyIsImV4cCI6MTczNjAyNjIxMywiaXNzIjoiaHR0cHM6Ly93d3cudGVhbTIuY29tIiwiYXVkIjoiaHR0cHM6Ly93d3cudGVhbTIuY29tIn0.GhMzdT9oRgA7QW_xlWa2Qv-Nhhghp_GqwYRdRIrX0UU"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    // MARK: - IBActions
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let agent = getAgentFromFields() else {
            showAlert(message: "Please fill all fields")
            return
        }
        saveAgent(agent: agent)
    }
    
    @IBAction func updateButtonTapped(_ sender: UIButton) {
        guard let agent = getAgentFromFields() else {
            showAlert(message: "Please fill all fields")
            return
        }
        updateAgent(agent: agent)
    }
    
    @IBAction func showButtonTapped(_ sender: UIButton) {
        guard let id = agentId.text, !id.isEmpty else {
            showAlert(message: "Please enter the agent ID to fetch details")
            return
        }
        fetchAgent(agentId: id)
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        guard let id = agentId.text, !id.isEmpty else {
            showAlert(message: "Please enter the agent ID to delete")
            return
        }
        deleteAgent(id: id)
    }
    
    // MARK: - API Methods
    private func saveAgent(agent: Agent) {
        guard let url = URL(string: "\(baseURL)/\(AppConstants.bearerToken)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        do {
            let requestBody = try JSONEncoder().encode(agent)
            request.httpBody = requestBody
        } catch {
            print("Error encoding agent: \(error)")
            return
        }
        
        performRequest(request, action: "save") { success in
            DispatchQueue.main.async{
                if success {
                    self.showAlert(message: "Agent saved successfully!")
                } else {
                    self.showAlert(message: "Failed to save agent. Please try again.")
                }
            }
        }
    }
    
    private func updateAgent(agent: Agent) {
        guard let id = agentId.text, let url = URL(string: "\(baseURL)/\(id)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(agent)
        
        performRequest(request, action: "update") { success in
            DispatchQueue.main.async {
                self.showAlert(message: success ? "Agent updated successfully!" : "Failed to update agent.")
            }
        }
    }
    
    private func fetchAgent(agentId: String) {
        guard !agentId.isEmpty else {
            DispatchQueue.main.async {
                self.showAlert(message: "Please enter a valid Agent ID.")
            }
            return
        }

        guard let url = URL(string: "\(baseURL)/\(agentId)") else {
            DispatchQueue.main.async {
                self.showAlert(message: "Invalid URL")
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
                    self.showAlert(message: "Network Error: \(error.localizedDescription)")
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }

            guard let data = data else {
                print("No data received.")
                DispatchQueue.main.async {
                    self.showAlert(message: "No data received.")
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
                        self.showAlert(message: "Unexpected response format.")
                    }
                }
            } catch {
                print("Decoding Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert(message: "Failed to parse agent data.")
                }
            }
        }.resume()
    }
    
    private func deleteAgent(id: String) {
        guard let url = URL(string: "\(baseURL)/\(id)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        performRequest(request, action: "delete") { success in
            DispatchQueue.main.async {
                self.showAlert(message: success ? "Agent deleted successfully!" : "Failed to delete agent.")
            }
        }
    }
    
    private func performRequest(_ request: URLRequest, action: String, completion: @escaping (Bool) -> Void) {
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("Request Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            completion(true)
        }.resume()
    }
    
    // MARK: - Helper Methods
    private func getAgentFromFields() -> Agent? {
        guard let id = agentId.text, !id.isEmpty,
              let name = agentName.text, !name.isEmpty,
              let phone = agentPhone.text, !phone.isEmpty,
              let email = agentEmail.text, !email.isEmpty,
              let licenseCode = licenseCode.text, !licenseCode.isEmpty else {
            return nil
        }
        
        return Agent(agentID: id, agentName: name, agentPhone: phone, agentEmail: email, licenseCode: licenseCode)
    }
    
    
    private func populateTextFieldsFromJSON(_ jsonResponse: [String: Any]) {
        // Use safe optional binding to ensure keys are correct in the JSON response
        if let agentID = jsonResponse["agentID"] as? String {
            self.agentId.text = agentID
        }

        if let agentName = jsonResponse["agentName"] as? String {
            self.agentName.text = agentName
        }

        if let agentPhone = jsonResponse["agentPhone"] as? String {
            self.agentPhone.text = agentPhone
        }

        if let agentEmail = jsonResponse["agentEmail"] as? String {
            self.agentEmail.text = agentEmail
        }

        if let licenseCode = jsonResponse["licenseCode"] as? String {
            self.licenseCode.text = licenseCode
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

    

