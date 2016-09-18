//
//  ViewController.swift
//  sensors
//
//  Created by Koan-Sin Tan on 6/19/14.
//  Copyright (c) 2014 Koan-Sin Tan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    var currentNames: [Any] = [], voltageNames: [Any] = [], thermalNames: [Any] = []
    var currentValues: [Any] = [], voltageValues: [Any] = [], thermalValues: [Any] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentNames = currentArray()
        voltageNames = voltageArray()
        thermalNames = thermalArray()
        
        currentValues = returnCurrentValues()
        voltageValues = returnVoltageValues()
        thermalValues = returnThermalValues()
      
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
        case 0:
            return currentNames.count
        case 1:
            return voltageNames.count
        case 2:
            return thermalNames.count
        default:
            return 0;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")!
        let string: NSMutableString = ""
    
        switch (indexPath.section) {
        case 0:
            // cell.textLabel.text =
            let name = currentNames[indexPath.row] as! NSString
            let number = currentValues[indexPath.row] as! NSNumber
            string.appendFormat("%@: %.2lf", name, number.doubleValue)
        case 1:
            let name = voltageNames[indexPath.row] as! NSString
            let number = voltageValues[indexPath.row] as! NSNumber
            string.appendFormat("%@: %.2lf", name, number.doubleValue)
        case 2:
            let name = thermalNames[indexPath.row] as! NSString
            let number = thermalValues[indexPath.row] as! NSNumber
            string.appendFormat("%@: %.2lf", name, number.doubleValue)

        default:
            break;
        }
        
        cell.textLabel?.text = string as String?

        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3;
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch (section) {
        case 0:
            return "Current (A), \(currentNames.count) items"
        case 1:
            return "Voltage (V), \(voltageNames.count) items"
        case 2:
            return "Temperature (°C), \(thermalNames.count) items"
        default:
            return "";
        }
    }
    
    @IBAction func reloadData(_ sender : AnyObject) {
        currentValues = returnCurrentValues()
        voltageValues = returnVoltageValues()
        thermalValues = returnThermalValues()

        tableView.reloadData()
    }
}

