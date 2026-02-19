//
//  TaskService.swift
//  Plany
//
//  Created by Gianluca Dubioso on 01/02/2026.
//

import Foundation

protocol TaskServiceProtocol {
    func loadTasks() -> [Task]
    func saveTasks(_ tasks: [Task])
    func loadSections() -> [Section]
    func saveSections(_ sections: [Section])
    func addTask(_ task: Task, to section: Int, in sections: inout [Section])
    func removeTask(at index: Int, from section: Int, in sections: inout [Section])
    func toggleTaskStatus(_ task: inout Task)
    func moveTask(from sourceIndex: Int, to destinationIndex: Int, in section: Int, sections: inout [Section])
    func getTasksByStatus(from tasks: [Task], isDone: Bool) -> [Task]
    func updateTask(_ updatedTask: Task, in tasks: inout [Task])
    func deleteAllTasks()
}

final class TaskService: TaskServiceProtocol {
    
    static let shared = TaskService()
    
    private let storage = StorageService.shared
    
    private init() {}
    
    func loadTasks() -> [Task] {
        return storage.load([Task].self, forKey: StorageService.Keys.shared) ?? []
    }
    
    func saveTasks(_ tasks: [Task]) {
        storage.save(tasks, forKey: StorageService.Keys.shared)
        NotificationCenter.default.post(name: NSNotification.Name("sharedUpdated"), object: nil)
    }
    
    func loadSections() -> [Section] {
        return storage.load([Section].self, forKey: StorageService.Keys.sections) ?? []
    }
    
    func saveSections(_ sections: [Section]) {
        storage.save(sections, forKey: StorageService.Keys.sections)
    }
    
    func addTask(_ task: Task, to sectionIndex: Int, in sections: inout [Section]) {
        guard sectionIndex < sections.count else { return }
        sections[sectionIndex].tasks.append(task)
        saveSections(sections)
    }
    
    func removeTask(at index: Int, from sectionIndex: Int, in sections: inout [Section]) {
        guard sectionIndex < sections.count,
              index < sections[sectionIndex].tasks.count else { return }
        sections[sectionIndex].tasks.remove(at: index)
        saveSections(sections)
    }
    
    func toggleTaskStatus(_ task: inout Task) {
        task.isDone.toggle()
    }
    
    func moveTask(from sourceIndex: Int, to destinationIndex: Int, in section: Int, sections: inout [Section]) {
        guard section < sections.count,
              sourceIndex < sections[section].tasks.count,
              destinationIndex < sections[section].tasks.count else { return }
        
        let task = sections[section].tasks.remove(at: sourceIndex)
        sections[section].tasks.insert(task, at: destinationIndex)
        saveSections(sections)
    }
    
    func getTasksByStatus(from tasks: [Task], isDone: Bool) -> [Task] {
        return tasks.filter { $0.isDone == isDone }
    }
    
    func updateTask(_ updatedTask: Task, in tasks: inout [Task]) {
        if let index = tasks.firstIndex(where: { $0.taskName == updatedTask.taskName }) {
            tasks[index] = updatedTask
            saveTasks(tasks)
        }
    }
    
    func deleteAllTasks() {
        storage.remove(forKey: StorageService.Keys.shared)
        storage.remove(forKey: StorageService.Keys.sections)
    }
}
