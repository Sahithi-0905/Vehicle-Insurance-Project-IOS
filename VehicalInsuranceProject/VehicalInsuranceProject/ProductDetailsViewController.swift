//
//  ProductDetailsViewController.swift
//  VehicalInsuranceProject
//
//  Created by shamitha on 26/12/24.
//

import UIKit

class ProductDetailsViewController: UIViewController {
    // UI Outlets
            @IBOutlet var productIdLabel: UILabel!
            @IBOutlet var productNameLabel: UILabel!
            @IBOutlet var productDescriptionLabel: UILabel!
            @IBOutlet var productUinLabel: UILabel!
            @IBOutlet var insuredInterestsLabel: UILabel!
            @IBOutlet var policyCoverageLabel: UILabel!
            
            // Product object to hold passed data
            var product: Product?
            
            override func viewDidLoad() {
                super.viewDidLoad()
                
                // Populate UI with product details
                if let product = product {
                    productIdLabel.text = "ProductID: \(product.productID)"
                    productNameLabel.text = "ProductName: \(product.productName)"
                    productDescriptionLabel.text = "ProductDescription: \(product.productDescription)"
                    productUinLabel.text = "ProductUIN: \(product.productUIN)"
                    insuredInterestsLabel.text = "InsuredInterests: \( product.insuredInterests)"
                    policyCoverageLabel.text = "PolicyCoverage: \(product.policyCoverage)"
                } else {
                    displayAlert(alertTitle: "Error", alertMessage: "No product details available.")
                }
            }
            
            // Helper Method for Alerts
            func displayAlert(alertTitle: String, alertMessage: String) {
                let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
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
