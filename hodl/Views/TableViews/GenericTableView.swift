//
//  GenericTableView.swift
//  Part of my local repo
//
//  Created by Emmanuel Adigun on 2021/06/23.
//  Copyright © 2021 Zignal Systems. All rights reserved.
//

import UIKit

class GenericTableView<T, Cell: UITableViewCell>: UITableView, UITableViewDataSource, UITableViewDelegate {

    typealias CellConfiguration         = (Cell, T) -> Cell
    typealias CellSelection             = (Int,Cell, T) -> Void
    typealias CellActions               = (IndexPath,Cell, T) -> [GenericTableSwipeMenuAction]?
    typealias Callback                  = (GenericTableSwipeMenuAction,IndexPath,Cell?,T?) -> Bool
    
    private var cellType: Cell.Type?
    private var models: [T] = []
    private var filteredModels: [T] = []
    private var callback: Callback? = nil
    private var cellActions: CellActions? = nil
    public  var heightConstraint: NSLayoutConstraint?
    
    private var maxTableHeight: CGFloat = 90.0
    public  var swipeActions: [GenericTableSwipeMenuAction] = [] //[.DeleteRow, .EditRow, .AddRow]
    private (set) var tableHeight: CGFloat = 90.0 {
        didSet {
            self.maxTableHeight = tableHeight
            self.heightConstraint?.isActive = false
            self.heightConstraint = self.heightAnchor.constraint(equalToConstant: tableHeight)
            self.heightConstraint?.isActive = true
        }
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(_ tableCellType: Cell.Type, _ models: [T] = [], _ tableHeight: CGFloat = 90.0, _ cellActions: CellActions? = nil, _ callback: Callback? = nil ) {
        super.init(frame: .zero, style: .plain)
        self.dataSource = self
        self.delegate = self
        self.cellType = tableCellType
        self.callback = callback
        self.cellActions = cellActions
        self.models = models
        self.register(tableCellType.self, forCellReuseIdentifier: tableCellType.reuseIdentifier)
        self.heightConstraint = self.heightAnchor.constraint(equalToConstant: tableHeight)
        self.heightConstraint?.isActive = true
        self.backgroundColor = .defaultBackgroundColor1
        self.separatorColor  = .defaultBackgroundColor1
        
        NotificationCenter.default.addObserver(self,selector: #selector(handleTableViewRefreshNotifications),name: .refreshGenericTableViewData,object: nil)
        self.reloadData()
    
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: Cell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        let model = getModelAt(indexPath)
        if self.callback?(.ConfigureCell,indexPath, cell, getModelAt(indexPath)) == false {
            cell.onConfigureCell(cell: cell, model: model)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView.deselectRow(at: indexPath, animated: true)
        let cell: Cell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        _ = self.callback?(.SelectCell,indexPath, cell, getModelAt(indexPath))
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions: [UIContextualAction] = []
        let cell: Cell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        if let cellActions = self.cellActions {
            swipeActions = cellActions(indexPath, cell, self.getModelAt(indexPath)) ?? []
        }
        if let _ = self.callback, swipeActions.count > 0 {
            for action in swipeActions {
                if action.isValid() {
                    let swipeAction = UIContextualAction(style: .normal, title:  action.Action, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                        _ = self.callback?(action, indexPath, cell, self.getModelAt(indexPath))
                        success(true)
                    })
                    swipeAction.backgroundColor = action.backgroundColor
                    actions.append(swipeAction)
                }
            }
        }
        
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    private func getModelAt(_ indexPath: IndexPath) -> T {
        return models[indexPath.item]
    }
    
    private func reCalculateTableHeight() {
        var th = CGFloat(Float(self.models.count) * 45)
        if models.count > 5 { th = 45 * 5 }
        tableHeight = th
    }
    
    func reloadWithData(models: [T]) {
        self.models = models
        self.reloadData()
    }
    
    func appendData( data: T ) {
        self.models.append(data)
        self.reloadData()
    }
    
    func getData() -> [T] {
        return self.models
    }
    
    @objc func handleTableViewRefreshNotifications(notification: NSNotification) {
        self.reloadData()
    }
    
    /**
     * Returns all cells in a table
     * ## Examples:
     * tableView.cells // array of cells in a tableview
     */
    public var cells: [UITableViewCell] {
      (0..<self.numberOfSections).indices.map { (sectionIndex: Int) -> [UITableViewCell] in
          (0..<self.numberOfRows(inSection: sectionIndex)).indices.compactMap { (rowIndex: Int) -> UITableViewCell? in
              self.cellForRow(at: IndexPath(row: rowIndex, section: sectionIndex))
          }
      }.flatMap { $0 }
    }

}

