//
//  ClaimsDisplayViewController.swift
//  VehicalInsuranceProject
//
//  Created by shamitha on 25/12/24.
//

import UIKit

class ClaimsDisplayViewController: UIViewController {
    
    @IBOutlet var claimNoLabel : UILabel!
    @IBOutlet var claimDatelabel : UILabel!
    @IBOutlet var policyNolabel : UILabel!
    @IBOutlet var incidentDatelabel : UILabel!
    @IBOutlet var incidentLocationlabel : UILabel!
    @IBOutlet var incidentDescriptionlabel : UILabel!
    @IBOutlet var claimAmountlabel : UILabel!
    @IBOutlet var surveyorNamelabel : UILabel!
    @IBOutlet var surveyorPhonelabel : UILabel!
    @IBOutlet var surveyDatelabel : UILabel!
    @IBOutlet var surveyDescriptionlabel : UILabel!
    @IBOutlet var claimStatuslabel : UILabel!
    
    var claim: ClaimDetails?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let claim = claim {
            claimNoLabel.text = "claimNo: \(claim.claimNo)"
            claimDatelabel.text = "claimDate: \(claim.claimDate)"
            policyNolabel.text = "policyNo: \(claim.policyNo)"
            incidentDatelabel.text = "incidentDate: \(claim.incidentDate)"
            incidentLocationlabel.text = "incidentLocation: \(claim.incidentLocation)"
            incidentDescriptionlabel.text = "incidentDescription: \(claim.incidentDescription)"
            claimAmountlabel.text = "claimAmount: \(claim.claimAmount)"
            surveyorNamelabel.text = "surveyorName: \(claim.surveyorName)"
            surveyorPhonelabel.text = "surveyorPhone: \(claim.surveyorPhone)"
            surveyDatelabel.text = "surveyDate: \(claim.surveyDate)"
            surveyDescriptionlabel.text = "surveyDescription: \(claim.surveyDescription)"
            claimStatuslabel.text = "claimStatus: \(claim.claimStatus)"
        }

        // Do any additional setup after loading the view.
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
