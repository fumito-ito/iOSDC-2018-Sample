//
//  ReloadDataViewController.swift
//  iOSDC-2018-Sample
//
//  Created by svpcadmin on 2018/08/31.
//  Copyright © 2018年 Fumito Ito. All rights reserved.
//

import UIKit

class ReloadDataViewController: UIViewController, SeedGeneratable, SeedUpdatable, MegaSeedGeneratable {

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

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(ReloadDataViewController.didFpsLabelTapped(sender:)))
        self.fpsLabel.addGestureRecognizer(recognizer)
        self.fpsLabel.isUserInteractionEnabled = true
        self.fpsLabel.text = "Tap to ReloadData"

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
        DispatchQueue.global().async { [weak self] in
            guard let `self` = self else {
                completion?(false, 0.0)
                return
            }

            let newValue = self.getNewValue()
            self.source = newValue

            DispatchQueue.main.async {
                let start = Date()
                UIView.animate(withDuration: 0.0, animations: {
                    self.tableView.reloadData()
                }, completion: { isCompleted in
                    let end = Date()
                    completion?(true, end.timeIntervalSince(start))
                })

            }
        }
    }
}

extension ReloadDataViewController: UITableViewDelegate {
}

extension ReloadDataViewController: UITableViewDataSource {
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
