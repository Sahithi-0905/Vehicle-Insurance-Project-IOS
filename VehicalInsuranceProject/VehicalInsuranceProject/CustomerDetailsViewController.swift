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
    
    private let baseURL = "https://abzcustomerwebapi-mani.azurewebsites.net/api/Customer"
    
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
        fetchCustomer(id: id)
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
        guard let url = URL(string: baseURL) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

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
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(customer)
        
        performRequest(request,action: "default") { success in
            self.showAlert(message: success ? "Customer updated successfully" : "Failed to update customer")
        }
    }
    
    private func fetchCustomer(id: String) {
        guard let url = URL(string: "\(baseURL)/\(id)") else { return }
        
        let request = URLRequest(url: url)
        
        performRequestWithData(request) { data in
            guard let data = data else {
                DispatchQueue.main.async {
                    self.showAlert(message: "Failed to fetch customer")
                }
                return
            }
            
            do {
                let customer = try JSONDecoder().decode(Customer.self, from: data)
                DispatchQueue.main.async {
                    self.navigateToCustomerDisplay(with: customer)
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(message: "Failed to parse customer data")
                }
            }
        }
    }
    
    private func deleteCustomer(id: String) {
        guard let url = URL(string: "\(baseURL)/\(id)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
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
    
    private func navigateToCustomerDisplay(with customer: Customer) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let displayVC = storyboard.instantiateViewController(withIdentifier: "showid") as? CustomerDisplayViewController else {
            showAlert(message: "Unable to navigate to Customer Display")
            return
        }
        displayVC.customer = customer
        navigationController?.pushViewController(displayVC, animated: true)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
