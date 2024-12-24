//
//  CustomerDisplayViewController.swift
//  VehicalInsuranceProject
//
//  Created by shamitha on 24/12/24.
//

import UIKit

class CustomerDisplayViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var customerIDLabel: UILabel!
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var customerPhoneLabel: UILabel!
    @IBOutlet weak var customerEmailLabel: UILabel!
    @IBOutlet weak var customerAddressLabel: UILabel!
    
    var customer: Customer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let customer = customer {
            customerIDLabel.text = "customerId: \(customer.customerID)"
            customerNameLabel.text = "customerName: \(customer.customerName)"
            customerPhoneLabel.text = "customerPhone: \(customer.customerPhone)"
            customerEmailLabel.text = "customerEmail: \(customer.customerEmail)"
            customerAddressLabel.text = "customerAddress: \(customer.customerAddress)"
        }
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


