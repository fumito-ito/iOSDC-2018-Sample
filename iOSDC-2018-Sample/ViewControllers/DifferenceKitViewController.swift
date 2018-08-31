//
//  DifferenceKitViewController.swift
//  iOSDC-2018-Sample
//
//  Created by svpcadmin on 2018/08/31.
//  Copyright © 2018年 Fumito Ito. All rights reserved.
//

import UIKit
import DifferenceKit

class DifferenceKitViewController: UIViewController, SeedGeneratable, SeedUpdatable, MegaSeedGeneratable {

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

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(DifferenceKitViewController.didFpsLabelTapped(sender:)))
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
        DispatchQueue.global().async { [weak self] in
            guard let `self` = self else {
                completion?(false, 0.0, 0.0)
                return
            }

            let newValue = self.getNewValue()

            let start = Date()
            let steps = StagedChangeset(source: self.source, target: newValue)
            let end = Date()

            DispatchQueue.main.async {
                
                let startMain = Date()
                UIView.animate(withDuration: 0.0, animations: {
                    self.tableView.beginUpdates()
                    self.tableView.reload(using: steps, with: .fade, setData: { data in
                        self.source = newValue
                    })
                    self.tableView.endUpdates()
                }, completion: { isCompleted in
                    let endMain = Date()
                    completion?(true, end.timeIntervalSince(start), endMain.timeIntervalSince(startMain))
                })
            }
        }
    }
}

extension DifferenceKitViewController: UITableViewDelegate {
}

extension DifferenceKitViewController: UITableViewDataSource {
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
