//
//  ImageProcessor.swift
//  CWProject
//
//  Created by Anna on 21.11.2024.
//

import Foundation
import UIKit
import CoreImage

class ImageProcessor {
    static let shared = ImageProcessor()
    private init() {}
    
    func applyRandomFilter(to image: UIImage) -> UIImage {
        let ciImage = CIImage(image: image)
        let filter = CIFilter(name: RandomFilter.random().rawValue) // Пример фильтра
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard let outputImage = filter?.outputImage else { return image }
        return UIImage(ciImage: outputImage)
    }

}
