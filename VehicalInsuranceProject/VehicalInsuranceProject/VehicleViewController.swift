import UIKit

// MARK: - Vehicle Model
struct Vehicle: Codable {
    var regNo: String
    var regAuthority: String
    var make: String
    var model: String
    var fuelType: String
    var variant: String
    var engineNo: String
    var chassisNo: String
    var engineCapacity: Int
    var seatingCapacity: Int
    var mfgYear: String
    var regDate: String
    var bodyType: String
    var leasedBy: String
    var ownerId: String
}

class VehicleViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - IBOutlets
    @IBOutlet var regNoTextField: UITextField!
    @IBOutlet var regAuthorityTextField: UITextField!
    @IBOutlet var makeTextField: UITextField!
    @IBOutlet var modelTextField: UITextField!
    @IBOutlet var fuelTypeTextField: UITextField!
    @IBOutlet var variantTextField: UITextField!
    @IBOutlet var engineNoTextField: UITextField!
    @IBOutlet var chassisNoTextField: UITextField!
    @IBOutlet var engineCapacityTextField: UITextField!
    @IBOutlet var seatingCapacityTextField: UITextField!
    @IBOutlet var mfgYearTextField: UITextField!
    @IBOutlet var regDateTextField: UITextField!
    @IBOutlet var bodyTypeTextField: UITextField!
    @IBOutlet var leasedByTextField: UITextField!
    @IBOutlet var ownerIdTextField: UITextField!
    
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var updateButton: UIButton!
    @IBOutlet var showButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    
    let accessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoibW0iLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJubiIsImV4cCI6MTczNTQxNDU1NSwiaXNzIjoiaHR0cHM6Ly93d3cudGVhbTIuY29tIiwiYXVkIjoiaHR0cHM6Ly93d3cudGVhbTIuY29tIn0.V0awAs8QxFby8zAy0kd_WBFWZiP_fhHKYyx7kS-Ino8"
    private let baseURL = "https://abzvehiclewebapi-chana.azurewebsites.net/api/Vehicle"
    
    // MARK: - Drop Down Data
    let fuelTypes = ["Petrol", "Diesel", "Electric", "Hybrid"]
    let bodyTypes = ["Sedan", "SUV", "Hatchback", "Coupe", "Convertible"]
    let makes = ["Toyota", "Ford", "Honda", "BMW", "Mercedes"]
    
    // MARK: - PickerView
    var activeTextField: UITextField?
    var activePickerView: UIPickerView?

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setting up Picker Views
        setUpPickerView()
    }

    private func setUpPickerView() {
        let fuelPicker = UIPickerView()
        fuelPicker.delegate = self
        fuelTypeTextField.inputView = fuelPicker
        
        let bodyTypePicker = UIPickerView()
        bodyTypePicker.delegate = self
        bodyTypeTextField.inputView = bodyTypePicker
        
        let makePicker = UIPickerView()
        makePicker.delegate = self
        makeTextField.inputView = makePicker
    }
    
    // MARK: - PickerView DataSource & Delegate Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == fuelTypeTextField.inputView {
            return fuelTypes.count
        } else if pickerView == bodyTypeTextField.inputView {
            return bodyTypes.count
        } else {
            return makes.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == fuelTypeTextField.inputView {
            return fuelTypes[row]
        } else if pickerView == bodyTypeTextField.inputView {
            return bodyTypes[row]
        } else {
            return makes[row]
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == fuelTypeTextField.inputView {
            fuelTypeTextField.text = fuelTypes[row]
        } else if pickerView == bodyTypeTextField.inputView {
            bodyTypeTextField.text = bodyTypes[row]
        } else {
            makeTextField.text = makes[row]
        }
        
        activeTextField?.resignFirstResponder()
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let vehicle = getVehicleFromFields() else {
            showAlert(message: "Please fill all fields")
            return
        }
        saveVehicle(vehicle: vehicle)
    }
    
    @IBAction func updateButtonTapped(_ sender: UIButton) {
        guard let vehicle = getVehicleFromFields() else {
            showAlert(message: "Please fill all fields")
            return
        }
        updateVehicle(vehicle: vehicle)
    }
    
    @IBAction func showButtonTapped(_ sender: UIButton) {
        guard let regNo = regNoTextField.text, !regNo.isEmpty else {
            showAlert(message: "Please enter the vehicle registration number to fetch details")
            return
        }
        fetchVehicle(regNo: regNo)
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        guard let regNo = regNoTextField.text, !regNo.isEmpty else {
            showAlert(message: "Please enter the vehicle registration number to delete")
            return
        }
        deleteVehicle(regNo: regNo)
    }
    
    // MARK: - API Methods
    private func saveVehicle(vehicle: Vehicle) {
        guard let url = URL(string: baseURL) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let requestBody = try JSONEncoder().encode(vehicle)
            request.httpBody = requestBody
        } catch {
            print("Error encoding vehicle: \(error)")
            return
        }

        performRequest(request) { success in
            DispatchQueue.main.async {
                if success {
                    self.showAlert(message: "Vehicle saved successfully!")
                } else {
                    self.showAlert(message: "Failed to save vehicle. Please try again.")
                }
            }
        }
    }

    private func updateVehicle(vehicle: Vehicle) {
        guard let url = URL(string: "\(baseURL)/\(regNoTextField.text!)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(vehicle)
        
        performRequest(request) { success in
            self.showAlert(message: success ? "Vehicle updated successfully" : "Failed to update vehicle")
        }
    }
    
    private func fetchVehicle(regNo: String) {
        guard let url = URL(string: "\(baseURL)/\(regNo)") else { return }
        
        let request = URLRequest(url: url)
        
        performRequestWithData(request) { data in
            guard let data = data else {
                DispatchQueue.main.async {
                    self.showAlert(message: "Failed to fetch vehicle")
                }
                return
            }
            
            do {
                let vehicle = try JSONDecoder().decode(Vehicle.self, from: data)
                DispatchQueue.main.async {
                    self.navigateToVehicleDisplay(with: vehicle)
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(message: "Failed to parse vehicle data")
                }
            }
        }
    }
    
    private func deleteVehicle(regNo: String) {
        guard let url = URL(string: "\(baseURL)/\(regNo)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        performRequest(request) { success in
            self.showAlert(message: success ? "Vehicle deleted successfully" : "Failed to delete vehicle")
        }
    }
    
    private func performRequest(_ request: URLRequest, completion: @escaping (Bool) -> Void) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle network error
            if let error = error {
                print("Request Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert(message: "Network Error: \(error.localizedDescription)")
                }
                completion(false)
                return
            }

            // Debugging response status code and body
            if let httpResponse = response as? HTTPURLResponse {
                print("Response Status Code: \(httpResponse.statusCode)")
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Response Body: \(responseString)")
                }

                // Check for successful status code
                if httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        self.showAlert(message: "Vehicle saved successfully!")
                    }
                    completion(true)
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(message: "Failed to save vehicle. Status code: \(httpResponse.statusCode)")
                    }
                    completion(false)
                }
            } else {
                DispatchQueue.main.async {
                    self.showAlert(message: "No response from server.")
                }
                completion(false)
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
    private func getVehicleFromFields() -> Vehicle? {
        guard let regNo = regNoTextField.text, !regNo.isEmpty,
              let regAuthority = regAuthorityTextField.text, !regAuthority.isEmpty,
              let make = makeTextField.text, !make.isEmpty,
              let model = modelTextField.text, !model.isEmpty,
              let fuelType = fuelTypeTextField.text , !fuelType.isEmpty,
              let variant = variantTextField.text, !variant.isEmpty,
              let engineNo = engineNoTextField.text, !engineNo.isEmpty,
              let chassisNo = chassisNoTextField.text, !chassisNo.isEmpty,
              let engineCapacity = engineCapacityTextField.text, !engineCapacity.isEmpty,
              let seatingCapacity = seatingCapacityTextField.text, !seatingCapacity.isEmpty,
              let mfgYear = mfgYearTextField.text, !mfgYear.isEmpty,
              let regDate = regDateTextField.text, !regDate.isEmpty,
              let bodyType = bodyTypeTextField.text, !bodyType.isEmpty,
              let leasedBy = leasedByTextField.text, !leasedBy.isEmpty,
              let ownerId = ownerIdTextField.text, !ownerId.isEmpty else { return nil }
        
        return Vehicle(regNo: regNo, regAuthority: regAuthority, make: make, model: model, fuelType: fuelType, variant: variant, engineNo: engineNo, chassisNo: chassisNo, engineCapacity: Int(engineCapacity) ?? 0, seatingCapacity: Int(seatingCapacity) ?? 0, mfgYear: mfgYear, regDate: regDate, bodyType: bodyType, leasedBy: leasedBy, ownerId: ownerId)
    }

    private func navigateToVehicleDisplay(with vehicle: Vehicle) {
        // Navigate to display view controller or update UI
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
