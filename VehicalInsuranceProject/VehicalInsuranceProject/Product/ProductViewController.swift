//
//  ProductViewController.swift
//  VehicalInsuranceProject
//
//  Created by shamitha on 24/12/24.
//

import UIKit

//product structure
struct Product: Codable {
    let productID: String
    let productName: String
    let productDescription: String
    let productUIN: String
    let insuredInterests: String
    let policyCoverage: String
}

class ProductViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Outlets for text fields,buttons
    @IBOutlet var productId: UITextField!
    @IBOutlet var productName: UITextField!
    @IBOutlet var productDesc: UITextField!
    @IBOutlet var productUin: UITextField!
    @IBOutlet var productInsuredInt: UITextField!
    @IBOutlet var policyCoverage: UITextField!
    @IBOutlet var save: UIButton!
    @IBOutlet var update: UIButton!
    @IBOutlet var show: UIButton!
    @IBOutlet var delete: UIButton!
        
    var propickerView : UIPickerView!
    
    var ids: [String] = [] // Array to store IDs fetched from API
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppConstants.generateToken { success in
            DispatchQueue.main.async {
                if success {
                    print("Token generated successfully: \(AppConstants.bearerToken)")
                    // fetch product ids
                    self.fetchProductIds()
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
        
        //picker view for productids
        propickerView = UIPickerView()
        propickerView.delegate = self
        propickerView.dataSource = self
        productId.inputView = propickerView
        productId.inputAccessoryView = toolbar
    }
    @objc func dismissFunc(){
        view.endEditing(true)
    }
    // MARK: - Button Actions to Save Product
    @IBAction func saveProduct() {
        guard let productData = createProductData() else {
            displayAlert(alertTitle: "Error", alertMessage: "All fields must be filled.")
            return
        }
        
        performRequest(
            endpoint: "\(AppConstants.productAPI)/api/Product/\(AppConstants.bearerToken)",
            method: "POST",
            productData: productData
        ) { response in
            self.displayAlert(alertTitle: "Success", alertMessage: "Product saved successfully.")
        }
    }
    // MARK: - Button Actions to Update Product
    @IBAction func updateProduct() {
        guard let productData = createProductData(), let productId = productId.text else {
            displayAlert(alertTitle: "Error", alertMessage: "All fields must be filled, including Product ID.")
            return
        }
        
        performRequest(
            endpoint: "\(AppConstants.productAPI)/api/Product/\(productId)",
            method: "PUT",
            productData: productData
        ) { response in
            self.displayAlert(alertTitle: "Success", alertMessage: "Product updated successfully.")
        }
    }
    // MARK: - Button Actions to Show Product
    @IBAction func showProduct() {
        guard let productId = productId.text, !productId.isEmpty else {
            displayAlert(alertTitle: "Error", alertMessage: "Please enter a Product ID.")
            return
        }
        
        performRequest(
            endpoint: "\(AppConstants.productAPI)/api/Product/\(productId)",
            method: "GET"
        ) { response in
            guard let product = self.parseProductResponse(response) else {
                self.displayAlert(alertTitle: "Error", alertMessage: "Failed to fetch product details.")
                return
            }
            
            DispatchQueue.main.async {
                // Navigate to the details screen and pass the product
                //self.navigateToProductDetails(with: product)
                self.populateFields(with: product)
            }
        }
    }
    // MARK: - Button Actions to Delete Product
    @IBAction func deleteProduct() {
        guard let prodId = productId.text, !prodId.isEmpty else {
            displayAlert(alertTitle: "Error", alertMessage: "Please enter a Product ID.")
            return
        }
        
        performRequest(
            endpoint: "\(AppConstants.productAPI)/api/Product/\(prodId)",
            method: "DELETE"
        ) { _ in
            self.displayAlert(alertTitle: "Success", alertMessage: "Product deleted successfully.")
        }
    }
    
    //function to creates a Product object if all required text fields are non-empty; otherwise, it returns nil.
    private func createProductData() -> Product? {
        guard let id = productId.text, !id.isEmpty,
              let name = productName.text, !name.isEmpty,
              let desc = productDesc.text, !desc.isEmpty,
              let uin = productUin.text, !uin.isEmpty,
              let interests = productInsuredInt.text, !interests.isEmpty,
              let coverage = policyCoverage.text, !coverage.isEmpty else {
            return nil
        }
        
        return Product(
            productID: id,
            productName: name,
            productDescription: desc,
            productUIN: uin,
            insuredInterests: interests,
            policyCoverage: coverage
        )
    }
    
    //function to performs an HTTP request with the given endpoint, method, and optional product data

    private func performRequest(
            endpoint: String,
            method: String,
            productData: Product? = nil,
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
        
        if let productData = productData {
            do {
                let jsonData = try JSONEncoder().encode(productData)
                request.httpBody = jsonData
            } catch {
                displayAlert(alertTitle: "Error", alertMessage: "Failed to encode product data.")
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
        
    private func parseProductResponse(_ data: Data?) -> Product? {
        guard let data = data else { return nil }
        do {
            return try JSONDecoder().decode(Product.self, from: data)
        } catch {
            print("Error decoding product data: \(error)")
            return nil
        }
    }
    //function to add existing data to text fields when clicked show button
    private func populateFields(with product: Product) {
        productId.text = product.productID
        productName.text = product.productName
        productDesc.text = product.productDescription
        productUin.text = product.productUIN
        productInsuredInt.text = product.insuredInterests
        policyCoverage.text = product.policyCoverage
    }
    
    //function to fetch list of existing product ids to include in picker view
    private func fetchProductIds(){
        
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
                                print("ProductID not found for product: \(products)")
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
        return 0
    }
        
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            if pickerView == propickerView{
                return ids[row]
            }
            return nil
        }
        
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == propickerView{
            productId.text = ids[row]
        }
    }
    
    //function to display alerts
    func displayAlert(alertTitle: String, alertMessage: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    
}
