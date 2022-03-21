//
//  NetworkAdapterUtility.swift
//  CertificatePinning
//
//  Created by Kant, Lalit on 21/03/22.
//

import Foundation
import Alamofire

/// Struct created to build Evaluator for SSL Pinning
internal struct NetworkAdapterUtility {
    
    /// Method to build Evaluator for the SSL Pinning
    /// - Parameters: host names as array to return Evaluator format accepted by Alamofire
    /// - Returns: array of Evaluator
    func buildEvaluators(evaluator_hosts: [String]) -> [String: ServerTrustEvaluating] {
        var evaluators = [String: ServerTrustEvaluating]()
        for host in evaluator_hosts {
            evaluators[host] = PublicKeysTrustEvaluator()
        }
        return evaluators
    }
}
