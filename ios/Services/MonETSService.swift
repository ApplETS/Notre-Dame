//
//  MonETSSerivce.swift
//  ETSMobile WidgetExtension
//
//  Created by Jonathan Duval-Venne on 2022-09-19.
//

import Foundation
//import SwiftyXMLParser

class MonETSClient {
    enum MonETSError: Error {
        case malformedJson
    }

    static let shared = MonETSClient()

    private let baseURL = URL(string: monEtsAPI)!
    private let session = URLSession(configuration: URLSessionConfiguration.default)

    private init() { }

    func authenticate(user: MonETSUser) {
        let postData = try! JSONEncoder().encode(user)

        var request = URLRequest(url: baseURL.appendingPathComponent("authentification"), timeoutInterval: 60.0)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postData

        URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            return
          }
          print(String(data: data, encoding: .utf8)!)
        }.resume()
    }
}
