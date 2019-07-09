//
//  ImagePostViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import Photos

class ImagePostViewController: ShiftableViewController {
    
    var originalImage: UIImage? {
        didSet {
            updateImage()
        }
    }
    
    var comicModeOn: Bool = false
    
    @IBOutlet weak var bcsStackView: UIStackView!
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var contrastSlider: UISlider!
    @IBOutlet weak var saturationSlider: UISlider!
    
    
    @IBOutlet weak var exposureSlider: UISlider!
    @IBOutlet weak var gammaSlider: UISlider!
    @IBOutlet weak var zoomBlurSlider: UISlider!
    
    
    @IBOutlet weak var lightTunnelStackView: UIStackView!
    @IBOutlet weak var rotationSlider: UISlider!
    @IBOutlet weak var radiusSlider: UISlider!
    
    private let context = CIContext(options: nil)
    private let colorFilter = CIFilter(name: "CIColorControls")
    private let exposureFilter = CIFilter(name: "CIExposureAdjust")
    private let gammaFilter = CIFilter(name: "CIGammaAdjust")
    private let zoomBlurFilter = CIFilter(name: "CIZoomBlur")
    private let comicFilter = CIFilter(name: "CICommicEffect")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bcsStackView.isHidden = true
        exposureSlider.isHidden = true
        gammaSlider.isHidden = true
        zoomBlurSlider.isHidden = true
        
        setImageViewHeight(with: 1.0)
        
        updateViews()
    }
    
    func updateViews() {
        
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else {
                title = "New Post"
                return
        }
        
        title = post?.title
        
        setImageViewHeight(with: image.ratio)
        
        imageView.image = image
        
        chooseImageButton.setTitle("", for: [])
    }
    
    func updateImage() {
        if let originalImage = originalImage {
            imageView.image = image(byFiltering: originalImage)
        } else {
            imageView.image = nil
        }
    }
    
    
    private func image(byFiltering image: UIImage) -> UIImage {
        guard let cgImage = image.flattened.cgImage else { return image }
        let ciImage = CIImage(cgImage: cgImage)
        
        colorFilter?.setValue(ciImage, forKey: "inputImage")
        colorFilter?.setValue(brightnessSlider.value, forKey: "inputBrightness")
        colorFilter?.setValue(contrastSlider.value, forKey: "inputContrast")
        colorFilter?.setValue(saturationSlider.value, forKey: "inputSaturation")
        
        guard let colorImage = colorFilter?.outputImage else { return image }
        
        exposureFilter?.setValue(colorImage, forKey: "inputImage")
        exposureFilter?.setValue(exposureSlider.value, forKey: "inputEV")
        
        guard let exposureImage = exposureFilter?.outputImage else { return image }
        
        gammaFilter?.setValue(exposureImage, forKey: "inputImage")
        gammaFilter?.setValue(gammaSlider.value, forKey: "inputPower")
        
        guard let gammaImage = gammaFilter?.outputImage else { return image }
        
        zoomBlurFilter?.setValue(gammaImage, forKey: "inputImage")
        zoomBlurFilter?.setValue(CIVector(cgPoint: imageView.center), forKey: "inputCenter")
        zoomBlurFilter?.setValue(zoomBlurSlider.value, forKey: "inputAmount")
        
        guard let zoomImage = zoomBlurFilter?.outputImage else { return image }
        
        var outputCIImage: CIImage?
    
        if comicModeOn {
            comicFilter?.setValue(zoomImage, forKey: "inputImage")
            outputCIImage = comicFilter?.outputImage
        } else {
            outputCIImage = zoomImage
        }
        
        guard let outputImage = outputCIImage else { return image }
        
        guard let outputCGImage = context.createCGImage(outputImage, from: outputImage.extent) else { return image }
        
        return UIImage(cgImage: outputCGImage)
        
        
    }
    
    
    // MARK: - Edit ColorControls
    @IBAction func editBrightnessSaturationContrastButtonPressed(_ sender: Any) {
        if bcsStackView.isHidden {
            bcsStackView.isHidden = false
        } else {
            bcsStackView.isHidden = true
        }
    }
    
    @IBAction func brightnessValueChanged(_ sender: Any) {
        updateImage()
    }
    
    @IBAction func contrastValueChanged(_ sender: Any) {
        updateImage()
    }
    
    @IBAction func saturationValueChanged(_ sender: Any) {
        updateImage()
    }
    
    
    
    
    // MARK: - Edit Exposure
    @IBAction func editExposureButtonPressed(_ sender: Any) {
        if exposureSlider.isHidden {
            exposureSlider.isHidden = false
        } else {
            exposureSlider.isHidden = true
        }
    }
    
    @IBAction func exposureValueChanged(_ sender: Any) {
        updateImage()
    }
    
    
    
    
    // MARK: - Edit Gamma
    @IBAction func editGammaButtonPressed(_ sender: Any) {
        if gammaSlider.isHidden {
            gammaSlider.isHidden = false
        } else {
            gammaSlider.isHidden = true
        }
    }
    
    @IBAction func gammaValueChanged(_ sender: Any) {
        updateImage()
    }
    
    
    
    // MARK: - Edit Zoom Blur
    @IBAction func editZoomBlurButtonPressed(_ sender: Any) {
        if zoomBlurSlider.isHidden {
            zoomBlurSlider.isHidden = false
        } else {
            zoomBlurSlider.isHidden = true
        }
    }
    
    @IBAction func zoomBlurValueChanged(_ sender: Any) {
        updateImage()
    }
    
    

    
    // MARK: - Toggle Comic Mode

    @IBAction func toggleComicMode(_ sender: Any) {
        if comicModeOn == false {
            comicModeOn = true
        } else {
            comicModeOn = false
        }
        updateImage()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    private func presentImagePickerController() {
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            presentInformationalAlertController(title: "Error", message: "The photo library is unavailable")
            return
        }
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        imagePicker.sourceType = .photoLibrary

        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func createPost(_ sender: Any) {
        
        view.endEditing(true)
        
        guard let imageData = imageView.image?.jpegData(compressionQuality: 0.1),
            let title = titleTextField.text, title != "" else {
            presentInformationalAlertController(title: "Uh-oh", message: "Make sure that you add a photo and a caption before posting.")
            return
        }
        
        postController.createPost(with: title, ofType: .image, mediaData: imageData, ratio: imageView.image?.ratio) { (success) in
            guard success else {
                DispatchQueue.main.async {
                    self.presentInformationalAlertController(title: "Error", message: "Unable to create post. Try again.")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func chooseImage(_ sender: Any) {
        
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch authorizationStatus {
        case .authorized:
            presentImagePickerController()
        case .notDetermined:
            
            PHPhotoLibrary.requestAuthorization { (status) in
                
                guard status == .authorized else {
                    NSLog("User did not authorize access to the photo library")
                    self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
                    return
                }
                
                self.presentImagePickerController()
            }
            
        case .denied:
            self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
        case .restricted:
            self.presentInformationalAlertController(title: "Error", message: "Unable to access the photo library. Your device's restrictions do not allow access.")
            
        }
        presentImagePickerController()
    }
    
    func setImageViewHeight(with aspectRatio: CGFloat) {
        
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        
        view.layoutSubviews()
    }
    
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        chooseImageButton.setTitle("", for: [])
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        imageView.image = image
        
        originalImage = image
        
        setImageViewHeight(with: image.ratio)

    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
