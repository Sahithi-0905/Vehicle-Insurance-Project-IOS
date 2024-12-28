//
//  PolicyAddonDetailsViewController.swift
//  VehicalInsuranceProject
//
//  Created by shamitha on 28/12/24.
//

import UIKit
// Define the PolicyAddon model
struct policyAddon {
    var policyNumber: String
    var addonID: String
    var amount: String
}

class PolicyAddonDetailsViewController: UIViewController {
    
    @IBOutlet var PolicyNoLabel: UILabel!
    @IBOutlet var PolicyAddonLabel: UILabel!
    @IBOutlet var AmountLabel: UILabel!
    
    var policyaddonDetails: PolicyAddon?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Populate UI with policy add-on details
               if let policyAddon = policyaddonDetails {
                   PolicyNoLabel.text = "Policy Number: \(policyAddon.policyNumber)"
                   PolicyAddonLabel.text = "Add-On ID: \(policyAddon.addonID)"
                   AmountLabel.text = "Details: \(policyAddon.amount)"
               } else {
                   displayAlert(alertTitle: "Error", alertMessage: "No policy add-on details available.")
               }
           }
           
           // Helper Method for Alerts
           func displayAlert(alertTitle: String, alertMessage: String) {
               let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "OK", style: .default))
               present(alert, animated: true)
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

