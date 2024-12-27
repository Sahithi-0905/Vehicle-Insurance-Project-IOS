//
//  ProductViewController.swift
//  VehicalInsuranceProject
//
//  Created by shamitha on 24/12/24.
//

import UIKit

struct Product: Codable {
    let productID: String
    let productName: String
    let productDescription: String
    let productUIN: String
    let insuredInterests: String
    let policyCoverage: String
}

class ProductViewController: UIViewController {

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
        
        var id: String!
        
        override func viewDidLoad() {
            super.viewDidLoad()
        }
        
        // MARK: - Button Actions
        
        @IBAction func saveProduct() {
            guard let productData = createProductData() else {
                displayAlert(alertTitle: "Error", alertMessage: "All fields must be filled.")
                return
            }
            
            performRequest(
                endpoint: "https://abzproductwebapi-akshitha.azurewebsites.net/api/Product",
                method: "POST",
                productData: productData
            ) { response in
                self.displayAlert(alertTitle: "Success", alertMessage: "Product saved successfully.")
            }
        }
        
        @IBAction func updateProduct() {
            guard let productData = createProductData(), let productId = productId.text else {
                displayAlert(alertTitle: "Error", alertMessage: "All fields must be filled, including Product ID.")
                return
            }
            
            performRequest(
                endpoint: "https://abzproductwebapi-akshitha.azurewebsites.net/api/Product/\(productId)",
                method: "PUT",
                productData: productData
            ) { response in
                self.displayAlert(alertTitle: "Success", alertMessage: "Product updated successfully.")
            }
        }
        
        @IBAction func showProduct() {
            guard let productId = productId.text, !productId.isEmpty else {
                displayAlert(alertTitle: "Error", alertMessage: "Please enter a Product ID.")
                return
            }
            
            performRequest(
                endpoint: "https://abzproductwebapi-akshitha.azurewebsites.net/api/Product/\(productId)",
                method: "GET"
            ) { response in
                guard let product = self.parseProductResponse(response) else {
                    self.displayAlert(alertTitle: "Error", alertMessage: "Failed to fetch product details.")
                    return
                }
                
                DispatchQueue.main.async {
                    // Navigate to the details screen and pass the product
                    self.navigateToProductDetails(with: product)
                }
            }
        }

        // Helper Method for Navigation
        private func navigateToProductDetails(with product: Product) {
            // Instantiate the ProductDetailsViewController from the storyboard
            guard let productDetailsVC = storyboard?.instantiateViewController(withIdentifier: "ProductDetails") as? ProductDetailsViewController else {
                displayAlert(alertTitle: "Error", alertMessage: "Failed to load product details screen.")
                return
            }
            
            // Pass the product data to the details screen
            productDetailsVC.product = product
            
            // Navigate to the ProductDetailsViewController
            navigationController?.present(productDetailsVC, animated: true)
            //pushViewController(productDetailsVC, animated: true)
        }

        
        @IBAction func deleteProduct() {
            guard let prodId = productId.text, !prodId.isEmpty else {
                displayAlert(alertTitle: "Error", alertMessage: "Please enter a Product ID.")
                return
            }
            
            performRequest(
                endpoint: "https://abzproductwebapi-akshitha.azurewebsites.net/api/Product/\(prodId)",
                method: "DELETE"
            ) { _ in
                self.displayAlert(alertTitle: "Success", alertMessage: "Product deleted successfully.")
            }
        }
        
        // MARK: - Helper Functions
        
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
        
        private func populateFields(with product: Product) {
            productId.text = product.productID
            productName.text = product.productName
            productDesc.text = product.productDescription
            productUin.text = product.productUIN
            productInsuredInt.text = product.insuredInterests
            policyCoverage.text = product.policyCoverage
        }
        
        func displayAlert(alertTitle: String, alertMessage: String) {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
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

}
