//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Irina Muravyeva on 13.05.2026.
//

import UIKit

final class OnboardingViewController: UIPageViewController {
    lazy var pages: [UIViewController] = {
        let first = OnboardingTemplateVC()
        first.setImage(.onboarding1)
        first.setTitle("Отслеживайте только то, что хотите")
        first.onNextButtonTapped = { [weak self] in
            self?.finishOnboarding()
        }
        
        let second = OnboardingTemplateVC()
        second.setImage(.onboarding2)
        second.setTitle("Даже если это не литры воды и йога")
        second.onNextButtonTapped = { [weak self] in
            self?.finishOnboarding()
        }
        
        return [first, second]
    }()
    
    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = .blackDay
        pageControl.pageIndicatorTintColor = .blackDay.withAlphaComponent(0.3)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    // MARK: - Initializes
    init() {
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // MARK: - Private methods
    private func finishOnboarding() {
        guard let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate else { return }
        
        UserDefaults.standard.set(true, forKey: Constants.hasSeenOnboardingKey)
        sceneDelegate.onboardingDidFinished()
    }
}

// MARK: - UIPageViewControllerDataSource, UIPageViewControllerDelegate
extension OnboardingViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard
            let viewControllerIndex = pages.firstIndex(of: viewController),
            viewControllerIndex - 1 >= 0
        else {
            return nil
        }
        
        return pages[viewControllerIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else {
            return nil
        }
        
        return pages[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}
