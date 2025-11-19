//
//  SettingsViewModel.swift
//  GeoDash
//
//  Created by IGOR on 17/11/2025.
//

import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published var showDeleteConfirmation = false
    @Published var userData: UserData
    
    private let dataService = DataService.shared
    
    init(userData: UserData) {
        self.userData = userData
    }
    
    func deleteAccount(completion: @escaping () -> Void) {
        dataService.deleteUserData()
        completion()
    }
    
    func saveUsername(_ newUsername: String) {
        userData.username = newUsername
        dataService.saveUserData(userData)
    }
}

