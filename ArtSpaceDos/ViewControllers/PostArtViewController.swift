//
//  PostArtViewController.swift
//  ArtSpaceDos
//
//  Created by Adam Jackson on 4/11/20.
//  Copyright © 2020 Adam Jackson. All rights reserved.
//
//

//MARK: Refactor and Organize
import MaterialComponents.MaterialTextFields

final class PostArtViewController: UIViewController {
    
    var image = UIImage() {
        didSet {
            self.artView.image = image
        }
    }
    
    var imageURL: URL? = nil
    
    var currentUser: AppUser? = nil
    
    let scrollView = UIScrollView()
    
    //MARK: Tags For Post
    lazy var photographyTag: TagButton = {
        let button = TagButton()
        button.setupTagButton(button, title: "Photography", systemName: "camera", target: self, action: #selector(addOrRemoveTags(_:)))
        button.isFiltering = false
        button.tag = 0
        return button
    }()
    
    lazy var paintingTag: TagButton = {
        let button = TagButton()
        button.setupTagButton(button, title: "Paintings", systemName: "paintbrush", target: self, action: #selector(addOrRemoveTags(_:)))
        button.isFiltering = false
        button.tag = 1
        return button
    }()
    
    lazy var drawingTag: TagButton = {
        let button = TagButton()
        button.setupTagButton(button, title: "Drawings", systemName: "pencil.and.outline", target: self, action: #selector(addOrRemoveTags(_:)))
        button.isFiltering = false
        button.tag = 2
        return button
    }()
    
    lazy var newMediaTag: TagButton = {
        let button = TagButton()
        button.setupTagButton(button, title: "New Media", systemName: "faceid", target: self, action: #selector(addOrRemoveTags(_:)))
        button.tag = 3
        button.isFiltering = false
        return button
    }()
    
    //MARK: UI
    
    lazy var pageTitle: UILabel = {
        let label = UILabel()
        UIUtilities.setUILabel(label, labelTitle: "Upload Your Art", size: 30, alignment: .left)
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 30)
        return label
    }()
    
    lazy var postButton: UIButton = {
        let button = UIButton()
        UIUtilities.setUpButton(button, title: "Post", backgroundColor: .white, target: self, action: #selector(postToFirebase))
        button.setTitleColor(ArtSpaceConstants.artSpaceBlue, for: .normal)
        return button
    }()
    lazy var uploadButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(uploadButtonPressed), for: .touchUpInside)
        return button
    }()
    
    lazy var tagTitle: UILabel = {
        let label = UILabel()
        UIUtilities.setUILabel(label, labelTitle: "Select The Tags Describing your Art", size: 15, alignment: .left)
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    
    lazy var artView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        
        imageView.contentMode = .scaleAspectFit
        
        imageView.image = #imageLiteral(resourceName: "noimage")
        return imageView
    }()
    //MARK: Text Fields
    let artName: MDCTextField = {
        let name = MDCTextField()
        name.translatesAutoresizingMaskIntoConstraints = false
        name.autocapitalizationType = .words
        name.leadingUnderlineLabel.textColor = .white
        name.cursorColor = .white
        name.underline?.color = .white
        return name
    }()
    
    let width: MDCTextField = {
        let address = MDCTextField()
        address.translatesAutoresizingMaskIntoConstraints = false
        address.autocapitalizationType = .words
        return address
    }()
    let widthController: MDCTextInputControllerUnderline
    
    let height: MDCTextField = {
        let city = MDCTextField()
        city.translatesAutoresizingMaskIntoConstraints = false
        city.autocapitalizationType = .words
        return city
    }()
    let heightController: MDCTextInputControllerUnderline
    
    let state: MDCTextField = {
        let state = MDCTextField()
        state.translatesAutoresizingMaskIntoConstraints = false
        state.autocapitalizationType = .allCharacters
        return state
    }()
    let stateController: MDCTextInputControllerUnderline
    
    let zip: MDCTextField = {
        let zip = MDCTextField()
        zip.translatesAutoresizingMaskIntoConstraints = false
        return zip
    }()
    let zipController: MDCTextInputControllerUnderline
    
    let artPrice: MDCTextField = {
        let phone = MDCTextField()
        phone.translatesAutoresizingMaskIntoConstraints = false
        return phone
    }()
    let phoneController: MDCTextInputControllerUnderline
    
    let message: MDCMultilineTextField = {
        let message = MDCMultilineTextField()
        message.translatesAutoresizingMaskIntoConstraints = false
        return message
    }()
    
    var allTextFieldControllers = [MDCTextInputControllerUnderline]()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        stateController = MDCTextInputControllerUnderline(textInput: state)
        heightController = MDCTextInputControllerUnderline(textInput: height)
        widthController = MDCTextInputControllerUnderline(textInput: width)
        zipController = MDCTextInputControllerUnderline(textInput: zip)
        phoneController = MDCTextInputControllerUnderline(textInput: artPrice)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func addOrRemoveTags(_ sender: TagButton) {
        
    }
    @objc func postToFirebase() {
        guard let photoURL = imageURL else {return}
        let photoURLString = "\(photoURL)"
        
        guard self.currentUser != nil else {showAlert(with: "Error", and: "No valid user"); return}
        
        guard let artist = self.currentUser else {showAlert(with: "Error", and: "No valid user"); return}
        
        guard message.text != "", artName.text != "", width.text != "", height.text != "", artPrice.text != "" else {showAlert(with: "Error", and: "Fill out all fields"); return}
        
        guard let description = message.text, let widthString = width.text, let heightString = height.text, let priceString = artPrice.text else {showAlert(with: "Error", and: "Invalid entry; check fields"); return}
        
        let priceDouble: Double? = Double((priceString as NSString).floatValue)
        let widthCGFloat: CGFloat? = CGFloat((widthString as NSString).floatValue)
        let heightCGFloat: CGFloat? = CGFloat((heightString as NSString).floatValue)
        
        if let price = priceDouble, let width = widthCGFloat, let height = heightCGFloat {
            guard price != 0.0, width != 0.0, height != 0.0 else {showAlert(with: "Error", and: "Invalid entry; check fields"); return}
            let newArtObject = ArtObject(artistName: artist.userName ?? "No artist name", artDescription: description, width: (width / 100) , height: (height / 100), artImageURL: photoURLString, sellerID: artName.text!, price: price, tags: ["2"], soldStatus: false)
            
            FirestoreService.manager.createArtObject(artObject: newArtObject) { (result) in
                switch result {
                case .failure(let error):
                    print(error)
                    self.showAlert(with: "Error", and: "Could not save item")
                case .success(()):
                    self.showAlert(with: "Art Posted", and: "Now Available For Sale!")
                }
            }
        } else {
            showAlert(with: "Error", and: "Invalid entry; check fields")
        }
    }
    
    private func showAlert(with title: String, and message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
        print("Submit Button Pressed. Data gets loaded intro Firebase")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ArtSpaceConstants.artSpaceBlue
        getCurrentUser()
        setupScrollView()
        setupTextFields()
        registerKeyboardNotifications()
        addGestureRecognizer()
        
        let styleButton = UIBarButtonItem(title: "Style",
                                          style: .plain,
                                          target: self,
                                          action: #selector(buttonDidTouch(sender: )))
        self.navigationItem.rightBarButtonItem = styleButton
    }
    
    private func getCurrentUser() {
        guard let user = FirebaseAuthService.manager.currentUser else {return}
        
        FirestoreService.manager.getCurrentAppUser(uid: user.uid) { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let user):
                self.currentUser = user
                
            }
        }
        
    }
    
    @objc func uploadButtonPressed() {
        self.showActivityIndicator(shouldShow: true)
        
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.delegate = self
        present(imagePickerVC, animated: true)
    }
    
    
    func setupTextFields() {
        scrollView.addSubview(pageTitle)
        scrollView.addSubview(artView)
        scrollView.addSubview(artName)
        let nameController = MDCTextInputControllerUnderline(textInput: artName)
        artName.delegate = self
        artName.text = ""
        artName.textColor = .white
        artName.underline?.color = .white
        artName.translatesAutoresizingMaskIntoConstraints = false
        nameController.placeholderText = "Art Name"
        nameController.normalColor = .white
        nameController.activeColor = .white
        nameController.disabledColor = .white
        nameController.inlinePlaceholderColor = .white
        nameController.floatingPlaceholderActiveColor = .white
        nameController.trailingUnderlineLabelTextColor = .white
        nameController.helperText = "Title Of Piece"
        allTextFieldControllers.append(nameController)
        
        scrollView.addSubview(width)
        width.delegate = self
        
        widthController.placeholderText = "Width"
        widthController.helperText = "Centimeters"
        widthController.normalColor = .white
        widthController.activeColor = .white
        widthController.disabledColor = .white
        widthController.inlinePlaceholderColor = .white
        widthController.floatingPlaceholderActiveColor = .white
        widthController.trailingUnderlineLabelTextColor = .white
        allTextFieldControllers.append(widthController)
        
        scrollView.addSubview(height)
        height.delegate = self
        heightController.placeholderText = "Height"
        heightController.helperText = "Centimeters"
        heightController.normalColor = .white
        heightController.activeColor = .white
        heightController.disabledColor = .white
        heightController.inlinePlaceholderColor = .white
        heightController.floatingPlaceholderActiveColor = .white
        heightController.trailingUnderlineLabelTextColor = .white
        allTextFieldControllers.append(heightController)

        scrollView.addSubview(artPrice)
        artPrice.delegate = self
        phoneController.placeholderText = "Price - $$$"
        phoneController.helperText = ""
        phoneController.normalColor = .white
        phoneController.activeColor = .white
        phoneController.disabledColor = .white
        phoneController.inlinePlaceholderColor = .white
        phoneController.floatingPlaceholderActiveColor = .white
        phoneController.trailingUnderlineLabelTextColor = .white
        allTextFieldControllers.append(phoneController)
        
        scrollView.addSubview(message)
        let messageController = MDCTextInputControllerUnderline(textInput: message)
        message.textView?.delegate = self
        
        message.multilineDelegate = self
        messageController.placeholderText = "Message"
        messageController.helperText = "Describe Your Art"
        messageController.normalColor = .white
        messageController.activeColor = .white
        messageController.disabledColor = .white
        messageController.inlinePlaceholderColor = .white
        messageController.floatingPlaceholderActiveColor = .white
        messageController.trailingUnderlineLabelTextColor = .white
        allTextFieldControllers.append(messageController)
        
        var tag = 0
        for controller in allTextFieldControllers {
            guard let textField = controller.textInput as? MDCTextField else { continue }
            textField.tag = tag
            tag += 1
        }
        pageTitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageTitle.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 30),
            pageTitle.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        ])
        artView.translatesAutoresizingMaskIntoConstraints = false
        uploadButton.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(uploadButton)
        NSLayoutConstraint.activate([
            artView.topAnchor.constraint(equalTo: pageTitle.bottomAnchor,constant: 5),
            artView.leftAnchor.constraint(equalTo: self.view.leftAnchor,constant: 10),
            artView.widthAnchor.constraint(equalToConstant: view.frame.width / 4),
            
            artView.heightAnchor.constraint(equalToConstant: view.frame.height / 5)
        ])
        
        NSLayoutConstraint.activate([
            uploadButton.topAnchor.constraint(equalTo:artView.topAnchor),
            uploadButton.leftAnchor.constraint(equalTo: artView.leftAnchor),
            uploadButton.rightAnchor.constraint(equalTo: artView.rightAnchor),
            uploadButton.bottomAnchor.constraint(equalTo:  artView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            artName.topAnchor.constraint(equalTo: artView.topAnchor),
            artName.leftAnchor.constraint(equalTo: artView.rightAnchor, constant: 20),
            artName.widthAnchor.constraint(equalToConstant: view.frame.width / 2)
        ])
        
        NSLayoutConstraint.activate([
            artPrice.topAnchor.constraint(equalTo: artName.bottomAnchor), artPrice.leftAnchor.constraint(equalTo: artName.leftAnchor),
            artPrice.widthAnchor.constraint(equalToConstant: view.frame.width / 2)
            
        ])
        
        NSLayoutConstraint.activate([
            width.topAnchor.constraint(equalTo: artView.bottomAnchor),
            width.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 10),
            width.widthAnchor.constraint(equalToConstant: view.frame.width / 3)
        ])
        
        NSLayoutConstraint.activate([
            height.leftAnchor.constraint(equalTo: width.rightAnchor, constant: 40),
            height.topAnchor.constraint(equalTo: width.topAnchor),
            height.widthAnchor.constraint(equalToConstant: view.frame.width / 3)
        ])
        
        NSLayoutConstraint.activate([
            message.topAnchor.constraint(equalTo: height.bottomAnchor, constant: 3),
            message.leftAnchor.constraint(equalTo: width.leftAnchor),
            message.widthAnchor.constraint(equalToConstant: view.frame.width / 0.9)
        ])
        scrollView.addSubview(tagTitle)
        tagTitle.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tagTitle.topAnchor.constraint(equalTo: message.bottomAnchor, constant: 10),
            tagTitle.leftAnchor.constraint(equalTo: message.leftAnchor),
            tagTitle.widthAnchor.constraint(equalToConstant: view.frame.width),
        ])
        
        scrollView.addSubview(paintingTag)
        paintingTag.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            paintingTag.topAnchor.constraint(equalTo: tagTitle.bottomAnchor,constant: 8),
            paintingTag.leftAnchor.constraint(equalTo: tagTitle.leftAnchor),
            paintingTag.widthAnchor.constraint(equalToConstant: 120),
            paintingTag.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        scrollView.addSubview(photographyTag)
        photographyTag.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            photographyTag.topAnchor.constraint(equalTo: paintingTag.topAnchor),
            photographyTag.leftAnchor.constraint(equalTo: paintingTag.rightAnchor,constant:  10),
            photographyTag.widthAnchor.constraint(equalToConstant: paintingTag.frame.width),
            photographyTag.heightAnchor.constraint(equalToConstant: paintingTag.frame.height)
        ])
        
        scrollView.addSubview(drawingTag)
        drawingTag.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            drawingTag.leftAnchor.constraint(equalTo: paintingTag.leftAnchor, constant: 20),
            drawingTag.topAnchor.constraint(equalTo: photographyTag.bottomAnchor,constant: 15),
            drawingTag.widthAnchor.constraint(equalToConstant: photographyTag.frame.width),
            drawingTag.heightAnchor.constraint(equalToConstant: photographyTag.frame.height)
        ])
        
        scrollView.addSubview(newMediaTag)
        newMediaTag.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            newMediaTag.leftAnchor.constraint(equalTo: drawingTag.rightAnchor,constant: 20),
            newMediaTag.topAnchor.constraint(equalTo: drawingTag.topAnchor),
            newMediaTag.widthAnchor.constraint(equalToConstant: photographyTag.frame.width),
            newMediaTag.heightAnchor.constraint(equalToConstant: photographyTag.frame.height)
        ])
        
        scrollView.addSubview(postButton)
        postButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            postButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            postButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            postButton.heightAnchor.constraint(equalToConstant: view.frame.height / 11),
            postButton.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -50)
            
        ])
        
        
        
        
    }
    
    func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[scrollView]|",
            options: [],
            metrics: nil,
            views: ["scrollView": scrollView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|",
                                                                   options: [],
                                                                   metrics: nil,
                                                                   views: ["scrollView": scrollView]))
        let marginOffset: CGFloat = 16
        let margins = UIEdgeInsets(top: 0, left: marginOffset, bottom: 0, right: marginOffset)
        
        scrollView.layoutMargins = margins
    }
    
    func addGestureRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self,
                                                   action: #selector(tapDidTouch(sender: )))
        self.scrollView.addGestureRecognizer(tapRecognizer)
    }
    
    // MARK: - Actions
    @objc func tapDidTouch(sender: Any) {
        self.view.endEditing(true)
    }
    
    @objc func buttonDidTouch(sender: Any) {
        let isFloatingEnabled = allTextFieldControllers.first?.isFloatingEnabled ?? false
        let alert = UIAlertController(title: "Floating Labels",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        
        let defaultAction = UIAlertAction(title: "Default (Yes)" + (isFloatingEnabled ? " ✓" : ""),
                                          style: .default) { _ in
                                            self.allTextFieldControllers.forEach({ (controller) in
                                                controller.isFloatingEnabled = true
                                            })
        }
        alert.addAction(defaultAction)
        let floatingAction = UIAlertAction(title: "No" + (isFloatingEnabled ? "" : " ✓"),
                                           style: .default) { _ in
                                            self.allTextFieldControllers.forEach({ (controller) in
                                                controller.isFloatingEnabled = false
                                            })
        }
        alert.addAction(floatingAction)
        present(alert, animated: true, completion: nil)
    }
}

