//
//  ProfileViewModel.swift
//  Plany
//
//  Created by Gianluca Dubioso on 01/02/2026.
//

import Foundation

protocol ProfileViewModelDelegate: AnyObject {
    func didUpdateProfile()
    func didClearProfile()
}

final class ProfileViewModel {

    weak var delegate: ProfileViewModelDelegate?

    private let profileService: ProfileServiceProtocol
    private let taskService: TaskServiceProtocol
    private let homeworkService: HomeworkServiceProtocol

    private(set) var profile: UserProfile

    var firstName: String {
        return profile.firstName ?? ""
    }

    var lastName: String {
        return profile.lastName ?? ""
    }

    var fullName: String {
        return profile.fullName
    }

    var profileImageData: Data? {
        return profile.profileImage
    }

    var settings: [String: Bool] {
        return profileService.getSettings()
    }

    init(
        profileService: ProfileServiceProtocol = ProfileService.shared,
        taskService: TaskServiceProtocol = TaskService.shared,
        homeworkService: HomeworkServiceProtocol = HomeworkService.shared
    ) {
        self.profileService = profileService
        self.taskService = taskService
        self.homeworkService = homeworkService
        self.profile = profileService.loadProfile()
    }

    func loadProfile() {
        profile = profileService.loadProfile()
        delegate?.didUpdateProfile()
    }

    func updateName(firstName: String?, lastName: String?) {
        profileService.updateName(firstName: firstName, lastName: lastName)
        profile = profileService.loadProfile()
        delegate?.didUpdateProfile()
    }

    func updateProfileImage(_ imageData: Data?) {
        profileService.updateProfileImage(imageData)
        profile = profileService.loadProfile()
        delegate?.didUpdateProfile()
    }

    func saveSetting(key: String, value: Bool) {
        profileService.saveSetting(key: key, value: value)
    }

    func clearAllData() {
        taskService.deleteAllTasks()
        homeworkService.deleteAllHomework()
        profileService.clearProfile()
        profile = profileService.loadProfile()
        delegate?.didClearProfile()
    }

    func clearProfile() {
        profileService.clearProfile()
        profile = profileService.loadProfile()
        delegate?.didClearProfile()
    }

    var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}
