//
//  ProductAddOnViewController.swift
//  VehicalInsuranceProject
//
//  Created by shamitha on 24/12/24.
//

import UIKit

struct ProductAddon: Codable {
    let productID: String
    let addonID: String
    let addonTitle: String
    let addonDescription: String
    
}
class ProductAddOnViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
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
    var ids: [String] = [] // Array to store IDs fetched from API
    var adonids:[String] = []// Array to store addonIDs fetched from API
    
    let accessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoibW0iLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJubiIsImV4cCI6MTczNTQxNDU1NSwiaXNzIjoiaHR0cHM6Ly93d3cudGVhbTIuY29tIiwiYXVkIjoiaHR0cHM6Ly93d3cudGVhbTIuY29tIn0.V0awAs8QxFby8zAy0kd_WBFWZiP_fhHKYyx7kS-Ino8"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        fetchProductIds()
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
        addId.inputView = propickerView
        addId.inputAccessoryView = toolbar
    }
    @objc func dismissFunc(){
        view.endEditing(true)
    }
    @IBAction func saveProduct() {
        guard let productaddData = createProductAddonData() else {
            displayAlert(alertTitle: "Error", alertMessage: "All fields must be filled.")
            return
        }
        performRequest(
            endpoint: "https://abzproductwebapi-akshitha.azurewebsites.net/api/ProductAddon/\(accessToken)",
            method: "POST",
            productAddonData: productaddData
        ) { response in
            self.displayAlert(alertTitle: "Success", alertMessage: "Product saved successfully.")
        }
    }
    @IBAction func updateProduct() {
        guard let productaddData = createProductAddonData(), let productId = prodId.text ,let addid = addId.text else {
            displayAlert(alertTitle: "Error", alertMessage: "All fields must be filled, including Product ID.")
            return
        }
        performRequest(
            endpoint: "https://abzproductwebapi-akshitha.azurewebsites.net/api/ProductAddon/\(productId)/\(addid)",
            method: "PUT",
            productAddonData: productaddData
        ) { response in
            self.displayAlert(alertTitle: "Success", alertMessage: "Product updated successfully.")
            
        }
    }
    // MARK: - Delete Method
    @IBAction func deleteProduct() {
        
        guard let prodId = prodId.text, !prodId.isEmpty,let addid = addId.text else {
            displayAlert(alertTitle: "Error", alertMessage: "Please enter a Product ID.")
            return
        }
        
        performRequest(
            //https://abzproductwebapi-akshitha.azurewebsites.net/api/ProductAddon/P123/9900
            endpoint: "https://abzproductwebapi-akshitha.azurewebsites.net/api/ProductAddon/\(prodId)/\(addid)",
            method: "DELETE"
        ) { _ in
            self.displayAlert(alertTitle: "Success", alertMessage: "Product deleted successfully.")
        }
        
    }

        // MARK: - Show Method
    @IBAction func showProduct() {
        guard let productId = prodId.text, !productId.isEmpty,
              let addonid = addId.text, !addonid.isEmpty else {
            displayAlert(alertTitle: "Error", alertMessage: "Please enter a Product ID and Addon ID.")
            return
        }
        
        performRequest(
            endpoint: "https://abzproductwebapi-akshitha.azurewebsites.net/api/ProductAddon/\(productId)/\(addonid)",
            method: "GET"
        ) { response in
            guard let productadd = self.parseProductResponse(response) else {
                self.displayAlert(alertTitle: "Error", alertMessage: "Failed to fetch product details.")
                return
            }
            
            DispatchQueue.main.async {
                // Navigate to the details screen and pass the product
                //self.navigateToProductDetails(with: product)
                self.populateFields(with: productadd)
            }
        }
    }
    // Helper Method for Navigation
    private func navigateToProductDetails(with product: ProductAddon) {
        // Instantiate the ProductDetailsViewController from the storyboard
        guard let productDetailsVC = storyboard?.instantiateViewController(withIdentifier: "ProductDetails") as? ProductAddondetailsViewController else {
            displayAlert(alertTitle: "Error", alertMessage: "Failed to load product details screen.")
            return
        }
        
        // Pass the product data to the details screen
        productDetailsVC.productadd = product
        
        // Navigate to the ProductDetailsViewController
        navigationController?.present(productDetailsVC, animated: true)
        //pushViewController(productDetailsVC, animated: true)
    }

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
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
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
        
    private func populateFields(with productadd: ProductAddon) {
        prodId.text = productadd.productID
        addId.text = productadd.addonID
        addTitle.text = productadd.addonTitle
        adddDescription.text = productadd.addonDescription
    }
    private func fetchProductIds(){
        //Create the URL Request
        let url = URL(string: "https://abzproductwebapi-akshitha.azurewebsites.net/api/Product")! // Replace with your API URL
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
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
    private func fetchAdonIds(){
        //Create the URL Request
        let url = URL(string: "https://abzproductwebapi-akshitha.azurewebsites.net/api/ProductAddon")! // Replace with your API URL
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
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
                                print("ProductID: \(proaddID)")
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
    
    private func displayAlert(alertTitle: String, alertMessage: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}
