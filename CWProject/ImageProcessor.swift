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
    
    // Применение случайного фильтра к изображению
    func applyRandomFilter(to image: UIImage) -> UIImage {
        let ciImage = CIImage(image: image)
        let filter = CIFilter(name: "CIPhotoEffectMono") // Пример фильтра
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard let outputImage = filter?.outputImage else { return image }
        return UIImage(ciImage: outputImage)
    }
    
    // Симуляция долгих вычислений
    func simulateCalculations(range: Range<Int>, progress: @escaping (Float, Int) -> Void) async {
        for i in range {
            guard !Task.isCancelled else { return }
            let result = await calculateFactorial(of: i)
            let progressValue = Float(i) / Float(range.count)
            DispatchQueue.main.async {
                progress(progressValue, result)
            }
        }
    }
    
    // Вычисление факториала числа
    private func calculateFactorial(of number: Int) async -> Int {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                let result = (1...max(1, number)).reduce(1, *)
                continuation.resume(returning: result)
            }
        }
    }
}
