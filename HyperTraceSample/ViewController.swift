//
//  ViewController.swift
//  HyperTraceSample
//
//  Created by Nico Prananta on 28.12.21.
//

import UIKit
import HyperTraceSDK
import CoreData

class ViewController: UIViewController {
  @IBOutlet weak var startTracingStackView: UIStackView!
  @IBOutlet weak var stopTracingStackView: UIStackView!
  @IBOutlet weak var phoneField: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    updateTracingStackView()
    
    // check the tracing status regularly
    Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
      print("Checking tracing status")
      self?.updateTracingStackView()
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    updateTracingStackView()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    updateTracingStackView()
  }
  
  func updateTracingStackView() {
    // show the stop tracing button if running
    if (HyperTrace.shared().isTracing()) {
      self.startTracingStackView.isHidden = true
      self.stopTracingStackView.isHidden = false
    } else {
      // show the start tracing if not running
      self.startTracingStackView.isHidden = false
      self.stopTracingStackView.isHidden = true
    }
  }
  
  @IBAction func didTapButton(_ sender: Any) {
    self.phoneField.resignFirstResponder()
    var userId = self.phoneField.text ?? ""
    if userId.trimmingCharacters(in: CharacterSet.whitespaces).count == 0 {
      return
    }
    
    // hypertrace server requires uid to be 21 character length
    while userId.count < 21 {
      userId.append("0")
    }
    UserDefaults.standard.set(userId, forKey: "userId")
    
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 1
    
    HyperTrace
      .shared()
      .start(baseUrl: "YOUR_HYPERTRACE_SERVER_URL_HERE",
             uid: UserDefaults.standard.string(forKey: "userId")!,
             sessionConfiguration: configuration
      )
    
    self.showLogs()
  }
  
  func showLogs() {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "logVC")
    DispatchQueue.main.async {
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }
  
  @IBAction func didTapStopTracing(_ sender: UIButton) {
    sender.isEnabled = false
    HyperTrace.shared().stop()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      sender.isEnabled = true
      self.updateTracingStackView()
    }
  }
  
  func showAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let closeAction = UIAlertAction(title: "Close", style: .default, handler: nil)
    alert.addAction(closeAction)
    self.present(alert, animated: true, completion: nil)
  }
  
  @IBAction func didTapViewLogs(_ sender: Any) {
    self.showLogs()
  }
}
