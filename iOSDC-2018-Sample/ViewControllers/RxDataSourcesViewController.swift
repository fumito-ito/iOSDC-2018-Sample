//
//  RxDataSourcesViewController.swift
//  iOSDC-2018-Sample
//
//  Created by svpcadmin on 2018/08/31.
//  Copyright © 2018年 Fumito Ito. All rights reserved.
//

import UIKit
import Differentiator
import RxDataSources

class RxDataSourcesViewController: UIViewController, SeedGeneratable, SeedUpdatable, MegaSeedGeneratable {

    @IBOutlet weak var fpsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var source: [UUID] = []

    var insertionRatio: Double = 0

    var deletionRatio: Double = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        self.tableView.delegate = self
        self.tableView.dataSource = self

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(RxDataSourcesViewController.didFpsLabelTapped(sender:)))
        self.fpsLabel.addGestureRecognizer(recognizer)
        self.fpsLabel.isUserInteractionEnabled = true
        self.fpsLabel.text = "Tap to ReloadData"

        self.tableView.reloadData()
    }

    @objc func didFpsLabelTapped(sender: UIGestureRecognizer) {
        self.fpsLabel.text = "Calculating..."

        self.reload { [weak self] isCompleted, diffTime, mainTime in
            if isCompleted {
                self?.fpsLabel.text = "Diff is \(floor(diffTime * 100000.0) / 100) ms, Bind main \(floor(mainTime * 100000.0) / 100) ms"
            } else {
                self?.fpsLabel.text = "Filed to calculate estimate time"
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func reload(completion: ((Bool, TimeInterval, TimeInterval) -> Void)? = nil) {
        DispatchQueue.global().async {
            let newValue = self.getNewValue()

            let initialSections = [self.arrayToAnimatableSectionModel(from: self.source)]
            let finalSections = [self.arrayToAnimatableSectionModel(from: newValue)]

            let start = Date()
            let steps = try? Diff.differencesForSectionedView(initialSections: initialSections, finalSections: finalSections)
            let end = Date()

            self.source = newValue

            DispatchQueue.main.async { [weak self] in
                guard let `self` = self, let steps = steps else {
                    completion?(false, 0.0, 0.0)
                    return
                }

                let startMain = Date()
                UIView.animate(withDuration: 0.0, animations: {
                    let config = AnimationConfiguration(insertAnimation: .none, reloadAnimation: .none, deleteAnimation: .none)
                    self.tableView.beginUpdates()
                    for step in steps {
                        self.tableView.performBatchUpdates(step, animationConfiguration: config)
                    }
                    self.tableView.endUpdates()
                }, completion: { isCompleted in
                    let endMain = Date()
                    completion?(true, end.timeIntervalSince(start), endMain.timeIntervalSince(startMain))
                })
            }
        }
    }

    func arrayToAnimatableSectionModel(from array: [UUID]) -> AnimatableSectionModel<Int, UUID> {
        return AnimatableSectionModel(model: 0, items: array)
    }
}

extension RxDataSourcesViewController: UITableViewDelegate {
}

extension RxDataSourcesViewController: UITableViewDataSource {
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
