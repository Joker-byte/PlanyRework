//
//  TasksViewModel.swift
//  Plany
//
//  Created by Gianluca Dubioso on 01/02/2026.
//

import Foundation

protocol TasksViewModelDelegate: AnyObject {
    func didUpdateSections()
    func didAddTask()
    func didDeleteTask()
}

final class TasksViewModel {
    
    weak var delegate: TasksViewModelDelegate?
    
    private let taskService: TaskServiceProtocol
    
    private(set) var sections: [Section] = []
    
    var numberOfSections: Int {
        return sections.count
    }
    
    init(taskService: TaskServiceProtocol = TaskService.shared) {
        self.taskService = taskService
    }
    
    func loadSections() {
        sections = taskService.loadSections()
        
        if sections.isEmpty {
            sections = [
                Section(name: "To Do", tasks: []),
                Section(name: "Done", tasks: [])
            ]
            taskService.saveSections(sections)
        }
        
        delegate?.didUpdateSections()
    }
    
    func numberOfTasks(in section: Int) -> Int {
        guard section < sections.count else { return 0 }
        return sections[section].tasks.count
    }
    
    func task(at indexPath: IndexPath) -> Task? {
        guard indexPath.section < sections.count,
              indexPath.row < sections[indexPath.section].tasks.count else {
            return nil
        }
        return sections[indexPath.section].tasks[indexPath.row]
    }
    
    func sectionTitle(for section: Int) -> String? {
        guard section < sections.count else { return nil }
        return sections[section].name
    }
    
    func addTask(name: String, toSection section: Int, shared: Bool = false) {
        let newTask = Task(taskName: name, shared: shared, isDone: false)
        taskService.addTask(newTask, to: section, in: &sections)
        delegate?.didAddTask()
        delegate?.didUpdateSections()
    }
    
    func deleteTask(at indexPath: IndexPath) {
        taskService.removeTask(at: indexPath.row, from: indexPath.section, in: &sections)
        delegate?.didDeleteTask()
        delegate?.didUpdateSections()
    }
    
    func toggleTaskStatus(at indexPath: IndexPath) {
        guard indexPath.section < sections.count,
              indexPath.row < sections[indexPath.section].tasks.count else {
            return
        }
        
        var task = sections[indexPath.section].tasks[indexPath.row]
        taskService.toggleTaskStatus(&task)
        sections[indexPath.section].tasks[indexPath.row] = task
        taskService.saveSections(sections)
        delegate?.didUpdateSections()
    }
    
    func moveTask(from source: IndexPath, to destination: IndexPath) {
        guard source.section == destination.section else { return }
        
        taskService.moveTask(
            from: source.row,
            to: destination.row,
            in: source.section,
            sections: &sections
        )
        delegate?.didUpdateSections()
    }
    
    func shareTask(at indexPath: IndexPath) {
        guard indexPath.section < sections.count,
              indexPath.row < sections[indexPath.section].tasks.count else {
            return
        }
        
        var task = sections[indexPath.section].tasks[indexPath.row]
        task.shared = true
        
        var sharedTasks = taskService.loadTasks()
        sharedTasks.append(task)
        taskService.saveTasks(sharedTasks)
        
        deleteTask(at: indexPath)
    }
}
