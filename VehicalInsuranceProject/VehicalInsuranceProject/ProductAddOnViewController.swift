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
class ProductAddOnViewController: UIViewController {
    
    @IBOutlet var prodId: UITextField!
        @IBOutlet var addId: UITextField!
        @IBOutlet var addTitle: UITextField!
        @IBOutlet var adddDescription: UITextField!
        @IBOutlet var save: UIButton!
        @IBOutlet var update: UIButton!
        @IBOutlet var show: UIButton!
        @IBOutlet var delete: UIButton!
        
        override func viewDidLoad() {
            super.viewDidLoad()

            // Do any additional setup after loading the view.
        }
        @IBAction func saveProduct() {
            guard let productaddData = createProductAddonData() else {
                displayAlert(alertTitle: "Error", alertMessage: "All fields must be filled.")
                return
            }
            
            performRequest(
                endpoint: "https://abzproductwebapi-akshitha.azurewebsites.net/api/ProductAddon",
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

        // MARK: - Helper Methods
        private func performRequest(endpoint: String, method: String, body: ProductAddon?, completion: ((Any) -> Void)? = nil) {
                guard let url = URL(string: endpoint) else {
                    displayAlert(alertTitle: "Error", alertMessage: "Invalid URL.")
                    return
                }

                var request = URLRequest(url: url)
                request.httpMethod = method
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                if let body = body {
                    do {
                        let jsonData = try JSONEncoder().encode(body)
                        request.httpBody = jsonData
                    } catch {
                        displayAlert(alertTitle: "Error", alertMessage: "Failed to encode data.")
                        return
                    }
                }

                let session = URLSession.shared
                let task = session.dataTask(with: request) { data, response, error in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.displayAlert(alertTitle: "Error", alertMessage: error.localizedDescription)
                        }
                        return
                    }

                    guard let data = data else {
                        DispatchQueue.main.async {
                            self.displayAlert(alertTitle: "Error", alertMessage: "No data received.")
                        }
                        return
                    }

                    if let completion = completion {
                        do {
                            let responseJSON = try JSONSerialization.jsonObject(with: data, options: [])
                            completion(responseJSON)
                        } catch {
                            DispatchQueue.main.async {
                                self.displayAlert(alertTitle: "Error", alertMessage: "Failed to parse response.")
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.displayAlert(alertTitle: "Success", alertMessage: "\(method) request successful.")
                        }
                    }
                }
                task.resume()
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
        
            private func populateFields(with product: ProductAddon) {
                prodId.text = product.productID
                addId.text = product.addonID
                addTitle.text = product.addonTitle
                adddDescription.text = product.addonDescription
            }

    private func displayAlert(alertTitle: String, alertMessage: String) {
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
