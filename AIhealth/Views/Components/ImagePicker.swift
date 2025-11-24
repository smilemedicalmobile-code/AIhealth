//
//  ImagePicker.swift
//  AIhealth
//
//  Created on 2025-10-28.
//

import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedImage: UIImage?
    var sourceType: UIImagePickerController.SourceType = .photoLibrary

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()

        // Check if source type is available before setting it
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            picker.sourceType = sourceType
        } else {
            // Fallback to photo library if camera is not available
            picker.sourceType = .photoLibrary
            // Notify user via alert that camera is not available
            DispatchQueue.main.async {
                context.coordinator.showCameraUnavailableAlert()
            }
        }

        picker.delegate = context.coordinator
        picker.allowsEditing = false

        // iPad-specific configuration to prevent crashes
        if UIDevice.current.userInterfaceIdiom == .pad {
            picker.modalPresentationStyle = .fullScreen
        }

        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // MUST run on main thread to prevent crashes
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                // Safely extract the image
                if let image = info[.originalImage] as? UIImage {
                    // Resize image if needed to prevent memory issues on iPad
                    let resizedImage = self.resizeImage(image, targetSize: CGSize(width: 1920, height: 1920))
                    self.parent.selectedImage = resizedImage
                }

                // Dismiss picker with slight delay to ensure smooth transition
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.parent.dismiss()
                }
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            DispatchQueue.main.async { [weak self] in
                self?.parent.dismiss()
            }
        }

        // Resize image to prevent memory issues
        private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
            let size = image.size

            // If image is already smaller, return original
            if size.width <= targetSize.width && size.height <= targetSize.height {
                return image
            }

            let widthRatio  = targetSize.width  / size.width
            let heightRatio = targetSize.height / size.height
            let ratio = min(widthRatio, heightRatio)

            let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
            let rect = CGRect(origin: .zero, size: newSize)

            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return newImage ?? image
        }

        func showCameraUnavailableAlert() {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController else {
                return
            }

            let alert = UIAlertController(
                title: "camera_unavailable".localized,
                message: "camera_not_available_message".localized,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "confirm".localized, style: .default) { _ in
                self.parent.dismiss()
            })

            var presentingVC = rootViewController
            while let presented = presentingVC.presentedViewController {
                presentingVC = presented
            }
            presentingVC.present(alert, animated: true)
        }
    }
}
