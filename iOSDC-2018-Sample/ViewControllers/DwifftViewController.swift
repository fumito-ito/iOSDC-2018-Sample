//
//  DwifftViewController.swift
//  iOSDC-2018-Sample
//
//  Created by svpcadmin on 2018/08/30.
//  Copyright © 2018年 Fumito Ito. All rights reserved.
//

import UIKit
import Dwifft

class DwifftViewController: UIViewController, SeedGeneratable, SeedUpdatable, MegaSeedGeneratable {

    @IBOutlet weak var fpsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    var source: [UUID] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        self.tableView.delegate = self
        self.tableView.dataSource = self

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(DwifftViewController.didFpsLabelTapped(sender:)))
        self.fpsLabel.addGestureRecognizer(recognizer)
        self.fpsLabel.isUserInteractionEnabled = true
        self.fpsLabel.text = "Tap to ReloadData"

        self.source = self.seed
        self.tableView.reloadData()
    }

    @objc func didFpsLabelTapped(sender: UIGestureRecognizer) {
        self.fpsLabel.text = "Calculating..."

        self.reload { [weak self] isCompleted, estimatedTime in
            if isCompleted {
                self?.fpsLabel.text = "Estimated Time is \(floor(estimatedTime * 100000.0) / 100) ms"
            } else {
                self?.fpsLabel.text = "Filed to calculate estimate time"
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func reload(completion: ((Bool, TimeInterval) -> Void)? = nil) {
        DispatchQueue.global().async {
            let newValue = self.getNewValue()

            let start = Date()
            let steps = Dwifft.diff(self.source, newValue)
            let end = Date()

            self.source = newValue

            DispatchQueue.main.async { [weak self] in
                self?.tableView.performBatchUpdates({
                    steps.forEach({ step in
                        switch step {
                        case let .insert(index, _):
                            self?.tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                        case let .delete(index, _):
                            self?.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                        }
                    })
                }) { isCompleted in
                    completion?(isCompleted, end.timeIntervalSince(start))
                }
            }
        }
    }

    func getNewValue() -> [UUID] {
        return self.update(self.source, insertionRatio: 0.1, deletionRatio: 0.1)
    }
}

extension DwifftViewController: UITableViewDelegate {
}

extension DwifftViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return source.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = self.source[indexPath.row].uuidString

        return cell
    }
}
