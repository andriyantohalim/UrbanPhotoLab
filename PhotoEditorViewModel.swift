//
//  PhotoEditorViewModel.swift
//  UrbanPhotoLab
//
//  Created by Andriyanto Halim on 26/10/24.
//

import SwiftUI
import Photos
import CoreImage
import CoreImage.CIFilterBuiltins

class PhotoEditorViewModel: ObservableObject {
    @Published var filteredImage: UIImage?
    @Published var showPhotoPicker = false
    @Published var showSaveAlert = false
    @Published var saveMessage = ""
    
    private var originalImage: UIImage?
    private let context = CIContext()
    
    func loadImage(_ image: UIImage) {
        self.originalImage = image
        self.filteredImage = image
    }
    
    func applyFilter(type: FilterType) {
        guard let originalImage = originalImage,
              let ciImage = CIImage(image: originalImage) else {
            return
        }
        
        let filter: CIFilter
        switch type {
        case .monochrome:
            let monochromeFilter = CIFilter.colorMonochrome()
            monochromeFilter.inputImage = ciImage
            monochromeFilter.intensity = 1.0
            monochromeFilter.color = CIColor.black
            filter = monochromeFilter
        case .sepia:
            let sepiaFilter = CIFilter.sepiaTone()
            sepiaFilter.inputImage = ciImage
            sepiaFilter.intensity = 1.0
            filter = sepiaFilter
        case .noir:
            let noirFilter = CIFilter.photoEffectNoir()
            noirFilter.inputImage = ciImage
            filter = noirFilter
            
        case .bloom:
            let bloomFilter = CIFilter.bloom()
            bloomFilter.inputImage = ciImage
            bloomFilter.intensity = 0.8
            bloomFilter.radius = 10.0
            filter = bloomFilter
            
        case .vignette:
            let vignetteFilter = CIFilter.vignette()
            vignetteFilter.inputImage = ciImage
            vignetteFilter.intensity = 1.0
            vignetteFilter.radius = 2.0
            filter = vignetteFilter
            
        case .invert:
            let invertFilter = CIFilter.colorInvert()
            invertFilter.inputImage = ciImage
            filter = invertFilter
            
        case .crystallize:
            let crystallizeFilter = CIFilter.crystallize()
            crystallizeFilter.inputImage = ciImage
            crystallizeFilter.radius = 20.0
            filter = crystallizeFilter
        }
        
        guard let outputImage = filter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return
        }
        
        DispatchQueue.main.async {
            self.filteredImage = UIImage(cgImage: cgImage)
        }
    }
    
    func saveImage() {
        guard let filteredImage = filteredImage else { return }
        
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                DispatchQueue.main.async {
                    self.saveMessage = "Photo library access denied."
                    self.showSaveAlert = true
                }
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: filteredImage)
            }) { success, error in
                DispatchQueue.main.async {
                    if success {
                        self.saveMessage = "Image saved successfully!"
                    } else {
                        self.saveMessage = error?.localizedDescription ?? "Failed to save image."
                    }
                    self.showSaveAlert = true
                }
            }
        }
    }
}

