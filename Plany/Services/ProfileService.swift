//
//  ProfileService.swift
//  Plany
//
//  Created by Gianluca Dubioso on 01/02/2026.
//

import Foundation
import UIKit

struct UserProfile {
    var firstName: String?
    var lastName: String?
    var profileImage: Data?

    var fullName: String {
        // Check if both exist and are not empty
        guard let first = firstName, !first.isEmpty,
            let last = lastName, !last.isEmpty
        else {
            return ""
        }
        return "Hello \n\(first) \(last)"
    }

    var displayName: String {
        // Check if both exist and are not empty
        guard let first = firstName, !first.isEmpty,
            let last = lastName, !last.isEmpty
        else {
            return ""
        }
        return "\(first) \(last)"
    }
}

protocol ProfileServiceProtocol {
    func loadProfile() -> UserProfile
    func saveProfile(_ profile: UserProfile)
    func updateName(firstName: String?, lastName: String?)
    func updateProfileImage(_ imageData: Data?)
    func clearProfile()
    func getSettings() -> [String: Bool]
    func saveSetting(key: String, value: Bool)
}

final class ProfileService: ProfileServiceProtocol {

    static let shared = ProfileService()

    private let storage = StorageService.shared

    private init() {}

    func loadProfile() -> UserProfile {
        let firstName = storage.loadString(forKey: StorageService.Keys.userName)
        let lastName = storage.loadString(forKey: StorageService.Keys.userSurname)
        let profileImage = storage.loadData(forKey: StorageService.Keys.profileImage)

        return UserProfile(
            firstName: firstName,
            lastName: lastName,
            profileImage: profileImage
        )
    }

    func saveProfile(_ profile: UserProfile) {
        // Save firstName only if not empty
        if let firstName = profile.firstName, !firstName.isEmpty {
            storage.saveString(firstName, forKey: StorageService.Keys.userName)
        } else {
            storage.remove(forKey: StorageService.Keys.userName)
        }

        // Save lastName only if not empty
        if let lastName = profile.lastName, !lastName.isEmpty {
            storage.saveString(lastName, forKey: StorageService.Keys.userSurname)
        } else {
            storage.remove(forKey: StorageService.Keys.userSurname)
        }

        // Save image only if exists
        if let imageData = profile.profileImage {
            storage.saveData(imageData, forKey: StorageService.Keys.profileImage)
        } else {
            storage.remove(forKey: StorageService.Keys.profileImage)
        }

        // Always save fullName for backwards compatibility
        storage.saveString(profile.fullName, forKey: StorageService.Keys.user)

        // Post notification with displayName or empty string
        NotificationCenter.default.post(
            name: NSNotification.Name("updateName"),
            object: profile.displayName.isEmpty
                ? "profile.default.name".localized : profile.displayName
        )
    }

    func updateName(firstName: String?, lastName: String?) {
        var profile = loadProfile()
        profile.firstName = firstName
        profile.lastName = lastName
        saveProfile(profile)
    }

    func updateProfileImage(_ imageData: Data?) {
        var profile = loadProfile()
        profile.profileImage = imageData
        saveProfile(profile)
    }

    func clearProfile() {
        storage.remove(forKey: StorageService.Keys.userName)
        storage.remove(forKey: StorageService.Keys.userSurname)
        storage.remove(forKey: StorageService.Keys.user)
        storage.remove(forKey: StorageService.Keys.profileImage)

        NotificationCenter.default.post(
            name: NSNotification.Name("updateName"),
            object: "profile.guest".localized
        )
    }

    func getSettings() -> [String: Bool] {
        return [
            "animationsEnabled": storage.loadBool(forKey: StorageService.Keys.animationsEnabled),
            "taskReminders": storage.loadBool(forKey: StorageService.Keys.taskReminders),
            "soundEffects": storage.loadBool(forKey: StorageService.Keys.soundEffects),
        ]
    }

    func saveSetting(key: String, value: Bool) {
        storage.saveBool(value, forKey: key)
    }
}
