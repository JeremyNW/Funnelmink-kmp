//
//  FeatureFlags.swift
//  iosApp
//
//  Created by Jared Warren on 1/23/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Foundation
import FirebaseRemoteConfig

enum FeatureFlags: String, CaseIterable {
    case funnelsTestUI
    
    static var isOverridingRemoteConfig: Bool {
        defaults.bool(forKey: "FeatureFlags.isOverridingRemoteConfig")
    }
    
    var isEnabled: Bool {
        if Self.isOverridingRemoteConfig {
            return Self.defaults.bool(forKey: "FeatureFlags.\(rawValue)")
        }
        return Self.remoteConfig["iOS_ff_\(rawValue)"].boolValue
    }
    
    func set(_ isEnabled: Bool) {
        Self.defaults.set(isEnabled, forKey: "FeatureFlags.\(rawValue)")
    }
    
    static private let remoteConfig = RemoteConfig.remoteConfig()
    
    // share the same UserDefaults between `funnelmink` and `funnelmink dev`
    static let defaults = UserDefaults(suiteName: "group.com.funnelmink.crm")!
}
