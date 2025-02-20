//
//  Navigation.swift
//  iosApp
//
//  Created by Jared Warren on 10/18/23.
//  Copyright © 2023 FunnelMink, LLC. All rights reserved.
//

import Foundation
import SwiftUI

// One day we might need to create an iPad-specific version of this class
// It would be used via conditional compilation/compiler directives
// The iPad specific version would allow for an arbitrary amount of top-level tabs (not capped at 5)
class Navigation: ObservableObject {
    static let shared = Navigation()
    private init() {
        _state._selectedTab = UserDefaults.standard.integer(forKey: "Navigation._state._selectedTab")
    }
    
    @Published var _state = State()
    var _canDisplayFAB: Bool {
        guard _state._selectedTab != FunnelminkTab.settings.rawValue else { return false }
        switch _state._selectedTab {
        case 0: return _state._0.isEmpty
        case 1: return _state._1.isEmpty
        case 2: return _state._2.isEmpty
        case 3: return _state._3.isEmpty
        case 4: return _state._4.isEmpty
        default: return false
        }
    }
    var _onModalDismiss: (() -> Void)?
    
    struct State: Hashable, Equatable {
        var _dismissTask: Task<Void, Error>?
        var _selectedTab = 0
        
        // navigation stack for each tab
        var _0 = [Segue]()
        var _1 = [Segue]()
        var _2 = [Segue]()
        var _3 = [Segue]()
        var _4 = [Segue]()
        
        // navigation stack when not logged in
        var _unauthenticated = [UnauthenticatedSegue]()
        
        var _sheet: Modal?
        var _fullscreen: Modal?
        var _alert: Modal?
        
        var _toast: Toast?
        var _modalToast: Toast?
    }
    
    func _path(index: Int) -> Binding<[Segue]> {
        switch index {
        case 0: return Binding(get: { self._state._0 }, set: { self._state._0 = $0 } )
        case 1: return Binding(get: { self._state._1 }, set: { self._state._1 = $0 } )
        case 2: return Binding(get: { self._state._2 }, set: { self._state._2 = $0 } )
        case 3: return Binding(get: { self._state._3 }, set: { self._state._3 = $0 } )
        default: return Binding(get: { self._state._4 }, set: { self._state._4 = $0 } )
        }
    }
    
    func segue(_ segue: Segue) {
        switch _state._selectedTab {
        case 0: _state._0.append(segue)
        case 1: _state._1.append(segue)
        case 2: _state._2.append(segue)
        case 3: _state._3.append(segue)
        default: _state._4.append(segue)
        }
    }
    
    //TODO: update all present functions
    func presentAlert(_ modal: Modal) {
        var state = _state
        state._alert = modal
        state._fullscreen = nil
        state._sheet = nil
        _state = state
    }
    
    func popSegue() {
        switch _state._selectedTab {
        case 0: _state._0.removeLast()
        case 1: _state._1.removeLast()
        case 2: _state._2.removeLast()
        case 3: _state._3.removeLast()
        default: _state._4.removeLast()
        }
    }
    
    func popSegueToRoot() {
        switch _state._selectedTab {
        case 0: _state._0 = []
        case 1: _state._1 = []
        case 2: _state._2 = []
        case 3: _state._3 = []
        default: _state._4 = []
        }
    }
    
    func modalSheet(_ modal: Modal, onDismiss: (() -> Void)? = nil) {
        var state = _state
        state._fullscreen = nil
        state._sheet = modal
        _onModalDismiss = { onDismiss?(); self._onModalDismiss = nil }
        _state = state
    }
    
    func modalFullscreen(_ modal: Modal, onDismiss: (() -> Void)? = nil) {
        var state = _state
        state._sheet = nil
        state._fullscreen = modal
        _onModalDismiss = { onDismiss?(); self._onModalDismiss = nil }
        _state = state
    }
    
    func dismissModal() {
        var state = _state
        state._sheet = nil
        state._fullscreen = nil
        state._alert = nil
        _state = state
    }
    
    func externalDeeplink(to deeplink: ExternalDeeplink) {
        if let url = deeplink.url,
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func externalDeeplink(to url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func externalDeeplink(to string: String) {
        if let url = URL(string: string),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

protocol NavigationSegue: Hashable, Equatable {}

extension NavigationSegue {
    var rawValue: String { "\(self)" }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}

extension Modal: Hashable, Equatable {
    var id: String { rawValue }
    var rawValue: String { "\(self)" }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}
