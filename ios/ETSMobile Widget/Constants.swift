//
//  Constants.swift
//  ETSMobile WidgetExtension
//
//  Created by Club Applets on 2022-02-03.
//

public let widgetGroupId = "group.ca.etsmtl.applets.ETSMobile"
public let keychainServiceAttr = "flutter_keychain"
public let usernameKey = "WidgetSecureUser"
public let passwordKey = "WidgetSecurePass"

// Urls related to MonETS
public let monEtsAPI = "https://portail.etsmtl.ca/api/"
public let authenticationMonETS = "${monEtsAPI}authentification"

/// Urls related to SignetsMobile API
/// For more information about the operations supported see:
/// https://signets-ens.etsmtl.ca/Secure/WebServices/SignetsMobile.asmx
public let signetsAPI =
    "https://signets-ens.etsmtl.ca/Secure/WebServices/SignetsMobile.asmx"

// MonETS Consants
public let signetsOperationBase = "http://etsmtl.ca/"
public let donneesAuthentificationValides =
    "donneesAuthentificationValides"
public let infoStudentOperation = "infoEtudiant"
public let listProgramsOperation = "listeProgrammes"
public let listClassScheduleOperation = "lireHoraireDesSeances"
public let listSessionsOperation = "listeSessions"
public let listCourseOperation = "listeCours"
public let listEvaluationsOperation = "listeElementsEvaluation"
public let listeHoraireEtProf = "listeHoraireEtProf"
public let readCourseReviewOperation = "lireEvaluationCours"
