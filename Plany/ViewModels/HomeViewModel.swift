//
//  HomeViewModel.swift
//  Plany
//
//  Created by Gianluca Dubioso on 01/02/2026.
//

import Foundation

protocol HomeViewModelDelegate: AnyObject {
    func didUpdateTasks()
    func didUpdateHomework()
    func didLoadData()
}

final class HomeViewModel {

    weak var delegate: HomeViewModelDelegate?

    private let taskService: TaskServiceProtocol
    private let homeworkService: HomeworkServiceProtocol
    private let profileService: ProfileServiceProtocol

    private(set) var tasks: [Task] = []
    private(set) var homework: [Homework] = []

    var allTasks: [Task] {
        return tasks
    }

    var todoTasks: [Task] {
        return taskService.getTasksByStatus(from: tasks, isDone: false)
    }

    var doneTasks: [Task] {
        return taskService.getTasksByStatus(from: tasks, isDone: true)
    }

    var numberOfSections: Int {
        return tasks.isEmpty ? 1 : 2
    }

    init(
        taskService: TaskServiceProtocol = TaskService.shared,
        homeworkService: HomeworkServiceProtocol = HomeworkService.shared,
        profileService: ProfileServiceProtocol = ProfileService.shared
    ) {
        self.taskService = taskService
        self.homeworkService = homeworkService
        self.profileService = profileService
        setupNotifications()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTaskUpdate),
            name: NSNotification.Name("sharedUpdated"),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleHomeworkUpdate),
            name: NSNotification.Name("updateArray"),
            object: nil
        )
    }

    @objc private func handleTaskUpdate() {
        loadTasks()
    }

    @objc private func handleHomeworkUpdate() {
        loadHomework()
    }

    func loadData() {
        loadTasks()
        loadHomework()
        delegate?.didLoadData()
    }

    func loadTasks() {
        tasks = taskService.loadTasks()
        delegate?.didUpdateTasks()
    }

    func loadHomework() {
        homework = homeworkService.loadHomework()
        delegate?.didUpdateHomework()
    }

    func getTasksForSection(_ section: Int) -> [Task] {
        return section == 0 ? todoTasks : doneTasks
    }

    func numberOfTasksInSection(_ section: Int) -> Int {
        if tasks.isEmpty {
            return 4
        }
        return getTasksForSection(section).count
    }

    func numberOfHomework() -> Int {
        return homework.isEmpty ? 3 : homework.count
    }

    func toggleTaskStatus(at index: Int, in section: Int) {
        let sectionTasks = getTasksForSection(section)
        guard index < sectionTasks.count else { return }

        var task = sectionTasks[index]
        taskService.toggleTaskStatus(&task)
        taskService.updateTask(task, in: &tasks)
    }

    func toggleTaskStatus(_ task: Task) {
        guard let index = tasks.firstIndex(where: { $0.taskName == task.taskName }) else { return }
        var updatedTask = task
        taskService.toggleTaskStatus(&updatedTask)
        tasks[index] = updatedTask
        taskService.saveTasks(tasks)
    }

    func moveTask(_ task: Task, from sourceIndex: Int, to destinationIndex: Int) {
        guard let originalIndex = tasks.firstIndex(where: { $0.taskName == task.taskName }) else {
            return
        }
        tasks.remove(at: originalIndex)
        let insertIndex = destinationIndex > originalIndex ? destinationIndex - 1 : destinationIndex
        tasks.insert(task, at: insertIndex)
        taskService.saveTasks(tasks)
    }

    func deleteTask(at index: Int, in section: Int) {
        let sectionTasks = getTasksForSection(section)
        guard index < sectionTasks.count else { return }

        let taskToRemove = sectionTasks[index]
        if let originalIndex = tasks.firstIndex(where: { $0.taskName == taskToRemove.taskName }) {
            tasks.remove(at: originalIndex)
            taskService.saveTasks(tasks)
        }
    }

    func deleteTask(_ task: Task) {
        guard let index = tasks.firstIndex(where: { $0.taskName == task.taskName }) else { return }
        tasks.remove(at: index)
        taskService.saveTasks(tasks)
    }

    func pushBackTask(at index: Int, in section: Int) {
        let sectionTasks = getTasksForSection(section)
        guard index < sectionTasks.count else { return }

        var task = sectionTasks[index]
        task.shared = false

        if let originalIndex = tasks.firstIndex(where: { $0.taskName == task.taskName }) {
            tasks.remove(at: originalIndex)
        }

        var sections = taskService.loadSections()

        if task.isDone {
            if sections.count == 1 {
                sections.append(Section(name: "Done", tasks: [task]))
            } else {
                let doneIndex = sections.firstIndex(where: { $0.name == "Done" }) ?? 1
                sections[doneIndex].tasks.append(task)
            }
        } else {
            if sections.isEmpty {
                sections.append(Section(name: "To Do", tasks: [task]))
            } else {
                let todoIndex = sections.firstIndex(where: { $0.name == "To Do" }) ?? 0
                sections[todoIndex].tasks.append(task)
            }
        }

        taskService.saveSections(sections)
        taskService.saveTasks(tasks)
    }

    func pushBackTask(_ task: Task) {
        var updatedTask = task
        updatedTask.shared = false

        guard let index = tasks.firstIndex(where: { $0.taskName == task.taskName }) else { return }
        tasks.remove(at: index)

        var sections = taskService.loadSections()

        if updatedTask.isDone {
            if sections.count == 1 {
                sections.append(Section(name: "Done", tasks: [updatedTask]))
            } else {
                let doneIndex = sections.firstIndex(where: { $0.name == "Done" }) ?? 1
                sections[doneIndex].tasks.append(updatedTask)
            }
        } else {
            if sections.isEmpty {
                sections.append(Section(name: "To Do", tasks: [updatedTask]))
            } else {
                let todoIndex = sections.firstIndex(where: { $0.name == "To Do" }) ?? 0
                sections[todoIndex].tasks.append(updatedTask)
            }
        }

        taskService.saveSections(sections)
        taskService.saveTasks(tasks)
    }

    func removeHomework(at index: Int) {
        guard index < homework.count else { return }
        homeworkService.removeHomework(at: index)
        homework.remove(at: index)
    }

    func addHomework(_ homework: Homework) {
        homeworkService.addHomework(
            title: homework.title,
            description: homework.description,
            date: homework.date,
            time: homework.time
        )
        loadHomework()
    }

    func moveHomework(from sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex < homework.count, destinationIndex < homework.count else { return }
        let item = homework.remove(at: sourceIndex)
        homework.insert(item, at: destinationIndex)
        homeworkService.saveHomework(homework)
    }

    func updateHomework(at index: Int, with homework: Homework) {
        guard index < self.homework.count else { return }
        homeworkService.updateHomework(
            at: index,
            title: homework.title,
            description: homework.description,
            date: homework.date,
            time: homework.time
        )
        loadHomework()
    }

    func updateHomework(
        at index: Int, title: String?, description: String?, date: String?, time: String?
    ) {
        guard index < homework.count else { return }
        homeworkService.updateHomework(
            at: index, title: title, description: description, date: date, time: time)
        loadHomework()
    }

    func duplicateHomework(at index: Int) {
        guard index < homework.count else { return }
        let item = homework[index]
        homeworkService.addHomework(
            title: item.title, description: item.description, date: item.date, time: item.time)
        loadHomework()
    }

    // MARK: - Profile Methods
    func getProfile() -> UserProfile {
        return profileService.loadProfile()
    }
}
