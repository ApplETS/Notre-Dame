//
//  StudentInfo.swift
//  ETSMobile WidgetExtension
//
//  Created by Jonathan Duval-Venne on 2022-11-07.
//

import Foundation
import SwiftyXMLParser

public let studentInfoPath = ["soap:Envelope", "soap:Body", "infoEtudiantResponse", "infoEtudiantResult"]
public let studentInfoErrorPath = ["soap:Envelope", "soap:Body", "infoEtudiantResponse", "infoEtudiantResult", "erreur"]

public class ProfileStudent {
    
    /// First name of the student
    let firstName: String?
    
    // Last name of the student
    let lastName: String?
    
    /// Permanent code of the student (XXXX00000000)
    let codePerm: String?
    
    /// Balance of the student
    let balance: String?
    
    public init(from xml:XML.Accessor) {
        self.firstName = xml.prenom.text
        self.lastName = xml.nom.text
        self.codePerm = xml.codePerm.text
        self.balance = xml.soldeTotal.text
    }
}
