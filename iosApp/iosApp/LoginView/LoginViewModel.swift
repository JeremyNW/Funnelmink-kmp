//
//  LoginViewModel.swift
//  funnelmink
//
//  Created by Jared Warren on 11/28/23.
//  Copyright © 2023 FunnelMink, LLC. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import AuthenticationServices
import GoogleSignIn
import Shared

class LoginViewModel: ViewModel {
    @Published var state = State()

    struct State: Hashable {}

    @MainActor
    func signInWithGoogle() async {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        do {
            let vc = UIApplication
                    .shared
                    .connectedScenes
                    .compactMap {
                        ($0 as? UIWindowScene)?.keyWindow
                    }
                    .last!
                    .rootViewController!
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: vc)
            let user = result.user
            guard let idToken = user.idToken?.tokenString
            else {
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            let authResult = try await Auth.auth().signIn(with: credential)
            Task {
                do {
                    let token = try await authResult.user.getIDToken()
                    try Networking.api.refreshToken(token: token)
                    let body = CreateUserRequest(id: authResult.user.uid, email: authResult.user.email ?? "", username: authResult.user.displayName ?? "")
                    let user = try await Networking.api.createUser(body: body)
                    AppState.shared.signIn(user: user, token: token)
                } catch {
                    Toast.warn(error)
                }
            }
        } catch {
            Toast.warn(error)
        }
    }
}
