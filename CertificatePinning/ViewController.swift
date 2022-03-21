//
//  ViewController.swift
//  CertificatePinning
//
//  Created by Kant, Lalit on 20/03/22.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    private var afSession: Session!
    
    override func viewDidLoad() {
        // In general Public key pinning is better as it avoid update of certficate in local
        self.certificatePinningWithAlamofirePublicKey()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
            self.certificatePinningWithPinnedCertificatesTrustEvaluator()
        }
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func certificatePinningWithAlamofirePublicKey() {
        // Build serverTrust manager for public key, Alamofire 5 +  don't support explicit public key pinning, It extract public key from certificate and compare it with api response public key
        let manager = ServerTrustManager(evaluators: NetworkAdapterUtility().buildEvaluators(evaluator_hosts: ["stackoverflow.com"]))
        afSession = Session(serverTrustManager: manager)
        certificatePinning()
    }
    
    
    func certificatePinningWithPinnedCertificatesTrustEvaluator() {
        let certificates = [
            "stackoverflow.com":
                PinnedCertificatesTrustEvaluator(certificates: [Certificates.certificate],
                                                 acceptSelfSignedCertificates: false,
                                                 performDefaultValidation: true,
                                                 validateHost: true)
        ]
        let serverTrustPolicy = ServerTrustManager(
            allHostsMustBeEvaluated: true,
            evaluators: certificates
        )
        afSession = Session(serverTrustManager: serverTrustPolicy)
        certificatePinning()
    }
    
    func certificatePinning() {
        afSession
            .request("https://stackoverflow.com/questions/34611112/certificate-pinning-in-alamofire", method: .get)
            .validate()
            .response(completionHandler: { response in
                switch response.result {
                case .success:
                    print(response.data ?? Data())
                case .failure(let error):
                    switch error {
                    case .serverTrustEvaluationFailed(let reason):
                        /* Try Removing stackoverflow.cer file from project folder compiler will execute serverTrustEvaluationFailed case
                         error: Alamofire.AFError.ServerTrustFailureReason.noPublicKeysFound
                         
                         Goto ServerTrustFailureReason class implementation you will find all SSL pinning failure cases
                         */
                        
                        // The reason here is a place where you might fine-tune your
                        // error handling and possibly deduce if it's an actualy MITM
                        // or just another error, like certificate issue.
                        //
                        // In this case, this will show `noRequiredEvaluator` if you try
                        // testing against a domain not in the evaluators list which is
                        // the closest I'm willing to setting up a MITM. In production,
                        // it will most likely be one of the other evaluation errors.
                        debugPrint(reason)
                    default:
                        debugPrint(error)
                    }
                }
            })
    }
    
}



struct Certificates {
    
    static let certificate: SecCertificate = Certificates.certificate(filename: "stackoverflow")
    
    private static func certificate(filename: String) -> SecCertificate {
        let filePath = Bundle.main.path(forResource: filename, ofType: "cer")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: filePath))
        let certificate = SecCertificateCreateWithData(nil, data as CFData)!
        return certificate
    }
}



