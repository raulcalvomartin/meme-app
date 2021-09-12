//
//  ViewController.swift
//  meme-app
//
//  Created by raul_builder on 30.07.2021.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    // MARK: instance elements
    
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!

    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "Impact", size: 40)!,
        NSAttributedString.Key.strokeWidth:  6
    ]

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        topText.delegate = self
        bottomText.delegate = self
        topText.textAlignment = .center
        bottomText.textAlignment = .center
        topText.defaultTextAttributes = memeTextAttributes
        bottomText.defaultTextAttributes = memeTextAttributes
        shareButton.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }

    @IBAction func share(_ sender: Any) {
        guard shareButton.isEnabled else {
            return
        }
        
        let image = generateMemedImage()
        let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activity, animated: true)
    }

    @IBAction func pickFromCamera(_ sender: Any) {
        pickImage(from: .camera)
    }

    @IBAction func pickFromGallery(_ sender: Any) {
        pickImage(from: .photoLibrary)
    }

    @IBAction func cancel(_ sender: Any) {
        topText.text = nil
        bottomText.text = nil
        imageView.image = nil
        shareButton.isEnabled = false
    }

    private func pickImage(from source: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = source
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[.originalImage] as? UIImage {
            imageView.image = img
            shareButton.isEnabled = true
        }
        dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }

    @objc func onKeyboradAppears(_ notification: Notification) {
        view.frame.origin.y = -getKeyboardHeight(notification)
    }

    @objc func onKeyboardDissapear(_ notification: Notification) {
        view.frame.origin.y = 0
    }

    private func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboradAppears(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardDissapear(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }

    private func unsubscribeFromKeyboardNotifications() {

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
    }

    private func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }

    private func save() {
        // Create the meme
        _ = Meme(topLabel: topText.text!, bottomLabel: bottomText.text!, originalImage: imageView.image!, memedImage: generateMemedImage())
    }

    private func generateMemedImage() -> UIImage {
        
        bottomToolbar.isHidden = true
        topToolbar.isHidden = true
        
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        
        bottomToolbar.isHidden = false
        topToolbar.isHidden = false

        return memedImage
    }
}

