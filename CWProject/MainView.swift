//
//  MainView.swift
//  CWProject
//
//  Created by Anna on 21.11.2024.
//

import Foundation
import UIKit

class MainView: UIView {

    let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Параллельно", "Последовательно"])
        control.selectedSegmentIndex = 0
        return control
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.progress = 0
        return progress
    }()
    
    let resultLabel: UILabel = {
        let label = UILabel()
        label.text = "Результат: 0"
        label.textAlignment = .center
        return label
    }()
    
    let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Начать вычисления", for: .normal)
        return button
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.red, for: .normal)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        
        addSubview(segmentedControl)
        addSubview(collectionView)
        addSubview(progressView)
        addSubview(resultLabel)
        addSubview(startButton)
        addSubview(cancelButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        startButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
 
            segmentedControl.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            collectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            collectionView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.6),
            
            progressView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 10),
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            resultLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 10),
            resultLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            resultLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            startButton.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 10),
            startButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            cancelButton.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 10),
            cancelButton.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
