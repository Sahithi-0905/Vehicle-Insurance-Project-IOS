import UIKit

class VehicleViewController: UIViewController {
    // MARK: - Properties
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Text Fields
    private let regNoTextField = UITextField()
    private let makeTextField = UITextField()
    private let modelTextField = UITextField()
    private let variantTextField = UITextField()
    private let engineNoTextField = UITextField()
    private let chassisNoTextField = UITextField()
    private let engineCapacityTextField = UITextField()
    
    //buttons
    // Save Button
   /* let saveButton = UIButton(type: .system)
    saveButton.translatesAutoresizingMaskIntoConstraints = false
    saveButton.setTitle("Save", for: .normal)
    saveButton.backgroundColor = .systemBlue
    saveButton.setTitleColor(.white, for: .normal)
    saveButton.layer.cornerRadius = 8
    saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    contentView.addSubview(saveButton)

    // Update Button
    let updateButton = UIButton(type: .system)
    updateButton.translatesAutoresizingMaskIntoConstraints = false
    updateButton.setTitle("Update", for: .normal)
    updateButton.backgroundColor = .systemGray
    updateButton.setTitleColor(.white, for: .normal)
    updateButton.layer.cornerRadius = 8
    updateButton.addTarget(self, action: #selector(updateButtonTapped), for: .touchUpInside)
    contentView.addSubview(updateButton)

    // Show Button
    let showButton = UIButton(type: .system)
    showButton.translatesAutoresizingMaskIntoConstraints = false
    showButton.setTitle("Show", for: .normal)
    showButton.backgroundColor = .systemGreen
    showButton.setTitleColor(.white, for: .normal)
    showButton.layer.cornerRadius = 8
    showButton.addTarget(self, action: #selector(showButtonTapped), for: .touchUpInside)
    contentView.addSubview(showButton)

    // Delete Button
    let deleteButton = UIButton(type: .system)
    deleteButton.translatesAutoresizingMaskIntoConstraints = false
    deleteButton.setTitle("Delete", for: .normal)
    deleteButton.backgroundColor = .systemRed
    deleteButton.setTitleColor(.white, for: .normal)
    deleteButton.layer.cornerRadius = 8
    deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    contentView.addSubview(deleteButton)
*/
    
    // Dropdowns (Using UIPickerView)
    private let regAuthorityTextField = UITextField()
    private let ownerIDTextField = UITextField()
    private let fuelTypeTextField = UITextField()
    private let seatingCapacityTextField = UITextField()
    private let mfgYearTextField = UITextField()
    private let bodyTypeTextField = UITextField()
    private let leasedByTextField = UITextField()
    
    // Date Picker
    private let regDateTextField = UITextField()
    private let datePicker = UIDatePicker()
    
    // Pickers
    private let regAuthorityPicker = UIPickerView()
    private let ownerIDPicker = UIPickerView()
    private let fuelTypePicker = UIPickerView()
    private let seatingCapacityPicker = UIPickerView()
    private let mfgYearPicker = UIPickerView()
    private let bodyTypePicker = UIPickerView()
    private let leasedByPicker = UIPickerView()
    
    // Data Sources
    private let fuelTypes = ["Petrol", "Diesel", "Electric", "Hybrid", "CNG"]
    private let bodyTypes = ["Sedan", "SUV", "Hatchback", "MUV", "Van"]
    private let seatingCapacityRange = Array(1...9)
    private let yearRange = Array((Calendar.current.component(.year, from: Date()) - 50)...Calendar.current.component(.year, from: Date()))
    private let regAuthorities = ["Authority 1", "Authority 2", "Authority 3"]
    private let ownerIDs = ["Owner 1", "Owner 2", "Owner 3"]
    private let lessees = ["Lessee 1", "Lessee 2", "Lessee 3"]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupPickers()
        setupDatePicker()
        setupKeyboardDismissal()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Vehicle Registration"
        view.backgroundColor = .systemBackground
        
        // Add scroll view
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Configure text fields
        let textFields = [
            regNoTextField, makeTextField, modelTextField, variantTextField,
            engineNoTextField, chassisNoTextField, engineCapacityTextField,
            regAuthorityTextField, ownerIDTextField, fuelTypeTextField,
            seatingCapacityTextField, mfgYearTextField, bodyTypeTextField,
            leasedByTextField, regDateTextField
        ]
        
