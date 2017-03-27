//
//  SourceUrlViewController.swift
//  Cookery
//
//  Created by Nicole Crawford on 3/16/17.
//  Copyright © 2017 Nicole Crawford. All rights reserved.
//

import MessageUI
import UIKit

class SourceUrlViewController: UIViewController, UIWebViewDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {
    
    // Public API
    
    @IBOutlet weak var webView: UIWebView! {
        didSet {
            webView.delegate = self
            updateUI()
        }
    }
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    @IBAction func close(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true)
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func shareRecipe(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Share Options", message: "Share a link to this recipe with a friend.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Message", style: .default) {
            [weak self] (action: UIAlertAction) -> Void in
            if MFMessageComposeViewController.canSendText() {
                let messageViewController = MFMessageComposeViewController()
                messageViewController.messageComposeDelegate = self
                messageViewController.body = "I found a recipe I thought you might like at \((self?.sourceUrl)!)"
                self?.present(messageViewController, animated: true, completion: nil)
            }
            else {
                let alert = UIAlertController(title: "Error Using Messages", message: "Your device currently cannot send messages.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        })
        alert.addAction(UIAlertAction(title: "Email", style: .default) {
            [weak self] (action: UIAlertAction) -> Void in
            if MFMailComposeViewController.canSendMail() {
                let mailViewController = MFMailComposeViewController()
                mailViewController.mailComposeDelegate = self
                mailViewController.setSubject("A tasty recipe found via Cookery")
                mailViewController.setMessageBody("I found a recipe I thought you might like at \((self?.sourceUrl)!)", isHTML: false)
                self?.present(mailViewController, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Error Using Mail", message: "You need to set up mail on your device before using this feature.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) {
            (action: UIAlertAction) -> Void in
            // do nothing
        })
        alert.popoverPresentationController?.barButtonItem = shareButton
        present(alert, animated: true, completion: nil)
    }
    
    var sourceUrl: String? { didSet { updateUI() } }
    
    // MARK: - Web view delegate
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator?.stopAnimating()
        webView.isHidden = false
    }
    
    // MARK: MFMessageComposeViewController delegate
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        dismiss(animated: true)
        switch result {
        case .cancelled:
            break
        case .sent:
            let alert = UIAlertController(title: "Message Sent", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        case .failed:
            let alert = UIAlertController(title: "Error Sending Message", message: "Your message could not be sent.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    // MARK: MFMailComposeViewController delegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true)
        if error != nil { print(error!) }
        switch result {
        case .cancelled:
            break
        case .sent:
            let alert = UIAlertController(title: "Mail Sent", message: "Your email has been sent to your Outbox.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        case .failed:
            let alert = UIAlertController(title: "Error Sending Mail", message: "Your email could not be sent.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        case .saved:
            let alert = UIAlertController(title: "Mail Saved", message: "Your email was saved.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    // Private implementation
    
    private func updateUI() {
        if sourceUrl != nil, let url = URL(string: sourceUrl!) {
            webView?.isHidden = true
            activityIndicator?.hidesWhenStopped = true
            activityIndicator?.startAnimating()
            let request = URLRequest(url: url)
            webView?.loadRequest(request)
        }
    }
    
}
