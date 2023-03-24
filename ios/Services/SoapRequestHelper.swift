//
//  SoapRequestHelper.swift
//  ETSMobile WidgetExtension
//
//  Created by Jonathan Duval-Venne on 2022-09-19.
//

import Foundation

struct SoapRequestHelper {
    static func getParameters(for requestAction: String, user: MonETSUser, extraParams: [String: String]) -> String {
        let parameters = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n  <soap:Body>\n    <\(requestAction) xmlns=\"http://etsmtl.ca/\">\n      <codeAccesUniversel>\(user.username)</codeAccesUniversel>\n      <motPasse>\(user.password)</motPasse>\n  \(buildXmlForExtraParams(extraParams))  </\(requestAction)>\n  </soap:Body>\n</soap:Envelope>"
        return parameters
    }
    
    private static func buildXmlForExtraParams(_ extraParams: [String: String]) -> String {
        var paramsAsXml = ""
        for (nodeName, nodeValue) in extraParams {
            paramsAsXml += "<\(nodeName)>\(nodeValue)</\(nodeName)>\n"
        }
        return paramsAsXml
    }
}