        let placeholders = [
            "Registration Number", "Make", "Model", "Variant",
            "Engine Number", "Chassis Number", "Engine Capacity",
            "Registration Authority", "Owner ID", "Fuel Type",
            "Seating Capacity", "Manufacturing Year", "Body Type",
            "Leased By", "Registration Date"
        ]
        
        for (textField, placeholder) in zip(textFields, placeholders) {
            setupTextField(textField, placeholder: placeholder)
            contentView.addSubview(textField)
        }
        
        // Add submit button
        let submitButton = UIButton(type: .system)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.setTitle("Submit", for: .normal)
        submitButton.backgroundColor = .systemBlue
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 8
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        contentView.addSubview(submitButton)
    }
    
    private func setupTextField(_ textField: UITextField, placeholder: String) {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.placeholder = placeholder
        textField.font = .systemFont(ofSize: 16)
    }
    
    private func setupPickers() {
        // Configure pickers
        let pickers = [
            (regAuthorityPicker, regAuthorityTextField, regAuthorities),
            (ownerIDPicker, ownerIDTextField, ownerIDs),
            (fuelTypePicker, fuelTypeTextField, fuelTypes),
            (seatingCapacityPicker, seatingCapacityTextField, seatingCapacityRange.map { String($0) }),
            (mfgYearPicker, mfgYearTextField, yearRange.map { String($0) }),
            (bodyTypePicker, bodyTypeTextField, bodyTypes),
            (leasedByPicker, leasedByTextField, lessees)
        ]
        
        for (picker, textField, _) in pickers {
            picker.delegate = self
            picker.dataSource = self
            textField.inputView = picker
            setupToolbar(for: textField)
        }
    }
    
    private func setupDatePicker() {
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        regDateTextField.inputView = datePicker
        setupToolbar(for: regDateTextField)
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    }
    
    private func setupToolbar(for textField: UITextField) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(toolbarDoneTapped))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(toolbarDoneTapped))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [cancelButton, flexSpace, doneButton]
        textField.inputAccessoryView = toolbar
    }
    
    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
        
        // Setup vertical spacing between elements
        var previousAnchor = contentView.topAnchor
        let textFields = [
            regNoTextField, makeTextField, modelTextField, variantTextField,
            engineNoTextField, chassisNoTextField, engineCapacityTextField,
            regAuthorityTextField, ownerIDTextField, fuelTypeTextField,
            seatingCapacityTextField, mfgYearTextField, regDateTextField,
            bodyTypeTextField, leasedByTextField
        ]
        
        for textField in textFields {
            NSLayoutConstraint.activate([
                textField.topAnchor.constraint(equalTo: previousAnchor, constant: 20),
                textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                textField.heightAnchor.constraint(equalToConstant: 44)
            ])
            previousAnchor = textField.bottomAnchor
        }
        
        // Find the submit button from contentView's subviews
        guard let submitButton = contentView.subviews.first(where: { $0 is UIButton }) as? UIButton else {
            return
        }
        
        // Set up submit button constraints
        NSLayoutConstraint.activate([
            submitButton.topAnchor.constraint(equalTo: previousAnchor, constant: 30),
            submitButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            submitButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            submitButton.heightAnchor.constraint(equalToConstant: 50),
            submitButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Actions
    @objc private func submitButtonTapped() {
        // Collect form data
        let formData = [
            "regNo": regNoTextField.text,
            "make": makeTextField.text,
            "model": modelTextField.text,
            "variant": variantTextField.text,
            "engineNo": engineNoTextField.text,
            "chassisNo": chassisNoTextField.text,
            "engineCapacity": engineCapacityTextField.text,
            "regAuthority": regAuthorityTextField.text,
            "ownerID": ownerIDTextField.text,
            "fuelType": fuelTypeTextField.text,
            "seatingCapacity": seatingCapacityTextField.text,
            "mfgYear": mfgYearTextField.text,
            "regDate": regDateTextField.text,
            "bodyType": bodyTypeTextField.text,
            "leasedBy": leasedByTextField.text
        ]
        
        // Handle form submission
        print("Form Data:", formData)
        
        let NO = regNoTextField.text ?? ""
        
        let make = makeTextField.text ?? ""
        let model = modelTextField.text ?? ""
        let variant = variantTextField.text ?? ""
        let engineNo = engineNoTextField.text ?? ""
        let chassisNo = chassisNoTextField.text ?? ""
        let engineCapacity = engineCapacityTextField.text ?? ""
        let regAuthority  = regAuthorityTextField.text ?? ""
        let ownerID = ownerIDTextField.text ?? ""
        let fuelType = fuelTypeTextField.text ?? ""
        let seatingCapacity = seatingCapacityTextField.text ?? ""
        let mfgYear = mfgYearTextField.text ?? ""
        let regDate = regDateTextField.text ?? ""
        let bodyType = bodyTypeTextField.text ?? ""
        let leasedBy = leasedByTextField.text ?? ""
        
        guard let ID = regNoTextField.text, !ID.isEmpty else {
            showAlert(title: "Error", message: "No Customer Found")
            return
        }
        
        guard let webserviceURL = URL(string: "https://abzvehiclewebapi-chana.azurewebsites.net/api/Vehicle ") else {
            self.showAlert(title: "Error", message: "Invalid service URL.")
            return
        }
        
        var request = URLRequest(url: webserviceURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let customerData: [String: Any] = [
            
            "regNo": NO,
            "make": make,
            "model": model,
            "variant": variant,
            "engineNo": engineNo,
            "chassisNo": chassisNo,
            "engineCapacity": engineCapacity,
            "regAuthority": regAuthority,
            "ownerID": ownerID,
            "fuelType": fuelType,
            "seatingCapacity": seatingCapacity,
            "mfgYear": mfgYear,
            "regDate": regDate,
            "bodyType": bodyType,
            "leasedBy": leasedBy
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: customerData, options: [])
            request.httpBody = jsonData
        } catch {
            self.showAlert(title: "Error", message: "Failed to serialize JSON: \(error.localizedDescription)")
            return
        }
        
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.showAlert(title: "Error", message: "Failed to save customer: \(error.localizedDescription)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                    self.showAlert(title: "Error", message: "Server error: \(httpResponse.statusCode)")
                    return
                }
                
                self.showAlert(title: "Success", message: "Customer saved successfully!")
                
            }
        }.resume()
    }
    /*
        // Show success alert
        let alert = UIAlertController(title: "Success",
                                    message: "Form submitted successfully!",
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }*/
    
    @objc private func toolbarDoneTapped() {
        view.endEditing(true)
    }
    
    @objc private func dateChanged() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        regDateTextField.text = formatter.string(from: datePicker.date)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UIPickerView Delegate & DataSource
