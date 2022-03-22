//
//  UploadViewController.swift
//  HyperTraceSample
//
//  Created by Nico Prananta on 06.01.22.
//


import UIKit
import HyperTraceSDK
import CoreData

class UploadViewController: UIViewController {
  @IBOutlet var loadingView: UIStackView?
  @IBOutlet var infoLabel: UILabel?
  @IBOutlet var codeField: UITextField?
  @IBOutlet var entryView: UIStackView?
  
  override func viewDidLoad() {
    self.title = "Upload"
  }
  
  @IBAction func didTapUpload() {
    guard let code = codeField?.text else {
      return
    }
    
    self.entryView?.isHidden = true
    self.loadingView?.isHidden = false
    
    HyperTrace.shared().upload(code: code) { [weak self] error in
      defer {
        DispatchQueue.main.async {
          self?.entryView?.isHidden = false
          self?.loadingView?.isHidden = true
        }
      }
      guard error == nil else {
        DispatchQueue.main.async {
          self?.showAlert(title: "Error", message: error?.localizedDescription ?? "Unknown error")
        }
        return
      }
      
      DispatchQueue.main.async {
        self?.showAlert(title: "Success", message: "Data is successfully uploaded")
      }
    }
  }
  
  func showAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let closeAction = UIAlertAction(title: "Close", style: .default, handler: nil)
    alert.addAction(closeAction)
    self.present(alert, animated: true, completion: nil)
  }
}
