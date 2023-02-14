//
//  NewsCollectionViewCell.swift
//  NewsApp
//
//  Created by Илья Казначеев on 03.02.2023.
//

import UIKit

public class NewsCollectionViewCell: UICollectionViewCell {

    private var dataTask: URLSessionDataTask?
    public static let indertifier = "NEWS_CELL"
    private var aspectRatioConstraint: NSLayoutConstraint?
    private let customFont = UIFont(name: "PoynterText-RomanFour", size: 20)

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }

    private var newsImageView: UIImageView = .init()
    private var titleLabel: UILabel = .init()
    private var viewsCountLabel: UILabel = .init()
    var shareButton = URLButton(type: .system)

    func setArticle(article: Article) {
        newsImageView.image = UIImage(systemName: "photo")?.withTintColor(.systemGray, renderingMode: .alwaysOriginal)
        if let urlToImage = article.urlToImage {
            if let url = URL(string: urlToImage) {
                loadImage(url: url)
            }
        }
        titleLabel.font = UIFont(name: "TimesNewRomanPSMT", size: 20)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textAlignment = .justified
        titleLabel.text = article.title
        titleLabel.numberOfLines = 3
        
        viewsCountLabel.text = "Views: \(UserDefaults.standard.integer(forKey: article.title))"
        viewsCountLabel.font = UIFont(name: "TimesNewRomanPSMT", size: 16)
        
        shareButton.urlString = article.url
    }
    
    private func setup() {
        setupButton()
        
        let stackViewViewsAndShareButton = UIStackView(arrangedSubviews: [viewsCountLabel, shareButton])
        stackViewViewsAndShareButton.distribution = .fill
        stackViewViewsAndShareButton.spacing = 8
        stackViewViewsAndShareButton.axis = .horizontal
        
        let textStackAndButtonShare = UIStackView(arrangedSubviews: [titleLabel, stackViewViewsAndShareButton])
        textStackAndButtonShare.distribution = .fill
        textStackAndButtonShare.spacing = 8
        textStackAndButtonShare.axis = .vertical
        
        let stackView = UIStackView(arrangedSubviews: [textStackAndButtonShare])
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        newsImageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        contentView.addSubview(newsImageView)
        
        NSLayoutConstraint.activate([
            newsImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            newsImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            newsImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            newsImageView.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -5),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
    }
    
    private func setupButton() {
        shareButton.setImage(UIImage(systemName: "arrowshape.turn.up.right"), for: .normal)
        shareButton.tintColor = .systemGray
    }
        
    private func loadImage(url: URL) {
        newsImageView.image = nil
        newsImageView.contentMode = .scaleToFill
        dataTask?.cancel()
        let urlRequest = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData
        )
        dataTask = URLSession.shared
            .dataTask(with: urlRequest) { [newsImageView] data, _, _ in
                guard let data else {
                    let image = UIImage(systemName: "photo")?.withTintColor(.systemGray, renderingMode: .alwaysOriginal)
                    DispatchQueue.main.async { [newsImageView] in
                        guard let image else { return }

                        newsImageView.image = image
                    }
                    return
                }

                let image = UIImage(data: data)
                DispatchQueue.main.async { [newsImageView] in
                    guard let image else { return }

                    newsImageView.image = image
                }
            }
        dataTask?.resume()
    }
    
}
