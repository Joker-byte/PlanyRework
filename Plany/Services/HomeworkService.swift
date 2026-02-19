//
//  HomeworkService.swift
//  Plany
//
//  Created by Gianluca Dubioso on 01/02/2026.
//

import Foundation

struct Homework: Codable {
    var title: String
    var description: String
    var date: String
    var time: String
}

protocol HomeworkServiceProtocol {
    func loadHomework() -> [Homework]
    func saveHomework(_ homework: [Homework])
    func addHomework(title: String, description: String, date: String, time: String)
    func removeHomework(at index: Int)
    func updateHomework(
        at index: Int, title: String?, description: String?, date: String?, time: String?)
    func validateHomeworkArrays()
    func deleteAllHomework()
}

final class HomeworkService: HomeworkServiceProtocol {

    static let shared = HomeworkService()

    private let storage = StorageService.shared

    private init() {}

    func loadHomework() -> [Homework] {
        let titles = loadArray(forKey: StorageService.Keys.titleText)
        let descriptions = loadArray(forKey: StorageService.Keys.tagText)
        let dates = loadArray(forKey: StorageService.Keys.dateText)
        let times = loadArray(forKey: StorageService.Keys.dateTime)

        let count = min(titles.count, descriptions.count, dates.count, times.count)

        return (0..<count).map { index in
            Homework(
                title: titles[index],
                description: descriptions[index],
                date: dates[index],
                time: times[index]
            )
        }
    }

    func saveHomework(_ homework: [Homework]) {
        let titles = homework.map { $0.title }
        let descriptions = homework.map { $0.description }
        let dates = homework.map { $0.date }
        let times = homework.map { $0.time }

        saveArray(titles, forKey: StorageService.Keys.titleText)
        saveArray(descriptions, forKey: StorageService.Keys.tagText)
        saveArray(dates, forKey: StorageService.Keys.dateText)
        saveArray(times, forKey: StorageService.Keys.dateTime)

        NotificationCenter.default.post(name: NSNotification.Name("updateArray"), object: nil)
    }

    func addHomework(title: String, description: String, date: String, time: String) {
        var homework = loadHomework()
        homework.append(Homework(title: title, description: description, date: date, time: time))
        saveHomework(homework)
    }

    func removeHomework(at index: Int) {
        var homework = loadHomework()
        guard index < homework.count else { return }
        homework.remove(at: index)
        saveHomework(homework)
    }

    func updateHomework(
        at index: Int, title: String?, description: String?, date: String?, time: String?
    ) {
        var homework = loadHomework()
        guard index < homework.count else { return }

        if let title = title {
            homework[index].title = title
        }
        if let description = description {
            homework[index].description = description
        }
        if let date = date {
            homework[index].date = date
        }
        if let time = time {
            homework[index].time = time
        }

        saveHomework(homework)
    }

    func validateHomeworkArrays() {
        let homework = loadHomework()
        saveHomework(homework)
    }

    func deleteAllHomework() {
        storage.remove(forKey: StorageService.Keys.titleText)
        storage.remove(forKey: StorageService.Keys.tagText)
        storage.remove(forKey: StorageService.Keys.dateText)
        storage.remove(forKey: StorageService.Keys.dateTime)
    }

    private func loadArray(forKey key: String) -> [String] {
        // Use StorageService to support all persistence methods (UserDefaults, CoreData, etc.)
        guard let data = storage.loadData(forKey: key),
            let array = try? JSONDecoder().decode([String].self, from: data)
        else {
            return []
        }
        return array
    }

    private func saveArray(_ array: [String], forKey key: String) {
        // Use StorageService to support all persistence methods (UserDefaults, CoreData, etc.)
        guard let data = try? JSONEncoder().encode(array) else { return }
        storage.saveData(data, forKey: key)
    }
}
