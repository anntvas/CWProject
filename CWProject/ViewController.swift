//
//  ViewController.swift
//  CWProject
//
//  Created by Anna on 21.11.2024.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource {
    // MARK: - Properties
    private let mainView = MainView()
    private var images: [UIImage] = [] // Исходные изображения
    private var filteredImages: [UIImage] = [] // Изображения с фильтрами
    private var isSequentialProcessing: Bool {
        mainView.segmentedControl.selectedSegmentIndex == 1
    }
    
    // MARK: - Lifecycle
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        loadImages()
        setupActions()
    }
    
    // MARK: - Setup
    private func setupCollectionView() {
        mainView.collectionView.dataSource = self
        mainView.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    private func setupActions() {
        mainView.startButton.addTarget(self, action: #selector(startCalculations), for: .touchUpInside)
    }
    
    private func loadImages() {
        // Загрузка изображений в массив
        images = (1...10).compactMap { UIImage(named: "image\($0)") }
        filteredImages = images
    }
    
    // MARK: - Actions
    @objc private func startCalculations() {
        applyFilters()
    }
    
    private func applyFilters() {
        if isSequentialProcessing {
            processSequentially()
        } else {
            processInParallel()
        }
    }
    
    private func processSequentially() {
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
    
    private func processInParallel() {
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
    
    // MARK: - UICollectionViewDataSource
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