extension PostArtViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let rawText = textField.text else {
            return true
        }
        
        let fullString = NSString(string: rawText).replacingCharacters(in: range, with: string)
        
        if textField == state {
            if let range = fullString.rangeOfCharacter(from: CharacterSet.letters.inverted),
                String(fullString[range]).characterCount > 0 {
                stateController.setErrorText("Error: State can only contain letters",
                                             errorAccessibilityValue: nil)
            } else {
                stateController.setErrorText(nil, errorAccessibilityValue: nil)
            }
        } else if textField == zip {
            if let range = fullString.rangeOfCharacter(from: CharacterSet.letters),
                String(fullString[range]).characterCount > 0 {
                zipController.setErrorText("Error: Zip can only contain numbers",
                                           errorAccessibilityValue: nil)
            } else if fullString.characterCount > 5 {
                zipController.setErrorText("Error: Zip can only contain five digits",
                                           errorAccessibilityValue: nil)
            } else {
                zipController.setErrorText(nil, errorAccessibilityValue: nil)
            }
        } else if textField == height || textField == width || textField == artPrice {
            if let range = fullString.rangeOfCharacter(from: CharacterSet.letters),
                String(fullString[range]).characterCount > 0 {
                if textField == height {
                    heightController.setErrorText("Numbers only",
                                                  errorAccessibilityValue: nil)
                }
                if textField == width {
                    widthController.setErrorText("Numbers only", errorAccessibilityValue: nil)
                }
                if textField == artPrice {
                    phoneController.setErrorText("Numbers only", errorAccessibilityValue: nil)
                }
            }
                
                
            else {
                heightController.setErrorText(nil, errorAccessibilityValue: nil)
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let index = textField.tag
        if index + 1 < allTextFieldControllers.count,
            let nextField = allTextFieldControllers[index + 1].textInput {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return false
    }
}

extension PostArtViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        print(textView.text)
    }
}

