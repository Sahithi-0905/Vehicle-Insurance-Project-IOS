import UIKit
import FirebaseAuth

class HomeViewController: UIViewController {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet var homebtn: UIBarButtonItem!
    // Timer property
    var timer: Timer?
    
    // Array of image names
    let images = ["car5.jpeg", "car1.jpeg", "car6.jpeg", "car3.jpeg"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addbarbtn()
        self.navigationItem.hidesBackButton = true
        // Setup initial image
        image.image = UIImage(named: images[0])
        pageControl.numberOfPages = images.count
        pageControl.currentPage = 0
        
        // Start the timer
        startTimer()
    }
    
    // Action for PageControl click (if manually controlled)
    @IBAction func pc1click() {
        let index: Int = pageControl.currentPage
        updateImage(for: index)
    }
    
    // Update image based on index
    private func updateImage(for index: Int) {
        if index < images.count {
            image.image = UIImage(named: images[index])
        }
    }
    
    // Start the timer
    private func startTimer() {
        timer = Timer.scheduledTimer(
            timeInterval: 3.0, // Change image every 3 seconds
            target: self,
            selector: #selector(nextPage),
            userInfo: nil,
            repeats: true
        )
    }
    
    // Stop the timer (if needed)
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // Change to the next page
    @objc private func nextPage() {
        let nextIndex = (pageControl.currentPage + 1) % images.count
        pageControl.currentPage = nextIndex
        updateImage(for: nextIndex)
    }
    
    deinit {
        // Ensure timer is invalidated
        stopTimer()
    }
    func addbarbtn(){
        homebtn = UIBarButtonItem(image: UIImage(systemName: "homekit"), style: .plain, target: self, action: #selector(homeBtnClick))
        self.navigationItem.rightBarButtonItem = homebtn
    }
    @objc func homeBtnClick(){
        if let user = Auth.auth().currentUser {
            do {
                try Auth.auth().signOut() // Attempt to sign out
                
                // Show a success message or transition to the root view controller
                print("User signed out successfully")
                
                // Pop to the root view controller
                navigationController?.popToRootViewController(animated: true)
            } catch let signOutError as NSError {
                
                print("Error signing out: \(signOutError.localizedDescription)")
                
            }
        } else {
            // If no user is signed in, print the message
            print("No user is currently signed in.")
            
        }
    }
    
    
}
