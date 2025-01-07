//
//  ProfileViewController.swift
//  VehicalInsuranceProject
//
//  Created by shamitha on 24/12/24.
//

//
//  ProfileViewController.swift
//  VehicalInsuranceProject
//
//  Created by shamitha on 24/12/24.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
        @IBOutlet var tableView: UITableView!
        @IBOutlet var profileImageView: UIImageView!
        @IBOutlet var nameLabel: UILabel!
        @IBOutlet var phoneLabel: UILabel!
        
        var sectionNames: [String] = []
        var sectionNamesicons: [String] = []
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            sectionNames = ["Customer", "Vehicle", "Product", "Product Addon", "Agent", "Proposal", "Policy", "PolicyAddon", "Claims","Customer Query","Query Response"]
            sectionNamesicons = ["person.crop.circle", "car.fill", "bag", "shippingbox", "person.circle", "square.and.pencil", "list.clipboard.fill", "plus.circle.fill", "doc.text.fill","doc.text.fill","doc.text.fill"]
            
            tableView.delegate = self
            tableView.dataSource = self
            
            // Add tap gesture to profileImageView
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectProfileImage))
            profileImageView.isUserInteractionEnabled = true
            profileImageView.addGestureRecognizer(tapGesture)
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
            profileImageView.clipsToBounds = true
            profileImageView.layer.borderWidth = 2
            profileImageView.layer.borderColor = UIColor.systemGray4.cgColor
        }
        
        @objc func selectProfileImage() {
            let actionSheet = UIAlertController(title: "Select Profile Image", message: "Choose a source", preferredStyle: .actionSheet)
            
            // Camera option
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                    self.presentImagePicker(sourceType: .camera)
                }))
            }
            
            // Photo Library option
            actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
                self.presentImagePicker(sourceType: .photoLibrary)
            }))
            
            // Cancel option
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
            
            // For iPad, present the action sheet properly
            if let popoverController = actionSheet.popoverPresentationController {
                popoverController.sourceView = self.profileImageView
                popoverController.sourceRect = profileImageView.bounds
            }
            
            present(actionSheet, animated: true, completion: nil)
        }
        
        func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = sourceType
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[.editedImage] as? UIImage {
                profileImageView.image = selectedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                profileImageView.image = originalImage
            }
            dismiss(animated: true, completion: nil)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss(animated: true, completion: nil)
        }
        
        func numberOfSections(in tableView: UITableView) -> Int {
            return sectionNames.count
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 1
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "id1", for: indexPath)
            cell.textLabel?.text = sectionNames[indexPath.section]
            cell.imageView?.image = UIImage(systemName: sectionNamesicons[indexPath.section]) // Set SF Symbol
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            switch indexPath.section {
            case 0:
                if let nextScreen = storyboard.instantiateViewController(withIdentifier: "custid") as? CustomerDetailsViewController {
                    navigationController?.pushViewController(nextScreen, animated: true)
                }
            case 1:
                if let nextScreen = storyboard.instantiateViewController(withIdentifier: "vehicleid") as? VehicleViewController {
                    navigationController?.pushViewController(nextScreen, animated: true)
                }
            case 2:
                if let nextScreen = storyboard.instantiateViewController(withIdentifier: "proid") as? ProductViewController {
                    navigationController?.pushViewController(nextScreen, animated: true)
                }
            case 3:
                if let nextScreen = storyboard.instantiateViewController(withIdentifier: "proaddid") as? ProductAddOnViewController {
                    navigationController?.pushViewController(nextScreen, animated: true)
                }
            case 4:
                if let nextScreen = storyboard.instantiateViewController(withIdentifier: "agentid") as? AgentsViewController {
                    navigationController?.pushViewController(nextScreen, animated: true)
                }
            case 5:
                if let nextScreen = storyboard.instantiateViewController(withIdentifier: "propid") as? ProposalViewController {
                    navigationController?.pushViewController(nextScreen, animated: true)
                }
            case 6:
                if let nextScreen = storyboard.instantiateViewController(withIdentifier: "policyid") as? PolicyViewController {
                    navigationController?.pushViewController(nextScreen, animated: true)
                }
            case 7:
                if let nextScreen = storyboard.instantiateViewController(withIdentifier: "poliid") as? PolicyAddonViewController {
                    navigationController?.pushViewController(nextScreen, animated: true)
                }
            case 8:
                if let nextScreen = storyboard.instantiateViewController(withIdentifier: "claimsid") as? ClaimsViewController {
                    navigationController?.pushViewController(nextScreen, animated: true)
                }
            case 9:
                if let nextScreen = storyboard.instantiateViewController(withIdentifier: "custqueId") as? CustomerQueryViewController {
                    navigationController?.pushViewController(nextScreen, animated: true)
                }
            case 10:
                if let nextScreen = storyboard.instantiateViewController(withIdentifier: "querId") as? QueryResponseViewController {
                    navigationController?.pushViewController(nextScreen, animated: true)
                }
            default:
                break
            }
        }
    }

