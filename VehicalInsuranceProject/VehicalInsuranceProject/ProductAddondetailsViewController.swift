//
//  ProductAddondetailsViewController.swift
//  VehicalInsuranceProject
//
//  Created by shamitha on 26/12/24.
//

import UIKit

class ProductAddondetailsViewController: UIViewController {
    //UI Outlets
        @IBOutlet var productIdLabel: UILabel!
        @IBOutlet var AddonIdLabel: UILabel!
        @IBOutlet var AddonTitleLabel: UILabel!
        @IBOutlet var AddonDescriptionLabel: UILabel!
        
            
        // Product object to hold passed data
        var productadd: ProductAddon?
            
        override func viewDidLoad() {
            super.viewDidLoad()
                
            // Populate UI with product details
            if let product = productadd {
                
                productIdLabel.text = "ProductId:\(product.productID)"
                AddonIdLabel.text = "AddOnID: \(product.addonID)"
                AddonTitleLabel.text = "AddonTitle: \(product.addonTitle)"
                AddonDescriptionLabel.text = "AddonDescription: \(product.addonDescription)"
                    
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
