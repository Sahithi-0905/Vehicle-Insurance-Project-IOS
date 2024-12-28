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
    
    let accessToken="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoibm4iLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJtbSIsImV4cCI6MTczNTM4NjQyMSwiaXNzIjoiaHR0cHM6Ly93d3cudGVhbTIuY29tIiwiYXVkIjoiaHR0cHM6Ly93d3cudGVhbTIuY29tIn0.yZbVCj2bGuCvFcIcGyR9Nt9fdDhV9JGd6fu-aEZzYTE"
    
    let baseURL = "https://abzagentwebapi-akshitha.azurewebsites.net/api/Agent"
    
    
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
           fetchAgent(id: id)
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
           guard let url = URL(string: "\(baseURL)/\(accessToken)") else {
               print("Invalid URL")
               return
           }

           var request = URLRequest(url: url)
           request.httpMethod = "POST"
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")
           request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

           do {
               let requestBody = try JSONEncoder().encode(agent)
               request.httpBody = requestBody
           } catch {
               print("Error encoding agent: \(error)")
               return
           }

           performRequest(request, action: "save") { success in
               if success {
                   self.showAlert(message: "Agent saved successfully!")
               } else {
                   self.showAlert(message: "Failed to save agent. Please try again.")
               }
           }
       }

       private func updateAgent(agent: Agent) {
           guard let id = agentId.text, let url = URL(string: "\(baseURL)/\(id)") else { return }

           var request = URLRequest(url: url)
           request.httpMethod = "PUT"
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")
           request.httpBody = try? JSONEncoder().encode(agent)

           performRequest(request, action: "update") { success in
               self.showAlert(message: success ? "Agent updated successfully!" : "Failed to update agent.")
           }
       }

       private func fetchAgent(id: String) {
           guard let url = URL(string: "\(baseURL)/\(id)") else { return }

           let request = URLRequest(url: url)

           performRequestWithData(request) { data in
               guard let data = data else {
                   self.showAlert(message: "Failed to fetch agent")
                   return
               }

               do {
                   let agent = try JSONDecoder().decode(Agent.self, from: data)
                   self.navigateToAgentDisplay(with: agent)
               } catch {
                   self.showAlert(message: "Failed to parse agent data")
               }
           }
       }

       private func deleteAgent(id: String) {
           guard let url = URL(string: "\(baseURL)/\(id)") else { return }

           var request = URLRequest(url: url)
           request.httpMethod = "DELETE"

           performRequest(request, action: "delete") { success in
               self.showAlert(message: success ? "Agent deleted successfully!" : "Failed to delete agent.")
           }
       }

       private func performRequest(_ request: URLRequest, action: String, completion: @escaping (Bool) -> Void) {
           URLSession.shared.dataTask(with: request) { _, response, error in
               if let error = error {
                   print("Request Error: \(error.localizedDescription)")
                   completion(false)
                   return
               }

               guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                   completion(false)
                   return
               }

               completion(true)
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

       private func navigateToAgentDisplay(with agent: Agent) {
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
           guard let displayVC = storyboard.instantiateViewController(withIdentifier: "agid") as? AgentDetailsViewController else {
               showAlert(message: "Unable to navigate to Agent Display")
               return
           }
           displayVC.agent = agent
           navigationController?.pushViewController(displayVC, animated: true)
       }

       private func showAlert(message: String) {
           let alert = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default))
           present(alert, animated: true)
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

