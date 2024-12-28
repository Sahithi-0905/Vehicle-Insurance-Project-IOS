//
//  AgentDetailsViewController.swift
//  VehicalInsuranceProject
//
//  Created by shamitha on 27/12/24.
//

import UIKit

class AgentDetailsViewController: UIViewController {
    
    var agent: Agent?
    
    @IBOutlet var agentIdLabel: UILabel!
    @IBOutlet var agentNameLabel: UILabel!
    @IBOutlet var agentPhoneLabel: UILabel!
    @IBOutlet var agentEmailLabel: UILabel!
    @IBOutlet var licenseCodeLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayAgentDetails()
    }
    
    private func displayAgentDetails() {
        guard let agent = agent else { return }
        agentIdLabel.text = "Agent ID: \(agent.agentID)"
        agentNameLabel.text = "Name: \(agent.agentName)"
        agentPhoneLabel.text = "Phone: \(agent.agentPhone)"
        agentEmailLabel.text = "Email: \(agent.agentEmail)"
        licenseCodeLabel.text = "License Code: \(agent.licenseCode)"
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

