//
//  HomeworkViewModel.swift
//  Plany
//
//  Created by Gianluca Dubioso on 01/02/2026.
//

import Foundation

protocol HomeworkViewModelDelegate: AnyObject {
    func didSaveHomework()
    func showError(_ message: String)
}

final class HomeworkViewModel {
    
    weak var delegate: HomeworkViewModelDelegate?
    
    private let homeworkService: HomeworkServiceProtocol
    
    init(homeworkService: HomeworkServiceProtocol = HomeworkService.shared) {
        self.homeworkService = homeworkService
    }
    
    func saveHomework(title: String, description: String, date: String, time: String) {
        guard !title.isEmpty, !description.isEmpty else {
            delegate?.showError("Text Field can't be Empty")
            return
        }
        
        homeworkService.addHomework(
            title: title,
            description: description,
            date: date,
            time: time
        )
        
        delegate?.didSaveHomework()
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
