//
//  ImageViewerVC.swift
//  PPOcards
//
//  Created by ser.nikolaev on 30.04.2023.
//

import UIKit

class ImageViewerVC: UIViewController {
    let scrollView = UIScrollView()
    let image: UIImage?
    
    convenience init() {
        self.init(image: nil)
    }
    
    init(image: UIImage?) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var magicViev = MagicView(with: image)

    override func viewDidLoad() {
        super.viewDidLoad()

        
        setup()
    }

    private func setup() {
        view.addSubview(magicViev)
        view.backgroundColor = .systemBackground
        
        magicViev.translatesAutoresizingMaskIntoConstraints = false
        magicViev.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        magicViev.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        magicViev.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        magicViev.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}

extension ImageViewerVC: UIScrollViewDelegate {
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return magicViev
  }
}

final class MagicView: UIView {
    private var imageView: UIImageView
    private let imageViewContainer = UIView()
    
    convenience init() {
        self.init(with: nil)
    }
    
    init(with image: UIImage?) {
        imageView = UIImageView(image: image)
        super.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        
        addSubview(imageViewContainer)
        imageViewContainer.addSubview(imageView)
        
        layout()
        addRecognizers()
    }
    
    private func addRecognizers() {
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        let rotationRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation))
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapRecognizer.numberOfTapsRequired = 2
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressRecognizer.minimumPressDuration = 1
        
            
        [pinchRecognizer, rotationRecognizer, panRecognizer, longPressRecognizer].forEach {
            imageView.addGestureRecognizer($0)
            $0.delegate = self
        }
        
        imageViewContainer.addGestureRecognizer(doubleTapRecognizer)
        doubleTapRecognizer.delegate = self
    }
    
    private func layout() {
        imageViewContainer.translatesAutoresizingMaskIntoConstraints = false
        imageViewContainer.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        imageViewContainer.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        imageViewContainer.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageViewContainer.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leftAnchor.constraint(equalTo: imageViewContainer.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: imageViewContainer.rightAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: imageViewContainer.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: imageViewContainer.bottomAnchor).isActive = true
    }
    
    @objc
    private func handlePinch(gestureRecognizer: UIPinchGestureRecognizer) {
        guard gestureRecognizer.state == .began || gestureRecognizer.state == .changed else {
            return
        }
        
        gestureRecognizer.view?.transform = gestureRecognizer.view?.transform.scaledBy(x: gestureRecognizer.scale, y: gestureRecognizer.scale) ?? .identity
        gestureRecognizer.scale = 1
    }
    
    @objc
    private func handleRotation(gestureRecognizer: UIRotationGestureRecognizer) {
        guard gestureRecognizer.state == .began || gestureRecognizer.state == .changed else {
            return
        }
        
        gestureRecognizer.view?.transform = gestureRecognizer.view?.transform.rotated(by: gestureRecognizer.rotation) ?? .identity
        gestureRecognizer.rotation = 0
    }
    
    @objc
    private func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view?.superview)
        gestureRecognizer.view?.center.x += translation.x
        gestureRecognizer.view?.center.y += translation.y
        gestureRecognizer.setTranslation(.zero, in: gestureRecognizer.view)
    }
    
    @objc
    private func handleDoubleTap(gestureRecognizer: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.5) {
            self.imageView.transform = .identity
            self.imageView.frame = self.imageViewContainer.bounds
        }
    }
    
    @objc
    private func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began || gestureRecognizer.state == .changed else {
            return
        }
        
        if self.imageView.contentMode == .scaleAspectFit {
            self.imageView.contentMode = .scaleAspectFill
        } else if self.imageView.contentMode == .scaleAspectFill {
            self.imageView.contentMode = .scaleAspectFit
        }
    }
}

extension MagicView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
