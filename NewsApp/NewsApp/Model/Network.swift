//
//  Network.swift
//  NewsApp
//
//  Created by Илья Казначеев on 03.02.2023.
//

import Foundation

// MARK: - Response
struct Response: Codable {
    let status: String
    let totalResults: Int?
    let articles: [Article]
}

// MARK: - Article
struct Article: Codable {
    let source: Source
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
}

// MARK: - Source
struct Source: Codable {
    let id: String?
    let name: String
}
