//
//  HomeView.swift
//  OnboardingApp
//
//  Created by Milad Ahmad on 07-05-2026.
//

import SwiftUI

public struct HomeView: View {
    public var body: some View {

        ZStack {
            //background
//            setGradient()

            //foreground
            ScrollView {
                Text(
                    "welcome to this Dawn reference app for translations to Android"
                )
                .font(.title)
                .bold()
                .foregroundStyle(.primary)
                .padding()
            }

        }
    }
}
