//
//  ViewController.swift
//  CoreDataSample
//
//  Created by nurdin affandi on 22/10/24.
//

import UIKit

class ViewController: UIViewController {
    
    /** -coreDataContext: is where  you can go to perform objects in the core data database */
    let coreDataContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    private var models = [ToDoListItem]()
     
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "To Do List"
        view.addSubview(tableView)
        getAllItems()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapAdd)
        )
    }
    
    // MARK: - Functions
    @objc func didTapAdd() {
        let alert = UIAlertController(
            title: "New Item",
            message: "Enter new item",
            preferredStyle: .alert
        )
        alert.addTextField()
        alert.addAction(
            UIAlertAction(
                title: "Submit",
                style: .cancel
            ) { [weak self] _ in
            guard let textField = alert.textFields?.first, 
                  let text = textField.text,
                  !text.isEmpty else { return }
            self?.createItem(name: text )
        })
        present(alert, animated: true)
    }
    
    
    // MARK: - Core Data
    func getAllItems() {
        do {
            models = try coreDataContext.fetch(ToDoListItem.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            // error
        }
    }
    
    func createItem(name: String) {
        let newItem = ToDoListItem(context: coreDataContext)
        newItem.name = name
        newItem.createdAt = Date()
        
        do {
            try coreDataContext.save()
            getAllItems()
        } catch {
            // error
        }
    }
    
    func deleteItem(item: ToDoListItem) {
        coreDataContext.delete(item)
        
        do {
            try coreDataContext.save()
            getAllItems()
        } catch {
            // error
        }
    }
    
    func updateItem(item: ToDoListItem, newName: String) {
        item.name = newName
        do {
            try coreDataContext.save()
            getAllItems()
        } catch {
            // error
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row ]
        let name = model.name
        let date = model.createdAt
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(name ?? "") - \(date?.formatted() ?? "")"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = models[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        let sheet = UIAlertController(
            title: "Edit",
            message: nil,
            preferredStyle: .actionSheet
        )
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Edit", style: .default) { [weak self] _ in
            let alert = UIAlertController(
                title: "Edit Item",
                message: "Edit your item",
                preferredStyle: .alert
            )
            alert.addTextField()
            alert.textFields?.first?.text = item.name
            alert.addAction(
                UIAlertAction(
                    title: "Save",
                    style: .cancel
                ) { [weak self] _ in
                    guard let textField = alert.textFields?.first, 
                          let newName = textField.text,
                          !newName.isEmpty else { return }
                    self?.updateItem(item: item, newName: newName)
                }
            )
            self?.present(alert, animated: true )
        })
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteItem(item: item)
        })
        present(sheet, animated: true )
    }
    
}

