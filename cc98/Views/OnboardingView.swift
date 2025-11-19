//
//  OnboardingView.swift
//  cc98
//
//  Created by IGOR on 17/11/2025.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Binding var hasCompletedOnboarding: Bool
    
    var body: some View {
        ZStack {
            Color(hex: "02102b")
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                Image(systemName: viewModel.steps[viewModel.currentStep].icon)
                    .font(.system(size: 90))
                    .foregroundColor(Color(hex: "ffbe00"))
                    .shadow(color: Color(hex: "ffbe00").opacity(0.5), radius: 20, x: 0, y: 10)
                    .padding(.bottom, 20)
                
                Text(viewModel.steps[viewModel.currentStep].title)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Text(viewModel.steps[viewModel.currentStep].description)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                HStack(spacing: 10) {
                    ForEach(0..<viewModel.steps.count, id: \.self) { index in
                        Capsule()
                            .fill(index == viewModel.currentStep ? Color(hex: "bd0e1b") : Color.white.opacity(0.3))
                            .frame(width: index == viewModel.currentStep ? 30 : 10, height: 10)
                            .animation(.spring(), value: viewModel.currentStep)
                    }
                }
                .padding(.bottom, 20)
                
                HStack(spacing: 16) {
                    if viewModel.currentStep > 0 {
                        Button(action: {
                            withAnimation {
                                viewModel.previousStep()
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 56)
                                .background(Color(hex: "0a1a3b"))
                                .cornerRadius(14)
                        }
                    }
                    
                    Button(action: {
                        if viewModel.isLastStep {
                            hasCompletedOnboarding = true
                        } else {
                            withAnimation {
                                viewModel.nextStep()
                            }
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text(viewModel.isLastStep ? "Get Started" : "Next")
                                .font(.system(size: 18, weight: .bold))
                            
                            if !viewModel.isLastStep {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 16, weight: .bold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "bd0e1b"), Color(hex: "ffbe00")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                        .shadow(color: Color(hex: "bd0e1b").opacity(0.4), radius: 12, x: 0, y: 6)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
}

// Color extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
