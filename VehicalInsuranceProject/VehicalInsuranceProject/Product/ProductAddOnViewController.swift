//
//  ProductAddOnViewController.swift
//  VehicalInsuranceProject
//
//  Created by shamitha on 24/12/24.
//

import UIKit

//ProductAddon structure
struct ProductAddon: Codable {
    let productID: String
    let addonID: String
    let addonTitle: String
    let addonDescription: String
    
}
class ProductAddOnViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Outlets for text fields,buttons
    @IBOutlet var prodId: UITextField!
    @IBOutlet var addId: UITextField!
    @IBOutlet var addTitle: UITextField!
    @IBOutlet var adddDescription: UITextField!
    @IBOutlet var save: UIButton!
    @IBOutlet var update: UIButton!
    @IBOutlet var show: UIButton!
    @IBOutlet var delete: UIButton!
        
    var propickerView : UIPickerView!
    var addonPickerview : UIPickerView!
    
    var ids: [String] = [] // Array to store productIDs fetched from API
    var adonids:[String] = []// Array to store addonIDs fetched from API
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        AppConstants.generateToken { success in
            DispatchQueue.main.async {
                if success {
                    print("Token generated successfully: \(AppConstants.bearerToken)")
                   
                    self.fetchProductIds()
                    self.fetchAdonIds()
                } else {
                    print("Failed to generate token")
                    self.displayAlert(
                        alertTitle: "Error",
                        alertMessage: "Failed to generate token. Please try again."
                    )
                }
            }
        }
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(dismissFunc))
        toolbar.setItems([done], animated: true)
        
        propickerView = UIPickerView()
        propickerView.delegate = self
        propickerView.dataSource = self
        prodId.inputView = propickerView
        prodId.inputAccessoryView = toolbar
        
        addonPickerview = UIPickerView()
        addonPickerview.delegate = self
        addonPickerview.dataSource = self
        addId.inputView = addonPickerview
        addId.inputAccessoryView = toolbar
    }
    @objc func dismissFunc(){
        view.endEditing(true)
    }
    
    // MARK: - Button Actions to Save ProductAddon
    @IBAction func saveProduct() {
        guard let productaddData = createProductAddonData() else {
            displayAlert(alertTitle: "Error", alertMessage: "All fields must be filled.")
            return
        }
        performRequest(
            endpoint: "\(AppConstants.productAPI)/api/ProductAddon/\(AppConstants.bearerToken)",
            method: "POST",
            productAddonData: productaddData
        ) { response in
            self.displayAlert(alertTitle: "Success", alertMessage: "Product saved successfully.")
        }
    }
    // MARK: - Button Actions to Update ProductAddon
    @IBAction func updateProduct() {
        guard let productaddData = createProductAddonData(), let productId = prodId.text ,let addid = addId.text else {
            displayAlert(alertTitle: "Error", alertMessage: "All fields must be filled, including Product ID.")
            return
        }
        performRequest(
            endpoint: "\(AppConstants.productAPI)/api/ProductAddon/\(productId)/\(addid)",
            method: "PUT",
            productAddonData: productaddData
        ) { response in
            self.displayAlert(alertTitle: "Success", alertMessage: "Product updated successfully.")
            
        }
    }
    // MARK: - Button Actions to Delete ProductAddon
    @IBAction func deleteProduct() {
        
        guard let prodId = prodId.text, !prodId.isEmpty,let addid = addId.text else {
            displayAlert(alertTitle: "Error", alertMessage: "Please enter a Product ID.")
            return
        }
        
        performRequest(
            endpoint: "\(AppConstants.productAPI)/api/ProductAddon/\(prodId)/\(addid)",
            method: "DELETE"
        ) { _ in
            self.displayAlert(alertTitle: "Success", alertMessage: "Product deleted successfully.")
        }
        
    }

    // MARK: - Button Actions to Show ProductAddon
    @IBAction func showProduct() {
        guard let productId = prodId.text, !productId.isEmpty,
              let addonid = addId.text, !addonid.isEmpty else {
            displayAlert(alertTitle: "Error", alertMessage: "Please enter a Product ID and Addon ID.")
            return
        }
        
        performRequest(
            endpoint: "\(AppConstants.productAPI)/api/ProductAddon/\(productId)/\(addonid)",
            method: "GET"
        ) { response in
            guard let productadd = self.parseProductResponse(response) else {
                self.displayAlert(alertTitle: "Error", alertMessage: "Failed to fetch product details.")
                return
            }
            
            DispatchQueue.main.async {
                self.populateFields(with: productadd)
            }
        }
    }
    //function to creates a Product Addon object if all required text fields are non-empty; otherwise, it returns nil.
   
    private func createProductAddonData() -> ProductAddon? {
        guard let id = prodId.text, !id.isEmpty,
              let addid = addId.text, !addid.isEmpty,
              let addtitle = addTitle.text, !addtitle.isEmpty,
              let adddesc = adddDescription.text, !adddesc.isEmpty else {
            return nil
        }
        
        return ProductAddon(
            productID: id,
            addonID:addid,
            addonTitle:addtitle,
            addonDescription: adddesc
            
        )
    }
    //function to performs an HTTP request with the given endpoint, method, and optional product data

    private func performRequest(
            endpoint: String,
            method: String,
            productAddonData: ProductAddon? = nil,
            completion: @escaping (Data?) -> Void
    ) {
        guard let url = URL(string: endpoint) else {
            displayAlert(alertTitle: "Error", alertMessage: "Invalid URL.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(AppConstants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let productaddData = productAddonData {
            do {
                let jsonData = try JSONEncoder().encode(productaddData)
                request.httpBody = jsonData
            } catch {
                displayAlert(alertTitle: "Error", alertMessage: "Failed to encode product data.")
                return
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.displayAlert(alertTitle: "Error", alertMessage: "Request failed: \(error.localizedDescription)")
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    self.displayAlert(alertTitle: "Error", alertMessage: "Server error or invalid response.")
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(data)
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
    //function to add existing data to text fields when clicked show button
    private func populateFields(with productadd: ProductAddon) {
        prodId.text = productadd.productID
        addId.text = productadd.addonID
        addTitle.text = productadd.addonTitle
        adddDescription.text = productadd.addonDescription
    }
    
    //function to fetch Product ids
    private func fetchProductIds(){
        //Create the URL Request
        let url = URL(string: "\(AppConstants.productAPI)/api/Product")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(AppConstants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        


        //Perform the API Request
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
                        for products in jsonResponse {
                            if let productsID = products["productID"] as? String {
                                print("ProductID: \(productsID)")
                                // Assuming self.CustomerID exists as an array property
                                self.ids.append(productsID)
                            } else {
                                print("CustomerID not found for product: \(products)")
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
    //function to fetch ProductAddon ids
    private func fetchAdonIds(){
        
        guard let addonid = addId.text, !addonid.isEmpty else {
            return
        }
        let url = URL(string: "\(AppConstants.productAPI)/api/ProductAddon")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(AppConstants.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      
        //Perform the API Request
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
                        for productaddons in jsonResponse {
                            if let proaddID = productaddons["addonID"] as? String {
                                print("ProductAddonID: \(proaddID)")
                                // Assuming self.CustomerID exists as an array property
                                self.adonids.append(proaddID)
                            } else {
                                print("CustomerID not found for product: \(productaddons)")
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
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
        
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == propickerView{
            return ids.count
        }
        else if pickerView == addonPickerview{
            return adonids.count
        }
        return 0
    }
        
    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == propickerView{
            return ids[row]
        }
        else if pickerView == addonPickerview{
            return adonids[row]
        }
            return nil
        }
        
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == propickerView{
            prodId.text = ids[row]
        }
        else if pickerView == addonPickerview{
            addId.text = adonids[row]
        }
    }
    
    //function to display alerts
    private func displayAlert(alertTitle: String, alertMessage: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}
