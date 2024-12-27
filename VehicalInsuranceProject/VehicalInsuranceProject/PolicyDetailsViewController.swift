//
//  PolicyDetailsViewController.swift
//  VehicalInsuranceProject
//
//  Created by shamitha on 26/12/24.
//

import UIKit

class PolicyDetailsViewController: UIViewController {
    
    @IBOutlet  var policyNumberLabel : UILabel!
    @IBOutlet  var proposalNumberLabel : UILabel!
    @IBOutlet  var noClaimBonusLabel : UILabel!
    @IBOutlet  var receiptNumberLabel : UILabel!
    @IBOutlet  var receiptDateLabel : UILabel!
    @IBOutlet  var paymentModeLabel : UILabel!
    @IBOutlet  var amountLabel : UILabel!
  

    var policy: Policy?

       override func viewDidLoad() {
           super.viewDidLoad()
           
           // Populate the labels with the policy details
           if let policy = policy {
               policyNumberLabel.text = "Policy Number: \(policy.policyNumber)"
               proposalNumberLabel.text = "Proposal Number: \(policy.proposalNumber)"
               noClaimBonusLabel.text = "No Claim Bonus: \(policy.noClaimBonus)"
               receiptNumberLabel.text = "Receipt Number: \(policy.receiptNumber)"
               receiptDateLabel.text = "Receipt Date: \(policy.receiptDate)"
               paymentModeLabel.text = "Payment Mode: \(policy.paymentMode)"
               amountLabel.text = "Amount: \(policy.amount)"
           } else {
               displayAlert(alertTitle: "Error", alertMessage: "No policy details available.")
           }
       }
       
       // MARK: - Helper Methods
       
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

