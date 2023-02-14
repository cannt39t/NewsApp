//
//  DescriptionViewController.swift
//  NewsApp
//
//  Created by Илья Казначеев on 04.02.2023.
//

import UIKit
import WebKit

class DescriptionViewController: UIViewController {
    
    private var scrollView = UIScrollView()
    let contentView = UIView()
    
    private var imageView = UIImageView()
    private var titleLabel = UILabel()
    private var descriptionLabel = UILabel()
    private var dateLabel = UILabel()
    private var sourceLabel = UILabel()
    private var linkButton = UIButton(type: .system)
        
    public var article: Article?
    private var dataTask: URLSessionDataTask?
    private var aspectRatioConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        setupLayout()
    }
    
    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        
        let stackDateAndAuthor = UIStackView(arrangedSubviews: [dateLabel, sourceLabel])
        stackDateAndAuthor.distribution = .fill
        stackDateAndAuthor.spacing = 150
        stackDateAndAuthor.axis = .horizontal
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, stackDateAndAuthor, linkButton])
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 10
        
        contentView.addSubview(stack)
        contentView.addSubview(imageView)

        NSLayoutConstraint.activate([
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: stack.topAnchor, constant: -5),
            
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
    }
    
    public func setArticale() {
        if let urlToImage = article?.urlToImage {
            if let url = URL(string: urlToImage) {
                loadImage(url: url)
            }
        }
        
        titleLabel.font = UIFont(name: "TimesNewRomanPS-BoldMT", size: 24)!
        titleLabel.textAlignment = .left
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.text = article?.title
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        
        descriptionLabel.text = article?.description ?? "No description"
        descriptionLabel.font = UIFont(name: "TimesNewRomanPSMT", size: 19)!
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .justified
        
        let index = (article?.publishedAt.firstIndex(of: "T") ?? article?.publishedAt.endIndex)!
        let substring = String((article?.publishedAt[..<index])!)
        dateLabel.text = substring
        
        sourceLabel.text = article?.author ?? "Unknown"
        
        linkButton.setTitle(article?.url, for: .normal)
        linkButton.setTitleColor(.blue, for: .normal)
        linkButton.titleLabel?.numberOfLines = 1
        linkButton.addTarget(self, action: #selector(tappedOnFullVersion), for: .touchUpInside)
    }
    
    @objc func tappedOnFullVersion() {
        let fullVersionVC = FullVersionViewController()
        fullVersionVC.link = article?.url ?? "https://www.google.com/"
        navigationController?.pushViewController(fullVersionVC, animated: true)
    }
    
    private func loadImage(url: URL) {
        imageView.image = nil
        dataTask?.cancel()
        let urlRequest = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData
        )
        dataTask = URLSession.shared
            .dataTask(with: urlRequest) { [imageView] data, _, _ in
                guard let data else {
                    return
                }

                let image = UIImage(data: data)
                DispatchQueue.main.async { [imageView] in
                    guard let image else { return }
                    self.setupRatio(for: image)
                    imageView.image = image
                }
            }
        dataTask?.resume()
    }

    private func setupRatio(for image: UIImage) {
       aspectRatioConstraint?.isActive = false
       aspectRatioConstraint = imageView.widthAnchor.constraint(
           equalTo: imageView.heightAnchor,
           multiplier: image.size.width / image.size.height
       )
       aspectRatioConstraint?.isActive = true
    }

}