extension PostArtViewController: MDCMultilineTextInputDelegate {
    private func multilineTextFieldShouldClear(_ textField: UIView!) -> Bool {
        return true
    }
}

//Users/god/Desktop/Portfolio Work/Capstone-ArtSpace/ArtSpaceDos.xcodeproj/ MARK: - Keyboard Handling
extension PostArtViewController {
    func registerKeyboardNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(keyboardWillShow(notif:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        notificationCenter.addObserver(
            self,
            selector: #selector(keyboardWillHide(notif:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
        notificationCenter.addObserver(
            self,
            selector: #selector(keyboardWillShow(notif:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil)
    }
    
    @objc func keyboardWillShow(notif: Notification) {
        guard let frame = notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        scrollView.contentInset = UIEdgeInsets(top: 0.0,
                                               left: 0.0,
                                               bottom: frame.height,
                                               right: 0.0)
    }
    
    @objc func keyboardWillHide(notif: Notification) {
        scrollView.contentInset = UIEdgeInsets()
    }
}

// MARK: - Status Bar Style
extension PostArtViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: - CatalogByConvention
extension PostArtViewController {
    
    @objc class func catalogMetadata() -> [String: Any] {
        return [
            "breadcrumbs": ["Text Field", "Underline Style"],
            "description": "Text fields let users enter and edit text.",
            "primaryDemo": false,
            "presentable": false,
        ]
    }
}

internal extension String {
    var characterCount: Int {
        return self.count
    }
}


//MARK: - Extensions
extension PostArtViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        self.image = image
        
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {return}
        //MARK: To Do - Refactor when Image is being saved
        FirebaseStorageService.manager.storeImage(pictureType: .artPiece, image: imageData) { [weak self] (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let url):
                self?.imageURL = url
            }
        }
        
        self.showActivityIndicator(shouldShow: false)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.showActivityIndicator(shouldShow: false)
        self.dismiss(animated: true, completion: nil)
    }
}

