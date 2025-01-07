import UIKit

// MARK: - Customer Model
struct Customer: Codable {
    var customerID: String
    var customerName: String
    var customerPhone: String
    var customerEmail: String
    var customerAddress: String
}

class CustomerDetailsViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet var CusID: UITextField!
    @IBOutlet var CusName: UITextField!
    @IBOutlet var PhoneNo: UITextField!
    @IBOutlet var Email: UITextField!
    @IBOutlet var Address: UITextField!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var updateButton: UIButton!
    @IBOutlet var showButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    
    private var ids: [String] = []
    
    let baseURL = "https://abzcustomerwebapi-akshitha.azurewebsites.net/api/Customer"
    let accessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoibm4iLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJtbSIsImV4cCI6MTczNjI2ODg3MywiaXNzIjoiaHR0cHM6Ly93d3cudGVhbTIuY29tIiwiYXVkIjoiaHR0cHM6Ly93d3cudGVhbTIuY29tIn0.Pl6GkdPQqroIVN_U3SVk8wwLTQCeeDNkS2Mveor4Ays"
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let customer = getCustomerFromFields() else {
            showAlert(message: "Please fill all fields")
            return
        }
        saveCustomer(customer: customer)
    }
    
    @IBAction func updateButtonTapped(_ sender: UIButton) {
        guard let customer = getCustomerFromFields() else {
            showAlert(message: "Please fill all fields")
            return
        }
        updateCustomer(customer: customer)
    }
    
    @IBAction func showButtonTapped(_ sender: UIButton) {
        guard let id = CusID.text, !id.isEmpty else {
            showAlert(message: "Please enter the customer ID to fetch details")
            return
        }
        showCustomer(customerID: id)
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        guard let id = CusID.text, !id.isEmpty else {
            showAlert(message: "Please enter the customer ID to delete")
            return
        }
        deleteCustomer(id: id)
    }
    
    // MARK: - API Methods
    private func saveCustomer(customer: Customer) {
        

        guard let url = URL(string: "\(baseURL)/\(accessToken)") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                
        do {
            let requestBody = try JSONEncoder().encode(customer)
            request.httpBody = requestBody
        } catch {
            print("Error encoding customer: \(error)")
            return
        }

        performRequest(request, action: "save") { success in
            DispatchQueue.main.async {
                if success {
                    self.showAlert(message: "Customer saved successfully!")
                } else {
                    self.showAlert(message: "Failed to save customer. Please try again.")
                }
            }
        }
    }

    private func updateCustomer(customer: Customer) {
        guard let url = URL(string: "\(baseURL)/\(CusID.text!)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(customer)
        
        performRequest(request,action: "default") { success in
            self.showAlert(message: success ? "Customer updated successfully" : "Failed to update customer")
        }
    }
    private func showCustomer(customerID: String) {
        guard !customerID.isEmpty else {
            DispatchQueue.main.async {
                self.showAlert( message: "Please enter a valid Customer ID.")
            }
            return
        }
        
        guard let url = URL(string: "\(baseURL)/\(customerID)") else {
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
                    self.showAlert( message: "No data received.")
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
                        self.populateFieldsFromJSON(jsonResponse)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAlert( message: "Unexpected response format.")
                    }
                }
            } catch {
                print("Decoding Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert( message: "Failed to parse customer data.")
                }
            }
        }.resume()
    }
    private func fetchCustomer(id: String) {
        let url = URL(string: "\(AppConstants.customerAPI)/api/Customer")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(AppConstants.bearerToken)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            if let data = data {
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                        for customer in jsonResponse {
                            if let customerID = customer["customerID"] as? String {
                                self.ids.append(customerID) // Ensure `self.ids` is defined and accessible
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
    private func parseProductResponse(_ data: Data?) -> ProductAddon? {
        guard let data = data else { return nil }
        do {
            return try JSONDecoder().decode(ProductAddon.self, from: data)
        } catch {
            print("Error decoding product data: \(error)")
            return nil
        }
    }
    private func deleteCustomer(id: String) {
        guard let url = URL(string: "\(baseURL)/\(id)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(AppConstants.bearerToken)", forHTTPHeaderField: "Authorization")
        performRequest(request, action: "delete") { success in
            if success {
            // Handle success if needed
                self.showAlert(message: "Customer deleted successfully!")
            } else {
            // Handle failure if needed
                self.showAlert(message: "Failed to delete Customer!")
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
                            self.showAlert(message: "Customer saved successfully!")
                        case "delete":
                            self.showAlert(message: "Customer deleted successfully!")
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
    private func getCustomerFromFields() -> Customer? {
        guard let id = CusID.text, !id.isEmpty,
              let name = CusName.text, !name.isEmpty,
              let phone = PhoneNo.text, !phone.isEmpty,
              let email = Email.text , !email.isEmpty,
              let address = Address.text, !address.isEmpty else { return nil }
        
        return Customer(customerID: id, customerName: name, customerPhone: phone, customerEmail: email, customerAddress: address )
    }
    
    private func populateFieldsFromJSON (_ jsonResponse: [String: Any]) {
        // Safely unwrap and populate the text fields
        if let customerID = jsonResponse["customerID"] as? String {
            self.CusID.text = customerID
        }

        if let customerName = jsonResponse["customerName"] as? String {
            self.CusName.text = customerName
        }

        if let customerPhone = jsonResponse["customerPhone"] as? String {
            self.PhoneNo.text = customerPhone
        }

        if let customerEmail = jsonResponse["customerEmail"] as? String {
            self.Email.text = customerEmail
        }

        if let customerAddress = jsonResponse["customerAddress"] as? String {
            self.Address.text = customerAddress
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