extension VehicleViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case regAuthorityPicker:
            return regAuthorities.count
        case ownerIDPicker:
            return ownerIDs.count
        case fuelTypePicker:
            return fuelTypes.count
        case seatingCapacityPicker:
            return seatingCapacityRange.count
        case mfgYearPicker:
            return yearRange.count
        case bodyTypePicker:
            return bodyTypes.count
        case leasedByPicker:
            return lessees.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case regAuthorityPicker:
            return regAuthorities[row]
        case ownerIDPicker:
            return ownerIDs[row]
        case fuelTypePicker:
            return fuelTypes[row]
        case seatingCapacityPicker:
            return String(seatingCapacityRange[row])
        case mfgYearPicker:
            return String(yearRange[row])
        case bodyTypePicker:
            return bodyTypes[row]
        case leasedByPicker:
            return lessees[row]
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case regAuthorityPicker:
            regAuthorityTextField.text = regAuthorities[row]
        case ownerIDPicker:
            ownerIDTextField.text = ownerIDs[row]
        case fuelTypePicker:
            fuelTypeTextField.text = fuelTypes[row]
        case seatingCapacityPicker:
            seatingCapacityTextField.text = String(seatingCapacityRange[row])
        case mfgYearPicker:
            mfgYearTextField.text = String(yearRange[row])
        case bodyTypePicker:
            bodyTypeTextField.text = bodyTypes[row]
        case leasedByPicker:
            leasedByTextField.text = lessees[row]
        default:
            break
        }
    }
    
    
    
    private func showAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    @objc private func saveButtonTapped() {
        print("Save button tapped")
        // Add functionality to save the data
    }

    @objc private func updateButtonTapped() {
        print("Update button tapped")
        // Add functionality to update the data
    }

    @objc private func showButtonTapped() {
        print("Show button tapped")
        // Add functionality to show the data
    }

    @objc private func deleteButtonTapped() {
        print("Delete button tapped")
        // Add functionality to delete the data
    }

}
