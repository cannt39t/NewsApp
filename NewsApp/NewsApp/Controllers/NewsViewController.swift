//
//  NewsViewController.swift
//  NewsApp
//
//  Created by Илья Казначеев on 03.02.2023.
//

import UIKit

class NewsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var collection: UICollectionView?
    var articles: [Article] = []
    var page = 1
    var isLoadingData = false
    let articleService = ArticleService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "News"
        
        loadArticles()
        setupCollectionView()
        setupRefreshController()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: view.frame.width / 1, height: view.frame.height / 2.8)
        collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection?.dataSource = self
        collection?.delegate = self
        collection?.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.968627451, alpha: 1)
        collection?.register(NewsCollectionViewCell.self, forCellWithReuseIdentifier: NewsCollectionViewCell.indertifier)
        view.addSubview(collection!)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collection?.frame = view.bounds
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articles.count
    }
    
    func setupRefreshController() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collection?.refreshControl = refreshControl
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        page = 1
        UserDefaults.standard.removeObject(forKey: "articles")
        loadArticles()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            refreshControl.endRefreshing()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: NewsCollectionViewCell.indertifier, for: indexPath) as? NewsCollectionViewCell)!
        let item = articles[indexPath.item]
        cell.setArticle(article: item)
        cell.backgroundColor = .white
        cell.shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        return cell
    }
    
    private func loadArticles() {
        isLoadingData = true
        articleService.getArticles(page: page) { articles, error in
            if let error = error {
                if error._code == -1009 {
                    DispatchQueue.main.async {
                        self.showNoInternetConnectionAlert()
                    }
                } else {
                    print(error.localizedDescription)
                }
                return
            }
            self.articles = []
            self.articles.append(contentsOf: articles)
            DispatchQueue.main.async {
                self.collection!.reloadData()
                self.isLoadingData = false
            }
        }
    }
    
    @objc func shareButtonTapped(_ sender: URLButton) {
        let text = "Check the news"
        let link = URL(string: sender.urlString!)!
        let items = [text, link] as [Any]
        
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }
    
    private func showNoInternetConnectionAlert() {
        let alert = UIAlertController(title: "No Internet Connection", message: "Please check your internet connection and try again.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = articles[indexPath.item]
        let descriptionVC = DescriptionViewController()
        descriptionVC.article = item
        descriptionVC.setArticale()
        navigationController?.pushViewController(descriptionVC, animated: true)
        
        // Увелечение счетчика просмотров
        
        let key = item.title
        var value = UserDefaults.standard.integer(forKey: key)
        value += 1
        UserDefaults.standard.set(value, forKey: key)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.height && !isLoadingData {
            page += 1
            loadArticles()
        }
    }
}
