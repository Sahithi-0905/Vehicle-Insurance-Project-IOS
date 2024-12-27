//
//  AgentsViewController.swift
//  VehicalInsuranceProject
//
//  Created by FCI on 20/12/24.
//

import UIKit

struct Agent: Codable {
    let agentID: String
    let agentName: String
    let agentPhone: String
    let agentEmail: String
    let licenseCode: String
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
       
       override func viewDidLoad() {
           super.viewDidLoad()
       }
       
       // MARK: - Button Actions
       
       @IBAction func saveAgent() {
           guard let agentData = createAgentData() else {
               displayAlert(alertTitle: "Error", alertMessage: "All fields must be filled.")
               return
           }
           
           performRequest(
               endpoint: "https://abzagentwebapi-akshitha.azurewebsites.net/api/Agent",
               method: "POST",
               agentData: agentData
           ) { response in
               self.displayAlert(alertTitle: "Success", alertMessage: "Agent saved successfully.")
           }
       }
       
       @IBAction func updateAgent() {
           guard let agentData = createAgentData(), let agentId = agentId.text else {
               displayAlert(alertTitle: "Error", alertMessage: "All fields must be filled, including Agent ID.")
               return
           }
           
           performRequest(
               endpoint: "https://abzagentwebapi-akshitha.azurewebsites.net/api/Agent/\(agentId)",
               method: "PUT",
               agentData: agentData
           ) { response in
               self.displayAlert(alertTitle: "Success", alertMessage: "Agent updated successfully.")
           }
       }
       
       @IBAction func showAgent() {
           guard let agentId = agentId.text, !agentId.isEmpty else {
               displayAlert(alertTitle: "Error", alertMessage: "Please enter an Agent ID.")
               return
           }
           
           performRequest(
               endpoint: "https://abzagentwebapi-akshitha.azurewebsites.net/api/Agent/\(agentId)",
               method: "GET"
           ) { response in
               guard let agent = self.parseAgentResponse(response) else {
                   self.displayAlert(alertTitle: "Error", alertMessage: "Failed to fetch agent details.")
                   return
               }
               
               DispatchQueue.main.async {
                   self.navigateToAgentDetails(with: agent)
               }
           }
       }
       
       @IBAction func deleteAgent() {
           guard let agentId = agentId.text, !agentId.isEmpty else {
               displayAlert(alertTitle: "Error", alertMessage: "Please enter an Agent ID.")
               return
           }
           
           performRequest(
               endpoint: "https://abzagentwebapi-akshitha.azurewebsites.net/api/Agent/\(agentId)",
               method: "DELETE"
           ) { _ in
               self.displayAlert(alertTitle: "Success", alertMessage: "Agent deleted successfully.")
           }
       }
       
       // MARK: - Navigation
       
       private func navigateToAgentDetails(with agent: Agent) {
           // Instantiate the AgentDetailsViewController from the storyboard
           guard let agentDetailsVC = storyboard?.instantiateViewController(withIdentifier: "AgentDetailsViewController") as? AgentDetailsViewController else {
               displayAlert(alertTitle: "Error", alertMessage: "Failed to load agent details screen.")
               return
           }
           
           // Pass the agent data to the details screen
           agentDetailsVC.agent = agent
           
           // Navigate to the AgentDetailsViewController
           navigationController?.pushViewController(agentDetailsVC, animated: true)
       }
       
       // MARK: - Helper Functions
       
       private func createAgentData() -> Agent? {
           guard let id = agentId.text, !id.isEmpty,
                 let name = agentName.text, !name.isEmpty,
                 let phone = agentPhone.text, !phone.isEmpty,
                 let email = agentEmail.text, !email.isEmpty,
                 let license = licenseCode.text, !license.isEmpty else {
               return nil
           }
           
           return Agent(
               agentID: id,
               agentName: name,
               agentPhone: phone,
               agentEmail: email,
               licenseCode: license
           )
       }
       
       private func performRequest(
           endpoint: String,
           method: String,
           agentData: Agent? = nil,
           completion: @escaping (Data?) -> Void
       ) {
           guard let url = URL(string: endpoint) else {
               displayAlert(alertTitle: "Error", alertMessage: "Invalid URL.")
               return
           }
           
           var request = URLRequest(url: url)
           request.httpMethod = method
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")
           
           if let agentData = agentData {
               do {
                   let jsonData = try JSONEncoder().encode(agentData)
                   request.httpBody = jsonData
               } catch {
                   displayAlert(alertTitle: "Error", alertMessage: "Failed to encode agent data.")
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
       
       private func parseAgentResponse(_ data: Data?) -> Agent? {
           guard let data = data else { return nil }
           do {
               return try JSONDecoder().decode(Agent.self, from: data)
           } catch {
               print("Error decoding agent data: \(error)")
               return nil
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

