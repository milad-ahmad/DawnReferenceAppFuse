//
//  AppRouter.swift
//  dawn-reference-app-fuse
//
//  Created by Milad Ahmad on 17-06-2026.
//

import SwiftUI
import Observation

@MainActor
@Observable
public final class AppRouter {
    public var selectedTab: Int = 0
    public var featuresPath = NavigationPath()
    public var errorMessage: String? = nil
    
    public init() {}
   
    public func handle(url: URL) {
        guard url.scheme == "dawnapp" else { return }
        
        errorMessage = nil
        let target = (url.host ?? url.path).replacingOccurrences(of: "/", with: "").lowercased()
        
        featuresPath = NavigationPath()
        
        switch target {
        case "home":
            selectedTab = 0
        case "features":
            selectedTab = 1
        case "location":
            selectedTab = 1
            featuresPath.append("location")
        case "biometrics":
            selectedTab = 1
            featuresPath.append("biometrics")
        case "camera":
            selectedTab = 1
            featuresPath.append("camera")
        default:
            errorMessage = "Invalid route: \(url.absoluteString)"
            selectedTab = 0
        }
    }
}
