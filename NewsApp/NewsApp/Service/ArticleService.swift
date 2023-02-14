//
//  ArticleService.swift
//  NewsApp
//
//  Created by Илья Казначеев on 04.02.2023.
//

import Foundation

class ArticleService: LoadArticlesProtocol {
    func getArticles(page: Int, completion: @escaping ([Article], Error?) -> Void) {
        // Check if articles already exist in UserDefaults
        if let data = UserDefaults.standard.data(forKey: "articles") {
            do {
                let articles = try JSONDecoder().decode([Article].self, from: data)
                if 20 * page <= articles.count {
                    let startIndex = (page - 1) * 20
                    let articlesToReturn = Array(articles[startIndex..<min(startIndex + 20, articles.count)])
                    completion(articlesToReturn, nil)
                    return
                }
            } catch {
                print("Error decoding articles array: \(error)")
            }
        }

        // If articles not found in UserDefaults, load from API
        let apiClient = APIClient()
        apiClient.getArticles(page: page) { articles, error in
            var articlesArray = [Article]()
            if let data = UserDefaults.standard.data(forKey: "articles"),
                let savedArticles = try? JSONDecoder().decode([Article].self, from: data) {
                articlesArray = savedArticles
            }
            articlesArray.append(contentsOf: articles)
            
            var articalesNew = [Article]()
            var titles = Set<String>()

            for article in articlesArray {
                if !titles.contains(article.title) {
                    articalesNew.append(article)
                    titles.insert(article.title)
                }
            }
            
            do {
                let data = try JSONEncoder().encode(articalesNew)
                UserDefaults.standard.set(data, forKey: "articles")
            } catch {
                print("Error encoding articles array: \(error)")
            }
            completion(articalesNew, error)
        }
    }
}

class APIClient: LoadArticlesProtocol {
    func getArticles(page: Int, completion: @escaping ([Article], Error?) -> Void) {
        var articles: [Article] = []
        let urlString = "https://newsapi.org/v2/everything?q=tesla&from=\(FROM)&page=\(page)&pageSize=\(PAGE_SIZE)&sortBy=publishedAt&apiKey=\(API_KEY)"
        let url = URL(string: urlString)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(articles, error)
                return
            }
            guard let data = data else { return }

            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(Response.self, from: data)
                articles = response.articles
                completion(articles, nil)
            } catch let error {
                print(error)
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
}
