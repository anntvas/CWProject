//
//  ViewController.swift
//  CWProject
//
//  Created by Anna on 21.11.2024.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource {
    private let mainView = MainView()
    private var images: [UIImage] = []
    private var filteredImages: [UIImage] = []
    private var isSequentialProcessing: Bool {
        mainView.segmentedControl.selectedSegmentIndex == 1
    }
    private var task: Task<Void, Never>?

    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        loadImages()
        setupActions()
    }
    
    private func setupCollectionView() {
        mainView.collectionView.dataSource = self
        mainView.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    private func setupActions() {
        mainView.startButton.addTarget(self, action: #selector(startCalculations), for: .touchUpInside)
        mainView.cancelButton.addTarget(self, action: #selector(cancelCalculations), for: .touchUpInside)
    }
    
    @objc private func startCalculations() {
        task?.cancel()
        applyFilters()

        task = Task {
            await performLongCalculations()
        }
    }

    @objc private func cancelCalculations() {
        task?.cancel()
        mainView.progressView.progress = 0.0
        mainView.resultLabel.text = "Результат: отменено"
    }

    
    private func loadImages() {
        for i in 1...12 {
            if let image = UIImage(named: "image\(i)") {
                images.append(image)
            }
        }
        filteredImages = images
    }
    
    private func performLongCalculations() async {
        mainView.progressView.progress = 0
        mainView.resultLabel.text = "Результат:"

        let range = 1...20

        for i in range {
            guard !Task.isCancelled else { return }

            let factorialResult = await calculateFactorial(of: i)
            
            await MainActor.run {
                mainView.progressView.progress = Float(i) / Float(range.count)
                mainView.resultLabel.text = "Результат: \(i * 5)%"
            }
        }
    }

    private func calculateFactorial(of number: Int) async -> Int {
        return await Task { () -> Int in
            var result = 1
            for i in 1...number {
                result *= i
            }
            return result
        }.value
    }

    
    private func applyFilters() {
        if isSequentialProcessing {
            processSerial()
        } else {
            processConcurrent()
        }
    }
    
    private func processSerial() {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        for (index, image) in images.enumerated() {
            queue.addOperation {
                let filteredImage = ImageProcessor.shared.applyRandomFilter(to: image)
                DispatchQueue.main.async {
                    self.filteredImages[index] = filteredImage
                    self.mainView.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                }
            }
        }
    }
    
    private func processConcurrent() {
        let queue = DispatchQueue.global(qos: .userInitiated)
        let group = DispatchGroup()
        
        for (index, image) in images.enumerated() {
            group.enter()
            queue.async {
                let filteredImage = ImageProcessor.shared.applyRandomFilter(to: image)
                DispatchQueue.main.async {
                    self.filteredImages[index] = filteredImage
                    self.mainView.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            print("Обработка завершена")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let imageView = UIImageView(image: filteredImages[indexPath.item])
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        cell.contentView.addSubview(imageView)
        imageView.frame = cell.contentView.bounds
        return cell
    }
}

