//
//  ViewController.swift
//  TransitionPrototype
//
//  Created by Erik Krietsch on 3/13/18.
//  Copyright © 2018 Totally Radical Software, Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    enum Transition: CaseIterable {
        case pacMan, sparkles, barf, heroElement, explode
    }

    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!

    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button5: UIButton!
    @IBOutlet weak var button6: UIButton!

    lazy var allButtons = [button1, button2, button3, button4, button5, button6]

    var transitionDelegate: UIViewControllerTransitioningDelegate?

    @IBAction func didTapButton(_ sender: UIButton) {
        let transition: Transition
        switch sender {
        case button1:
            transition = .pacMan
        case button2:
            transition = .sparkles
        case button3:
            transition = .barf
        case button4:
            transition = .heroElement
        case button5:
            transition = .explode
        default:
            transition = Transition.allCases.randomElement() ?? .explode
        }
        perform(transition)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        styleViews()
    }

    private func styleViews() {
        style(view: view)
        allButtons.forEach(style(button:))
    }

    private func style(button: UIButton?) {
        button?.layer.cornerRadius = 8
        button?.layer.backgroundColor = randomColor().cgColor
        button?.tintColor = .white
    }

    private func style(view: UIView) {
        view.backgroundColor = randomColor()
    }

    private func randomColor() -> UIColor {
        let colors: [UIColor] = [.systemOrange, .systemGray, .systemRed, .systemPurple, .systemGreen, .systemYellow, .systemPink, .systemTeal, .systemIndigo]

        return colors.randomElement() ?? .white
    }

    private func perform(_ transition: Transition) {
        let toVC = createViewController(for: transition)

        present(toVC, animated: true, completion: {
            self.transitionDelegate = nil
        })
    }

    private func transitionDelegate(for transition: Transition) -> UIViewControllerTransitioningDelegate {
        switch transition {
        case .pacMan:
            return PacManTransitionDelegate()
        case .sparkles:
            return SparkleTransitionDelegate()
        default:
            return SimpleTransitionDelegate()
        }

    }

    private func createViewController(for transition: Transition ) -> ViewController {
        let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(identifier: "main") as! ViewController
        vc.modalPresentationStyle = .custom
        setTransitioningDelegate(transitionDelegate(for: transition), to: vc)
        return vc
    }

    private func setTransitioningDelegate(_ transitionDelegate: UIViewControllerTransitioningDelegate, to vc: UIViewController) {
        self.transitionDelegate = transitionDelegate //hold a strong reference
        vc.transitioningDelegate = transitionDelegate
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

