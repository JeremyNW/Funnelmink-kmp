//
//  Networking.swift
//  funnelmink
//
//  Created by Jared Warren on 11/27/23.
//  Copyright © 2023 FunnelMink, LLC. All rights reserved.
//

import FirebaseAuth
import Foundation
import Shared

/// The full API can be found on [GitHub](https://github.com/funnelmink/funnelmink-kmp/blob/main/shared/src/commonMain/kotlin/networking/API.kt)
class Networking {
    static let cache = Database(databaseDriverFactory: DatabaseDriver())
    static let api: API = {
        let fmapi = FunnelminkAPI(
            baseURL: Properties.baseURL,
            cache: cache
        )
        
        fmapi.onAuthFailure = { _ in
            Task { @MainActor in
                do {
                    guard let token = try await Auth.auth().currentUser?.getIDTokenResult(forcingRefresh: true).token else {
                        Toast.error("Your session has expired. Please log in again.")
                        return
                    }
                    try Networking.api.refreshToken(token: token)
                } catch {
                    Toast.error("Your session has expired. Please log in again.")
                }
            }
        }
        
        fmapi.onBadRequest = { message in
            Task { @MainActor in
                Toast.error(message)
            }
        }
        
        fmapi.onDecodingError = { message in
            Task { @MainActor in
                Toast.error(message)
            }
        }
        
        fmapi.onMissing = { message in
            Task { @MainActor in
                Toast.error(message)
            }
        }
        
        fmapi.onServerError = { message in
            Task { @MainActor in
                if message.contains("ID token has expired") {
                    do {
                        guard let token = try await Auth.auth().currentUser?.getIDTokenResult(forcingRefresh: true).token else {
                            Toast.error("Your session has expired. Please log in again.")
                            return
                        }
                        try Networking.api.refreshToken(token: token)
                    } catch {
                        Toast.error("Your session has expired. Please log in again.")
                    }
                } else if message.contains("You have been signed out") {
                    AppState.shared.signOut()
                } else {
                    // Currently we ignore the error here
                    // Instead, errors are handled wherever they take place in code
                    // Toast.error(message)
                }
            }
        }
        
        return fmapi
    }()
}

