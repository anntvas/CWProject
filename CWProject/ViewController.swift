//
//  ViewController.swift
//  CWProject
//
//  Created by Anna on 21.11.2024.
//

import UIKit

class ViewController: UIViewController {
    // UI элементы
    private var collectionView: UICollectionView!
    private let segmentedControl = UISegmentedControl(items: ["Параллельно", "Последовательно"])
    private let startButton = UIButton(type: .system)
    private let progressView = UIProgressView(progressViewStyle: .default)
    private let resultLabel = UILabel()
    private let cancelButton = UIButton(type: .system)
    
    // Данные
    private var images: [UIImage] = []
    private var filteredImages: [UIImage] = []
    private var isSequentialProcessing = false
    private var task: Task<Void, Never>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        loadImages()
    }
    
    private func setupUI() {
        // Настройка UISegmentedControl
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        
        // Настройка кнопки
        startButton.setTitle("Начать вычисления", for: .normal)
        startButton.addTarget(self, action: #selector(startCalculations), for: .touchUpInside)
        
        cancelButton.setTitle("Отмена", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelCalculations), for: .touchUpInside)
        
        // Настройка UILabel
        resultLabel.text = "Результат:"
        resultLabel.textAlignment = .center
        
        // Настройка UIProgressView
        progressView.progress = 0.0
        
        // Настройка UICollectionView
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        // Добавление элементов на экран
        let stackView = UIStackView(arrangedSubviews: [
            segmentedControl,
            startButton,
            progressView,
            resultLabel,
            cancelButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // Layout
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            collectionView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadImages() {
        // Загружаем 10+ изображений из проекта
        for i in 1...10 {
            if let image = UIImage(named: "image\(i)") {
                images.append(image)
            }
        }
        filteredImages = images
        collectionView.reloadData()
    }
    
    @objc private func segmentedControlChanged() {
        isSequentialProcessing = (segmentedControl.selectedSegmentIndex == 1)
    }
    
    @objc private func startCalculations() {
        applyFilters()
        task = Task {
            await simulateCalculations()
        }
    }
    
    @objc private func cancelCalculations() {
        task?.cancel()
        progressView.progress = 0.0
        resultLabel.text = "Результат: отменено"
    }
    
    private func applyFilters() {
        if isSequentialProcessing {
            processSequentially()
        } else {
            processInParallel()
        }
    }

    // Последовательная обработка изображений
    private func processSequentially() {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1 // Последовательная обработка

        for (index, image) in images.enumerated() {
            queue.addOperation {
                let filteredImage = self.applyRandomFilter(to: image)
                DispatchQueue.main.async {
                    // Обновляем массив и соответствующую ячейку
                    self.filteredImages[index] = filteredImage
                    self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                }
            }
        }
    }

    // Параллельная обработка изображений
    private func processInParallel() {
        let group = DispatchGroup()
        let queue = DispatchQueue.global(qos: .userInitiated)

        for (index, image) in images.enumerated() {
            group.enter()
            queue.async {
                let filteredImage = self.applyRandomFilter(to: image)
                DispatchQueue.main.async {
                    // Обновляем массив и соответствующую ячейку
                    self.filteredImages[index] = filteredImage
                    self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            print("Обработка всех изображений завершена")
        }
    }

    private func applyRandomFilter(to image: UIImage) -> UIImage {
        let ciImage = CIImage(image: image)
        let filter = CIFilter(name: RandomFilter.random().rawValue)
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        guard let outputImage = filter?.outputImage else { return image }
        return UIImage(ciImage: outputImage)
    }
    
    private func simulateCalculations() async {
        let range = 1...20
        for i in range {
            guard !Task.isCancelled else { return }
            let factorial = await calculateFactorial(of: i)
            DispatchQueue.main.async {
                self.progressView.progress = Float(i) / Float(range.count)
                self.resultLabel.text = "Результат: \(i * 5)%"
            }
        }
    }
    
    private func calculateFactorial(of number: Int) async -> Int {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                let result = (1...number).reduce(1, *)
                continuation.resume(returning: result)
            }
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundView = UIImageView(image: filteredImages[indexPath.item])
        return cell
    }
}
