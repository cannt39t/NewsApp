//
//  LoadArticlesProtocol.swift
//  NewsApp
//
//  Created by Илья Казначеев on 04.02.2023.
//

import Foundation

protocol LoadArticlesProtocol {
    
    func getArticles(page: Int, completion: @escaping ([Article], Error?) -> Void)
    
}
