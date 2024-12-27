//
//  ProfileViewController.swift
//  VehicalInsuranceProject
//
//  Created by shamitha on 24/12/24.
//

import UIKit

class ProfileViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var phoneLabel: UILabel!
    
    var sectionNames: [String] = []
    var sectionNamesicons: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sectionNames = ["Customer","Vehicle","Product","Product Addon","Agent","Proposal","Policy","PolicyAddon","Claims"]
        sectionNamesicons = ["person.crop.circle","car.fill","bag", "shippingbox","person.circle","square.and.pencil","list.clipboard.fill","plus.circle.fill","doc.text.fill"]
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 9
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //let name = sectionNames[0]
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "id1", for: indexPath)
        
        cell1.textLabel?.text = sectionNames[indexPath.section]
        cell1.imageView?.image = UIImage(systemName: sectionNamesicons[indexPath.section]) // Set SF Symbol
        //cell1.backgroundColor = .clear
        cell1.accessoryType = .disclosureIndicator
        
        return cell1
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if indexPath.section == 0 {
            // Navigate to Customer screen
            if let nextScreen = storyboard.instantiateViewController(withIdentifier: "custid") as? CustomerDetailsViewController {
                self.navigationController?.pushViewController(nextScreen, animated: true)
            }
        }else if indexPath.section == 1 {
            //Navigate to vehicle screen
            if let nextScreen = storyboard.instantiateViewController(withIdentifier: "vehicleid") as? VehicleViewController {
                self.navigationController?.pushViewController(nextScreen, animated: true)
            }
        }else if indexPath.section == 2 {
            // Navigate to Product  screen
            if let nextScreen = storyboard.instantiateViewController(withIdentifier: "proid") as? ProductViewController {
                self.navigationController?.pushViewController(nextScreen, animated: true)
            }
        }else if indexPath.section == 3 {
            //Navigate to Product Addon Screen
            if let nextScreen = storyboard.instantiateViewController(withIdentifier: "proaddid") as? ProductAddOnViewController {
                self.navigationController?.pushViewController(nextScreen, animated: true)
            }
        }
        else if indexPath.section == 4 {
            //Navigate to Agent Screen
            if let nextScreen = storyboard.instantiateViewController(withIdentifier: "agid") as? AgentsViewController {
                self.navigationController?.pushViewController(nextScreen, animated: true)
            }
        }else if indexPath.section == 5{
                // Navigate to Proposal screen
                if let nextScreen = storyboard.instantiateViewController(withIdentifier: "propid") as? ProposalViewController {
                    self.navigationController?.pushViewController(nextScreen, animated: true)
                }
            }else if indexPath.section == 6 {
                //Navigate to Policy Screen
                if let nextScreen = storyboard.instantiateViewController(withIdentifier: "policyid") as? PolicyViewController {
                    self.navigationController?.pushViewController(nextScreen, animated: true)
                }
            }else if indexPath.section == 7{
                //Navigate to PolicyAddon Screen
                if let nextScreen = storyboard.instantiateViewController(withIdentifier: "poliid") as? PolicyAddonViewController {
                    self.navigationController?.pushViewController(nextScreen, animated: true)
                }
            }
        else if indexPath.section == 8{
                //Navigate to Claims Screen
                if let nextScreen = storyboard.instantiateViewController(withIdentifier: "claimsid") as? ClaimsViewController {
                    self.navigationController?.pushViewController(nextScreen, animated: true)
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
    }

