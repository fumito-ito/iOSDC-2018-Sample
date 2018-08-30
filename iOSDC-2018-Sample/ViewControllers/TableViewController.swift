//
//  TableViewController.swift
//  iOSDC-2018-Sample
//
//  Created by svpcadmin on 2018/08/31.
//  Copyright © 2018年 Fumito Ito. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    typealias SegueCargo = (Int, Double, Double)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    let stacks = [
        ("Ins: 10%, Del: 10%", 1000, 0.1, 0.1),
        ("Ins: 10%, Del: 10%", 10000, 0.1, 0.1),
        ("Ins: 30%, Del: 30%", 1000, 0.3, 0.3),
        ("Ins: 30%, Del: 30%", 10000, 0.3, 0.3),
    ]

    let methods = [
        "Dwifft",
        "EditDistance",
        "RxDataSources",
        "DifferenceKit",
        "reloadData"
    ]

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let method = self.methods[indexPath.row]

        cell.textLabel?.text = method

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(self.stacks[section].0) with \(self.stacks[section].1) rows"
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let method = self.methods[indexPath.row]
        let numberOfRows = self.stacks[indexPath.section].1
        let insertionRatio = self.stacks[indexPath.section].2
        let deletionRatio = self.stacks[indexPath.section].3

        let cargo = SegueCargo(numberOfRows, insertionRatio, deletionRatio)
        performSegue(withIdentifier: method.lowercased(), sender: cargo)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cargo = sender as? SegueCargo else {
            return
        }

        switch cargo.0 {
        case 1000:
            var viewController = segue.destination as? SeedGeneratable
            viewController?.prepareSeed()
        case 10000:
            var viewController = segue.destination as? MegaSeedGeneratable
            viewController?.prepareSeed()
        default:
            break
        }

        var viewController = segue.destination as? SeedUpdatable
        viewController?.insertionRatio = cargo.1
        viewController?.deletionRatio = cargo.2
    }
}
