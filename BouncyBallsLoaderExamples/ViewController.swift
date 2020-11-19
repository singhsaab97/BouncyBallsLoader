//
//  ViewController.swift
//  BouncyBallsLoaderExamples
//
//  Created by Abhijit Singh on 19/11/20.
//

import UIKit
import BouncyBallsLoader

class ViewController: UIViewController {
    
    private var loaders: [BouncyBallsLoader] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        startLoading()
        addTapGesture()
    }
    
    private func startLoading() {
        let directions: [BouncyBallsLoader.Direction] = [.up, .down, .left, .right]
        let loaderViewHeight: CGFloat = view.bounds.height / CGFloat(directions.count)
        directions.enumerated().forEach { (index, direction) in
            let loaderProperties: BouncyBallsLoader.Properties = .init(
                numberOfBalls: 4,
                radius: 8,
                colors: [.systemBlue, .systemRed, .systemYellow, .systemGreen],
                direction: direction,
                duration: 0.5
            )
            let loader: BouncyBallsLoader = .init(properties: loaderProperties)
            view.addSubview(loader)
            loaders.append(loader)
            loader.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            loader.centerYAnchor.constraint(
                equalTo: view.topAnchor,
                constant: CGFloat(index) * loaderViewHeight + loaderViewHeight / 2
            ).isActive = true
            loader.widthAnchor.constraint(equalToConstant: loader.optimalSize.width).isActive = true
            loader.heightAnchor.constraint(equalToConstant: loader.optimalSize.height).isActive = true
            
        }
    }
    
    private func addTapGesture() {
        view.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleViewTapped))
        )
    }
    
    @objc
    private func handleViewTapped() {
        loaders.forEach {
            $0.stopLoading()
        }
    }

}
