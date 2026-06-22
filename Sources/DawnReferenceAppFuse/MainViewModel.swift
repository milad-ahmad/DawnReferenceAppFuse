//
//  SwiftUIView.swift
//  dawn-reference-app-fuse
//
//  Created by Milad Ahmad on 22-06-2026.
//

import SwiftUI

@MainActor
@Observable
public final class MainViewModel {
    public var router: AppRouter

    public var showErrorAlert: Bool {
        get { router.errorMessage != nil }
        set {
            if !newValue {
                router.errorMessage = nil
            }
        }
    }

    public init(router: AppRouter) {
        self.router = router
    }
}
