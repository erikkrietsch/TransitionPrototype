import UIKit


class PacManView: UIView {
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        let pacMan = PacManLayer()
        layer.addSublayer(pacMan)
        pacMan.frame = layer.frame
    }
}

class PacManLayer: CAShapeLayer {
    override init() {
        super.init()
        fillColor = UIColor.yellow.cgColor
        setNeedsDisplay()
    }

    required init?(coder: NSCoder) {
        fatalError("wtf why is this even required")
    }

    override var path: CGPath? {
        get {
            let center = CGPoint(x: bounds.midX, y: bounds.midY)
            let radius: CGFloat = min(center.x, center.y)

            let start: CGFloat = .pi / 6
            let end:   CGFloat = 11 * .pi / 6

            let path = CGMutablePath()
            path.move(to: center)

            path.addLine(to: CGPoint(x: center.x + radius * cos(start),
                                    y: center.y + radius * sin(start)))

            path.addArc(center: center, radius: radius,
                       startAngle: start, endAngle: end,
                       clockwise: start > end)

            path.closeSubpath()
            return path
        }
        set {

        }
    }
}


class PacManTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        PacManTransitionAnimator()
    }
}

class PacManTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        1
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let stripCount = 12
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to)
            else {
                return
        }
        let container = transitionContext.containerView
        container.addSubview(toVC.view)

        var horizontalStrips: [UIView] = []
        var pacMen: [UIView] = []
        let stripSize = fromVC.view.frame.height / CGFloat(stripCount)
        for i in 0..<stripCount {
            let rect = CGRect(x: 0, y: CGFloat(i) * stripSize, width: fromVC.view.frame.width, height: stripSize)
            if let strip = fromVC.view.resizableSnapshotView(from: rect, afterScreenUpdates: false, withCapInsets: .zero) {
                horizontalStrips.append(strip)
                container.addSubview(strip)
                strip.frame = strip.frame.offsetBy(dx: 0, dy: CGFloat(i) * stripSize)
                strip.layer.masksToBounds = true

                let pacMan = PacManView(frame: CGRect(x: 0, y: 0, width: stripSize * 1.1, height: stripSize * 1.1))
                let pacManXOffset = (i % 2 == 0 ? -pacMan.frame.width / 2 : fromVC.view.frame.width - pacMan.frame.width / 2)
                let pacManOrigin = CGPoint(x: pacManXOffset, y: strip.frame.origin.y)
                pacMan.frame = CGRect(origin: pacManOrigin, size: pacMan.frame.size)
                pacMan.layer.setAffineTransform(CGAffineTransform(scaleX: i % 2 == 0 ? 1 : -1, y: 1))
                pacMen.append(pacMan)
            }
        }
        pacMen.forEach(container.addSubview)

        let duration = transitionDuration(using: transitionContext)
        let black = UIColor.black.cgColor
        let clear = UIColor.clear.cgColor

        for (i, strip) in horizontalStrips.enumerated() {
            let even = i % 2 == 0

            let maskLayer = CAGradientLayer()
            maskLayer.frame = strip.bounds
            maskLayer.colors = even ? [clear, black] : [black, clear]
            maskLayer.startPoint = CGPoint(x: 0.95, y: 0.5)
            maskLayer.endPoint = CGPoint(x: 1, y: 0.5)

            let finishEndPoint = CGPoint(x: 0.05, y: 0.5)
            let finishStartPoint = CGPoint(x: 0.0, y: 0.5)

            strip.layer.mask = maskLayer

            let startPointAnimation = CABasicAnimation(keyPath: "startPoint")
            startPointAnimation.fromValue = even ? finishStartPoint : maskLayer.startPoint
            startPointAnimation.toValue = even ? maskLayer.startPoint : finishStartPoint
            startPointAnimation.duration = duration

            let endPointAnimation = CABasicAnimation(keyPath: "endPoint")
            endPointAnimation.fromValue = even ? finishEndPoint : maskLayer.endPoint
            endPointAnimation.toValue = even ? maskLayer.endPoint : finishEndPoint
            endPointAnimation.duration = duration

            maskLayer.add(startPointAnimation, forKey: nil)
            maskLayer.add(endPointAnimation, forKey: nil)
        }

        UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
            for (i, strip) in horizontalStrips.enumerated() {
                let pacMan = pacMen[i]
                let multiplier: CGFloat = i % 2 == 0 ? 1 : -1
                let offset = (strip.frame.width + (pacMan.frame.width / 2)) * multiplier

                pacMan.frame = pacMan.frame.offsetBy(dx: offset, dy: 0)
            }
        }) { completed in
            horizontalStrips.forEach({ $0.removeFromSuperview() })
            pacMen.forEach({ $0.removeFromSuperview() })
            transitionContext.completeTransition(completed)
        }
    }


}
