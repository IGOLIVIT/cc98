//
//  OnboardingViewModel.swift
//  cc98
//
//  Created by IGOR on 17/11/2025.
//

import Foundation
import Combine

class OnboardingViewModel: ObservableObject {
    @Published var currentStep = 0
    
    let steps = [
        OnboardingStep(
            title: "Welcome!",
            description: "Get ready for an exciting collection of mini-games that will test your skills and reflexes!",
            icon: "gamecontroller.fill"
        ),
        OnboardingStep(
            title: "Play & Compete",
            description: "Challenge yourself with various games across different categories - puzzle, action, memory, and logic!",
            icon: "trophy.fill"
        ),
        OnboardingStep(
            title: "Unlock New Games",
            description: "Earn points by playing games to unlock new challenges and compete for high scores!",
            icon: "lock.open.fill"
        ),
        OnboardingStep(
            title: "Track Your Progress",
            description: "Monitor your stats, achievements, and climb the leaderboards as you become a gaming master!",
            icon: "chart.bar.fill"
        )
    ]
    
    var isLastStep: Bool {
        currentStep == steps.count - 1
    }
    
    func nextStep() {
        if currentStep < steps.count - 1 {
            currentStep += 1
        }
    }
    
    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }
}

struct OnboardingStep {
    let title: String
    let description: String
    let icon: String
}
