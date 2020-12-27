//
//  ImagePicker.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 01/10/2020.
//

import SwiftUI
import Combine
import CloudKit

// YouTube: iOS 13 Swift UI Tutorial: Use UIKit Components with Swift UI

class ImagePicker: ObservableObject {

    static let shared: ImagePicker = ImagePicker()
    init() {}

    let view = ImagePicker.View()
    let coordinator = ImagePicker.Coordinator()

    let willChangeImage = PassthroughSubject<UIImage?, Never>()
    let willChangeImageFileURL = PassthroughSubject<URL?, Never>()

    @Published var image: UIImage? = nil {
        didSet {
            if image != nil {
                willChangeImage.send(image)
            }
        }
    }

    @Published var imageFileURL: URL? = nil {
        didSet {
            if imageFileURL != nil {
                willChangeImageFileURL.send(imageFileURL)
            }
        }
    }
}

extension ImagePicker {
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            /// Nullstiller bildet før en velger et nytt
            ImagePicker.shared.imageFileURL = nil

//            /// Velger ut et bilde med sin url
//            let urlOld = info[UIImagePickerController.InfoKey.imageURL] as! URL
//
            /// Redusere det valgte bildet  vha. func resizedImage() og original url
//            let size = CGSize(width: 40, height: 40)
//            let image = ResizedImage(at: urlOld, for: size)
//            ImagePicker.shared.image = image

            /// Lage ny url
            let fileManager = FileManager.default
            let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            let url = documentsPath?.appendingPathComponent("image.png")

            /// Lagre det reduserte bildet med ny url
//            if (info[UIImagePickerController.InfoKey.editedImage] as? UIImage) != nil {
               if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                /// compressionQuality : 0 == max compression    1 == ingen compression)
                ImagePicker.shared.image = image
                let imageData = image.jpegData(compressionQuality: 0.01) // .pngData()  /// .jpegData(compressionQuality: 1.0)
                try! imageData!.write(to: url!)
            }

            /// Bruker nå  ny url
            ImagePicker.shared.imageFileURL = url
            picker.dismiss(animated: true)
        }

    }
}

extension ImagePicker {
    struct View: UIViewControllerRepresentable {

        func makeCoordinator() -> Coordinator {
            return ImagePicker.shared.coordinator
        }

        func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker.View>) ->
            UIImagePickerController {
                let imagePickerController = UIImagePickerController()
                imagePickerController.delegate = context.coordinator
                imagePickerController.allowsEditing = true
                return imagePickerController

        }

        func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker.View>) {
        }

    }
}

