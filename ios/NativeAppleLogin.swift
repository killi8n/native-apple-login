import AuthenticationServices

struct CredentialStateChangedEventProperties {
    let authorized = "authorized"
    let revoked = "revoked"
    let notfound = "notfound"
    let transferred = "transferred"
    let error = "error"
}

@available(iOS 13.0, *)
@objc(NaitveAppleLogin)
class NaitveAppleLogin: RCTEventEmitter, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    var appleIdProvider: ASAuthorizationAppleIDProvider = ASAuthorizationAppleIDProvider()
    var resolver: RCTPromiseResolveBlock?
    var rejecter: RCTPromiseRejectBlock?
    let credentialStateChangedEvent: String = "credentialStateChanged"
    
    override func constantsToExport() -> [AnyHashable : Any]! {
        return [
            "authorized": CredentialStateChangedEventProperties().authorized,
            "revoked": CredentialStateChangedEventProperties().revoked,
            "notfound": CredentialStateChangedEventProperties().notfound,
            "error": CredentialStateChangedEventProperties().error,
        ]
    }
    
    override func supportedEvents() -> [String]! {
        return [self.credentialStateChangedEvent]
    }
    
    override class func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    @objc
    func login(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        self.resolver = resolve
        self.rejecter = reject
        //      let applePasswordProvider = ASAuthorizationPasswordProvider()
        //      let passwordRequest = applePasswordProvider.createRequest()
        let idRequest = self.appleIdProvider.createRequest()
        idRequest.requestedScopes = [.email, .fullName]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [idRequest])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @objc
    func getCredentialState(_ userId: String) -> Void {
        self.appleIdProvider.getCredentialState(forUserID: userId) { (state: ASAuthorizationAppleIDProvider.CredentialState, error: Error?) in
            if let error = error {
                self.sendEvent(withName: self.credentialStateChangedEvent, body: ["state": CredentialStateChangedEventProperties().error, "error": error.localizedDescription])
                return
            }
            
            switch state {
                case .authorized:
                    self.sendEvent(withName: self.credentialStateChangedEvent, body: ["state": CredentialStateChangedEventProperties().authorized])
                    break
                case .notFound:
                    self.sendEvent(withName: self.credentialStateChangedEvent, body: ["state": CredentialStateChangedEventProperties().notfound])
                    break
                case .revoked:
                    self.sendEvent(withName: self.credentialStateChangedEvent, body: ["state": CredentialStateChangedEventProperties().revoked])
                    break
                case .transferred:
                    self.sendEvent(withName: self.credentialStateChangedEvent, body: ["state": CredentialStateChangedEventProperties().transferred])
                    break
                default:
                    break
            }
        }
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.keyWindow ?? UIWindow()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let idCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        var authorizedInfos: [String: Any] = [:]
        if let authorizationCode = idCredential.authorizationCode {
            authorizedInfos["authorizationCode"] = String(decoding: authorizationCode, as: UTF8.self)
        }
        let authorizedScopes = idCredential.authorizedScopes
        authorizedInfos["authorizedScopes"] = authorizedScopes
        if let email = idCredential.email {
            authorizedInfos["email"] = email
        }
        if let fullName = idCredential.fullName {
            authorizedInfos["fullName"] = fullName
        }
        if let identityToken = idCredential.identityToken {
            authorizedInfos["identityToken"] = String(decoding: identityToken, as: UTF8.self)
        }
        let realUserStatus = idCredential.realUserStatus
        authorizedInfos["realUserStatus"] = realUserStatus
        if let state = idCredential.state {
            authorizedInfos["state"] = state
        }
        let user = idCredential.user
        authorizedInfos["user"] = user
        
        guard let resolve = self.resolver else { return }
        resolve(authorizedInfos)
        
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        guard let reject = self.rejecter else { return }
        reject("APPLE LOGIN ERROR", error.localizedDescription, error)
    }
}
