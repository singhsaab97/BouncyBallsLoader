//
//  BouncyBallsLoader.swift
//  BouncyBallsLoader
//
//  Created by Abhijit Singh on 19/11/20.
//

import UIKit

final public class BouncyBallsLoader: UIView {

    public enum Direction {
        case up, down, left, right
    }
    
    /// Dependency for loader
    /// - Parameters:
    ///     - numberOfBalls: Count of balls in the loader
    ///     - radius: Determines the size of each ball
    ///     - colors: Color each ball will have, in order
    ///     - direction: Animation direction of balls
    ///     - duration: Total animation duration
    public struct Properties {
        let numberOfBalls: Int
        let radius: CGFloat
        let colors: [UIColor]
        let direction: Direction
        let duration: TimeInterval
        
        public init(numberOfBalls: Int, radius: CGFloat, colors: [UIColor], direction: Direction, duration: TimeInterval) {
            self.numberOfBalls = numberOfBalls
            self.radius = radius
            self.colors = colors
            self.direction = direction
            self.duration = duration
        }
    }
    
    private struct Style {
        let minimumInterBallsSpacing: CGFloat = 8
        let jumpDistance: CGFloat = 20
        let animationDelay: TimeInterval = 0.12
    }
    
    // MARK: - Lazy Vars
    private lazy var ballsLayer: [CAShapeLayer] = {
        return createBalls()
    }()
    
    private let style: Style = .init()
    private let properties: Properties
    
    typealias AnimationProperties = (keyPath: String, finalValue: CGFloat)
    
    public init(properties: Properties) {
        self.properties = properties
        super.init(frame: .init())
        performInitialSetup()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        guard didLayoutLoader else {
            setupLoader()
            return
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Requirements Setup
private extension BouncyBallsLoader {
    
    func createBalls() -> [CAShapeLayer] {
        guard willNotRuinAeshetics else { preconditionFailure("Try setting smaller ball radius or a larger bounding width for loader. Current specifications will make the balls overlap") }
        let ballBoundingBoxWidth: CGFloat = bounds.width / CGFloat(properties.numberOfBalls)
        return (0..<properties.numberOfBalls).enumerated().map { (index, _) in
            let layer: CAShapeLayer = .init()
            let ballCenter: CGPoint = .init(
                x: getCenterXForBall(at: index, with: ballBoundingBoxWidth),
                y: bounds.height / 2
            )
            layer.path = UIBezierPath(
                arcCenter: ballCenter,
                radius: properties.radius,
                startAngle: 0,
                endAngle: 2 * .pi,
                clockwise: true
            ).cgPath
            let ballColor: UIColor = index > properties.colors.count - 1 ? .systemGray : properties.colors[index]
            layer.fillColor = ballColor.cgColor
            return layer
        }
    }
    
}

// MARK: - Private Helpers
private extension BouncyBallsLoader {
    
    func performInitialSetup() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
    }
 
    func getCenterXForBall(at index: Int, with boundingWidth: CGFloat) -> CGFloat {
        return bounds.minX + CGFloat(2 * index + 1) * boundingWidth / 2
    }
    
    var didLayoutLoader: Bool {
        return subviews.last?.layer is CAShapeLayer
    }
    
    var willNotRuinAeshetics: Bool {
        return bounds.width >= 2 * CGFloat(properties.numberOfBalls) * properties.radius + CGFloat(properties.numberOfBalls - 1) * style.minimumInterBallsSpacing
    }
    
    func setupLoader() {
        ballsLayer.forEach {
            layer.addSublayer($0)
        }
        startAnimating()
    }
    
}

// MARK: - Animation
private extension BouncyBallsLoader {
    
    func startAnimating() {
        let animation: AnimationProperties = animationProperties
        let bounce: CABasicAnimation = .init(keyPath: animation.keyPath)
        bounce.toValue = animation.finalValue
        bounce.duration = properties.duration
        bounce.repeatCount = .infinity
        bounce.timingFunction = .init(name: .easeOut)
        bounce.autoreverses = true
        ballsLayer.enumerated().forEach { (index, layer) in
            bounce.beginTime = CACurrentMediaTime() + TimeInterval(index) * style.animationDelay
            layer.add(bounce, forKey: nil)
        }
    }
    
    var animationProperties: AnimationProperties {
        let keyPath: String
        let finalValue: CGFloat
        switch properties.direction {
        case .up:
            keyPath = "transform.translation.y"
            finalValue = -style.jumpDistance
        case .down:
            keyPath = "transform.translation.y"
            finalValue = style.jumpDistance
        case .left:
            keyPath = "transform.translation.x"
            finalValue = -style.jumpDistance
        case .right:
            keyPath = "transform.translation.x"
            finalValue = style.jumpDistance
        }
        return (keyPath, finalValue)
    }
    
}

// MARK: - Public APIs
public extension BouncyBallsLoader {
    
    var optimalSize: CGSize {
        let optimalWidth: CGFloat = 2 * properties.radius * CGFloat(properties.numberOfBalls) + CGFloat(properties.numberOfBalls - 1) * style.minimumInterBallsSpacing
        let optimalHeight: CGFloat = 2 * properties.radius
        return .init(
            width: optimalWidth,
            height: optimalHeight
        )
    }
   
    func stopLoading() {
        removeFromSuperview()
    }
    
}
