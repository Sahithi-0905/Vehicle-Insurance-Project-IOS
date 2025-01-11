import UIKit

class VehicleViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - IBOutlets
    @IBOutlet var RegNo: UITextField!
    @IBOutlet var RegAuth: UITextField!
    @IBOutlet var OwnId: UITextField!
    @IBOutlet var Make: UITextField!
    @IBOutlet var model: UITextField!
    @IBOutlet var Fueltype: UITextField!
    @IBOutlet var Variant: UITextField!
    @IBOutlet var EngineNo: UITextField!
    @IBOutlet var ChassiNo: UITextField!
    @IBOutlet var EngineCap: UITextField!
    @IBOutlet var SeatingCap: UITextField!
    @IBOutlet var MfgYear: UITextField!
    @IBOutlet var regDate: UITextField!
    @IBOutlet var BodyType: UITextField!
    @IBOutlet var LeasedBy: UITextField!
    
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var updateButton: UIButton!
    @IBOutlet var showButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    
    var pv1: UIPickerView!
    var OwnerId: [String] = []
    
    var pv2: UIPickerView!
    var FuelType: [String] = []
    
    var pv3: UIPickerView!
    var SeatingCapacity: [String] = []
    
    var pv4: UIPickerView!
    var RegestrationNo: [String] = []
    
    var dp1: UIDatePicker!
    var df1: DateFormatter!
    
    var token: String=" "
    override func viewDidLoad() {
        super.viewDidLoad()
        AppConstants.generateToken { success in
            DispatchQueue.main.async {
                if success {
                    print("Token generated successfully: \(AppConstants.bearerToken)")
                    
                    self.token=AppConstants.bearerToken
                } else {
                    print("Failed to generate token")
                   
                    self.showAlert(title: "Error",message: "no token")
                }
            }
        }
        // Setting up Picker Views
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissFunc))
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        
        OwnerId = []
        // Set up the UIPickerView for ClaimStatus
        pv1 = UIPickerView()
        pv1.delegate = self
        pv1.dataSource = self
        OwnId.inputView = pv1
        OwnId.inputAccessoryView = toolbar
        
        FuelType = ["P", "D", "C", "L", "E"]
        
        pv2 = UIPickerView()
        pv2.delegate = self
        pv2.dataSource = self
        Fueltype.inputView = pv2
        Fueltype.inputAccessoryView = toolbar
        
        
        SeatingCapacity = ["2", "5", "8", "12", "16"]
        
        pv3 = UIPickerView()
        pv3.delegate = self
        pv3.dataSource = self
        SeatingCap.inputView = pv3
        SeatingCap.inputAccessoryView = toolbar
        
        
        
        pv4 = UIPickerView()
        pv4.delegate = self
        pv4.dataSource = self
        RegNo.inputView = pv4
        RegNo.inputAccessoryView = toolbar
        
        
        // Set up the UIDatePickers for the dates
        dp1 = UIDatePicker()
        dp1.datePickerMode = .date
        dp1.preferredDatePickerStyle = .wheels
        dp1.addTarget(self, action: #selector(dp1Click), for: .valueChanged)
        regDate.inputView = dp1
        regDate.inputAccessoryView = toolbar
        
        fetchCustomerIDs()
        fetchRegNoIDs()

        
    }
    @objc func dp1Click() {
        let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS" // ISO 8601 format with milliseconds

         let formattedDate = dateFormatter.string(from: dp1.date)

   
         regDate.text = formattedDate
    }
    @objc func dismissFunc(){
        view.endEditing(true)
    }
    @IBAction func ClickSave(_ sender: UIButton) {

        
        guard let regNo = RegNo.text, !regNo.isEmpty,
              let regAuth = RegAuth.text, !regAuth.isEmpty,
              let ownId = OwnId.text, !ownId.isEmpty,
              let make = Make.text, !make.isEmpty,
              let model = model.text, !model.isEmpty,
              let fuelType = Fueltype.text, !fuelType.isEmpty,
              let variant = Variant.text, !variant.isEmpty,
              let engineNo = EngineNo.text, !engineNo.isEmpty,
              let chassiNo = ChassiNo.text, !chassiNo.isEmpty,
              let engineCap = EngineCap.text, !engineCap.isEmpty,
              let seatingCap = SeatingCap.text, !seatingCap.isEmpty,
              let mfgYear = MfgYear.text, !mfgYear.isEmpty,
              let regDate = regDate.text, !regDate.isEmpty,
              let bodyType = BodyType.text, !bodyType.isEmpty,
              let leasedBy = LeasedBy.text, !leasedBy.isEmpty else {
            showAlert(title: "Error", message: "All fields must be filled.")
            return
        }

        guard let webserviceURL = URL(string: "\(AppConstants.vehicleAPI)/api/Vehicle/\(AppConstants.bearerToken)") else {
            showAlert(title: "Error", message: "Invalid URL")
            return
        }
        
        var request = URLRequest(url: webserviceURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(AppConstants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let vehicleDetails: [String: Any] = [
            "regNo": regNo,
            "regAuthority": regAuth,
            "make": make,
            "model": model,
            "fuelType": fuelType,
            "variant": variant,
            "engineNo": engineNo,
            "chassisNo": chassiNo,
            "engineCapacity": Int(engineCap) ?? 0,
            "seatingCapacity": Int(seatingCap) ?? 0,
            "mfgYear": mfgYear,
            "regDate": regDate,
            "bodyType": bodyType,
            "leasedBy": leasedBy,
            "ownerId": ownId
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: vehicleDetails, options: [])
            request.httpBody = jsonData
        } catch {
            showAlert(title: "Error", message: "Failed to serialize JSON: \(error.localizedDescription)")
            print("Failed to serialize JSON: \(error.localizedDescription)")
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                self.showAlert(title: "Error", message: "Request failed: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
                    self.showAlert(title: "Error", message: "Server Error (\(httpResponse.statusCode)): \(errorMessage)")
                } else {
                    self.showAlert(title: "Error", message: "Server returned an error: \(httpResponse.statusCode)")
                }
                return
            }
            
            if let data = data {
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        self.showAlert(title: "Success", message: "Record Saved Successfully")
                    }
                } catch {
                    self.showAlert(title: "Error", message: "Failed to parse JSON: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
    @IBAction func ClickUpdate(_ sender: UIButton) {

        guard let regNo = RegNo.text, !regNo.isEmpty,
              let regAuth = RegAuth.text, !regAuth.isEmpty,
              let ownId = OwnId.text, !ownId.isEmpty,
              let make = Make.text, !make.isEmpty,
              let model = model.text, !model.isEmpty,
              let fuelType = Fueltype.text, !fuelType.isEmpty,
              let variant = Variant.text, !variant.isEmpty,
              let engineNo = EngineNo.text, !engineNo.isEmpty,
              let chassiNo = ChassiNo.text, !chassiNo.isEmpty,
              let engineCap = EngineCap.text, !engineCap.isEmpty,
              let seatingCap = SeatingCap.text, !seatingCap.isEmpty,
              let mfgYear = MfgYear.text, !mfgYear.isEmpty,
              let regDate = regDate.text, !regDate.isEmpty,
              let bodyType = BodyType.text, !bodyType.isEmpty,
              let leasedBy = LeasedBy.text, !leasedBy.isEmpty else {
            showAlert(title: "Error", message: "Invalid input: All fields must be filled.")
            return
        }

        // Construct URL
        guard let webserviceURL = URL(string: "\(AppConstants.vehicleAPI)/api/Vehicle/\(regNo)") else {
            showAlert(title: "Error", message: "Invalid URL")
            return
        }

        // Configure PUT request
        var request = URLRequest(url: webserviceURL)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(AppConstants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Prepare JSON payload
        let vehicleDetails: [String: Any] = [
            "regNo": regNo,
            "regAuthority": regAuth,
            "ownerId": ownId,
            "make": make,
            "model": model,
            "fuelType": fuelType,
            "variant": variant,
            "engineNo": engineNo,
            "chassisNo": chassiNo,
            "engineCapacity": Int(engineCap) ?? 0,
            "seatingCapacity": Int(seatingCap) ?? 0,
            "mfgYear": mfgYear,
            "regDate": regDate,
            "bodyType": bodyType,
            "leasedBy": leasedBy
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: vehicleDetails, options: [])
            request.httpBody = jsonData
        } catch {
            showAlert(title: "Error", message: "Failed to serialize JSON: \(error.localizedDescription)")
            print("Failed to serialize JSON: \(error.localizedDescription)")
            return
        }

        // Perform the request
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                self.showAlert(title: "Error", message: "Request failed: \(error.localizedDescription)")
                print("Request failed: \(error.localizedDescription)")
                return
            }

            // Handle response
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                if !(200...299).contains(httpResponse.statusCode) {
                    if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
                        self.showAlert(title: "Error", message: "Server Error (\(httpResponse.statusCode)): \(errorMessage)")
                        print("Server Error (\(httpResponse.statusCode)): \(errorMessage)")
                    } else {
                        self.showAlert(title: "Error", message: "Server returned an error: \(httpResponse.statusCode)")
                        print("Server returned an error: \(httpResponse.statusCode)")
                    }
                    return
                }
            }

            // Parse response data
            if let data = data {
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async {
                            self.showAlert(title: "Success", message: "Response from server: \(jsonResponse)")
                        }
                        print("Response from server: \(jsonResponse)")
                    }
                } catch {
                    self.showAlert(title: "Error", message: "Failed to parse JSON: \(error.localizedDescription)")
                    print("Failed to parse JSON: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
    
    @IBAction func ClickDelete(_ sender: UIButton) {

        
        guard let regNo = RegNo.text, !regNo.isEmpty else {
            showAlert(title: "Error", message: "Invalid input: Registration Number must be provided.")
            return
        }
        
        guard let webserviceURL = URL(string: "\(AppConstants.vehicleAPI)/api/Vehicle/\(regNo)") else {
            showAlert(title: "Error", message: "Invalid URL")
            return
        }
        
        var request = URLRequest(url: webserviceURL)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(AppConstants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                self.showAlert(title: "Error", message: "Request failed: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Success", message: "Vehicle deleted successfully.")
                    }
                } else {
                    if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
                        self.showAlert(title: "Error", message: "Server Error (\(httpResponse.statusCode)): \(errorMessage)")
                    } else {
                        self.showAlert(title: "Error", message: "Server returned an error: \(httpResponse.statusCode)")
                    }
                }
            }
        }
        task.resume()
    }
    
    
    
    @IBAction func ClickGet(_ sender: UIButton) {

        guard let regNo = RegNo.text, !regNo.isEmpty else {
            showAlert(title: "Error", message: "Registration Number must be filled.")
            return
        }

        // Construct the URL
        guard let webserviceURL = URL(string: "\(AppConstants.vehicleAPI)/api/Vehicle/\(regNo)") else {
            showAlert(title: "Error", message: "Invalid URL")
            return
        }

        var request = URLRequest(url: webserviceURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(AppConstants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                self.showAlert(title: "Error", message: "Request failed: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                if !(200...299).contains(httpResponse.statusCode) {
                    if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
                        self.showAlert(title: "Error", message: "Server Error (\(httpResponse.statusCode)): \(errorMessage)")
                    } else {
                        self.showAlert(title: "Error", message: "Server returned an error: \(httpResponse.statusCode)")
                    }
                    return
                }
            }

            guard let data = data else {
                self.showAlert(title: "Error", message: "No data received from server.")
                return
            }

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("Response from server: \(jsonResponse)")

                    // Update UI on the main thread
                    DispatchQueue.main.async {
                        self.RegNo.text = jsonResponse["regNo"] as? String ?? "N/A"
                        self.RegAuth.text = jsonResponse["regAuthority"] as? String ?? "N/A"
                        self.OwnId.text = jsonResponse["ownerId"] as? String ?? "N/A"
                        self.Make.text = jsonResponse["make"] as? String ?? "N/A"
                        self.model.text = jsonResponse["model"] as? String ?? "N/A"
                        self.Fueltype.text = jsonResponse["fuelType"] as? String ?? "N/A"
                        self.Variant.text = jsonResponse["variant"] as? String ?? "N/A"
                        self.EngineNo.text = jsonResponse["engineNo"] as? String ?? "N/A"
                        self.ChassiNo.text = jsonResponse["chassisNo"] as? String ?? "N/A"
                        self.EngineCap.text = "\(jsonResponse["engineCapacity"] as? Int ?? 0)" // Convert number to string
                        self.SeatingCap.text = "\(jsonResponse["seatingCapacity"] as? Int ?? 0)" // Convert number to string
                        self.MfgYear.text = jsonResponse["mfgYear"] as? String ?? "N/A"
                        self.regDate.text = jsonResponse["regDate"] as? String ?? "N/A"
                        self.BodyType.text = jsonResponse["bodyType"] as? String ?? "N/A"
                        self.LeasedBy.text = jsonResponse["leasedBy"] as? String ?? "N/A"
                    }
                } else {
                    self.showAlert(title: "Error", message: "Unexpected response format.")
                }
            } catch {
                self.showAlert(title: "Error", message: "Failed to parse JSON: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    // UIPickerViewDelegate and UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // Single component in each picker
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == pv1 {
            return OwnerId.count
        } else if pickerView == pv2 {
            return FuelType.count
        } else if pickerView == pv3 {
            return SeatingCapacity.count
        }
        else if pickerView == pv4 {
            return RegestrationNo.count
        }
        return 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == pv1 {
            return OwnerId[row]
        } else if pickerView == pv2 {
            return FuelType[row]
        } else if pickerView == pv3 {
            return SeatingCapacity[row]
        }
        else if pickerView == pv4 {
            return RegestrationNo[row]
        }
        return nil
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pv1 {
            OwnId.text = OwnerId[row]
        } else if pickerView == pv2 {
            Fueltype.text = FuelType[row]
        } else if pickerView == pv3 {
            SeatingCap.text = SeatingCapacity[row]
        }
        else if pickerView == pv4 {
            RegNo.text = RegestrationNo[row]
       }
    }
    func fetchCustomerIDs() {

       
        let url = URL(string: "\(AppConstants.customerAPI)/api/Customer")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(AppConstants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Perform the API request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Failed to get HTTP response.")
                return
            }
            
            print("HTTP Status Code: \(httpResponse.statusCode)")
            
            if !(200...299).contains(httpResponse.statusCode) {
                print("Server error with status code: \(httpResponse.statusCode)")
                if let data = data {
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to decode response data as String"
                    print("Response Data String: \(responseString)")
                }
                return
            }
            
            if let data = data {
                let responseString = String(data: data, encoding: .utf8) ?? "Unable to decode response data as String"
                print("Response Data String: \(responseString)")
                
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                        for customer in jsonResponse {
                            if let customerID = customer["customerID"] as? String {
                                print("CustomerID: \(customerID)")
                                // Assuming self.CustomerID exists as an array property
                                self.OwnerId.append(customerID)
                            } else {
                                print("CustomerID not found for product: \(customer)")
                            }
                        }
                    } else {
                        print("Unexpected JSON structure.")
                    }
                } catch {
                    print("Failed to decode response: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
    
    
    func fetchRegNoIDs() {


           let url = URL(string: "\(AppConstants.vehicleAPI)/api/Vehicle")!

           var request = URLRequest(url: url)
           request.httpMethod = "GET"
           request.setValue("Bearer \(AppConstants.bearerToken)", forHTTPHeaderField: "Authorization")
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")

           
           self.RegestrationNo = []

           // Perform the API request
           let task = URLSession.shared.dataTask(with: request) { data, response, error in
               if let error = error {
                   print("Error: \(error.localizedDescription)")
                   return
               }

               guard let httpResponse = response as? HTTPURLResponse else {
                   print("Failed to get HTTP response.")
                   return
               }

               print("HTTP Status Code: \(httpResponse.statusCode)")

               if !(200...299).contains(httpResponse.statusCode) {
                   print("Server error with status code: \(httpResponse.statusCode)")
                   if let data = data {
                       let responseString = String(data: data, encoding: .utf8) ?? "Unable to decode response data as String"
                       print("Response Data String: \(responseString)")
                   }
                   return
               }

               if let data = data {
                   let responseString = String(data: data, encoding: .utf8) ?? "Unable to decode response data as String"
                   print("Response Data String: \(responseString)")  // Print raw response for debugging
                   
                   do {
                       if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                           print("JSON Response: \(jsonResponse)")  // Log the full response JSON
                           
                           for vehicle in jsonResponse {
                               if let regNo = vehicle["regNo"] as? String {
                                   let sanitizedRegNo = regNo.trimmingCharacters(in: .whitespaces)
                                   print("regNo: \(sanitizedRegNo)")
                                   self.RegestrationNo.append(sanitizedRegNo)
                               } else {
                                   print("regNo not found for vehicle: \(vehicle)")
                               }
                           }

                       } else {
                           print("Unexpected JSON structure.")
                       }
                   } catch {
                       print("Failed to decode response: \(error.localizedDescription)")
                   }
               }
           }
           task.resume()
       }

    
   
   
}
