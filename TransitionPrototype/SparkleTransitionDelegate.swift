import UIKit

class SparkleTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        SparkleTransitionAnimator()
    }
}

class SparkleTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let kAnimationLayerKey = "com.whatever.testing.transition"
    var sparkleView: UIView!

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to)
            else {
                return
        }

        let duration = transitionDuration(using: transitionContext)
        let container = transitionContext.containerView
        container.addSubview(toVC.view)

        guard let snapshot = fromVC.view.resizableSnapshotView(from: fromVC.view.frame, afterScreenUpdates: true, withCapInsets: .zero) else { return }

        container.addSubview(snapshot)
        sparkleView = UIView(frame: container.bounds)
        sparkleView.backgroundColor = .clear
        container.addSubview(sparkleView)

        let sparkleEmitter = CAEmitterLayer()
        sparkleEmitter.frame = snapshot.bounds
        sparkleEmitter.emitterPosition = CGPoint(x: sparkleEmitter.frame.midX, y: sparkleEmitter.frame.minY)
        sparkleEmitter.emitterCells = emitterCells()
        sparkleEmitter.emitterShape = CAEmitterLayerEmitterShape.line
        sparkleEmitter.emitterSize = CGSize(width: snapshot.bounds.width, height: 1)
        sparkleEmitter.birthRate = 1

        let clear = UIColor.clear.cgColor
        let black = UIColor.black.cgColor

        let maskLayer = CAGradientLayer()
        maskLayer.frame = snapshot.bounds
        maskLayer.colors = [black, clear]
        maskLayer.startPoint = CGPoint(x: 0.5, y: 0.97)
        maskLayer.endPoint = CGPoint(x: 0.5, y: 1)

        let finishStartPoint = CGPoint(x: 0.5, y: 0)
        let finishEndPoint = CGPoint(x: 0.5, y: 0.03)

        let startSparklePoint = CGPoint(x: sparkleEmitter.frame.midX, y: sparkleEmitter.frame.maxY - 10)
        let finishSparklePoint = CGPoint(x: sparkleEmitter.frame.midX, y: sparkleEmitter.frame.minY)

        sparkleView.layer.addSublayer(sparkleEmitter)
        snapshot.layer.mask = maskLayer

        let startPointAnimation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.startPoint))
        startPointAnimation.fromValue = maskLayer.startPoint
        startPointAnimation.toValue = finishStartPoint
        startPointAnimation.duration = duration

        let endPointAnimation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.endPoint))
        endPointAnimation.fromValue = maskLayer.endPoint
        endPointAnimation.toValue = finishEndPoint
        endPointAnimation.duration = duration

        let sparkleMoveAnimation = CABasicAnimation(keyPath: #keyPath(CAEmitterLayer.emitterPosition))
        sparkleMoveAnimation.fromValue = startSparklePoint
        sparkleMoveAnimation.toValue = finishSparklePoint
        sparkleMoveAnimation.duration = duration

        CATransaction.begin()
        CATransaction.setCompletionBlock() {
            let transition = CATransition()
            transition.delegate = self
            transition.type = .fade
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: .easeOut)
            transition.setValue(sparkleEmitter, forKey: self.kAnimationLayerKey)
            transition.isRemovedOnCompletion = false

            sparkleEmitter.add(transition, forKey: nil)
            sparkleEmitter.opacity = 0

            snapshot.removeFromSuperview()
            fromVC.view.removeFromSuperview()
            transitionContext.completeTransition(true)
        }

        sparkleEmitter.add(sparkleMoveAnimation, forKey: nil)
        maskLayer.add(startPointAnimation, forKey: nil)
        maskLayer.add(endPointAnimation, forKey: nil)
        CATransaction.commit()
    }


    func emitterCells() -> [CAEmitterCell] {
        [SparkleCell()]
    }
}

extension SparkleTransitionAnimator: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let layer = anim.value(forKey: kAnimationLayerKey) as? CALayer {
            layer.removeAllAnimations()
            layer.removeFromSuperlayer()
        }
        sparkleView.removeFromSuperview()
    }
}

private class SparkleCell: CAEmitterCell {
    required init?(coder: NSCoder) {
        fatalError()
    }

    override init() {
        super.init()
        let image = UIImage(named: "sparkle")
        contents = image?.cgImage
        isEnabled = true
        birthRate = 500
        lifetime = 0.25
        lifetimeRange = 0.5
        scale = 1
        scaleRange = 3
        spin = 1
        spinRange = 3
    }
}
