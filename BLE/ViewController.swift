//
//  ViewController.swift
//  BLE
//
//  Created by pedoe on 2016/1/7.
//  Copyright © 2016年 NTU. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, bleDiscoveryProtocol {

    @IBOutlet weak var tableView: UITableView!
    
    var ListArray:NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Start the Bluetooth discovery process
        tableView.dataSource = self
        tableView.delegate = self
        
        btDiscoverySharedInstance
        btDiscoverySharedInstance.bleDiscoveryDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Implement didFindPeripherals delegate
    func didFindPeripherals(peripherals: NSMutableArray) {
        ListArray = peripherals
        dispatch_async(dispatch_get_main_queue()){
            self.tableView.reloadData()
        }
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int{
        return ListArray.count
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell{
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        
        var peripheral: CBPeripheral
        peripheral = ListArray.objectAtIndex(indexPath.row) as! CBPeripheral
        cell.textLabel!.text = "\(peripheral.name!)"
        cell.detailTextLabel!.text = "\(peripheral.identifier .UUIDString)"

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let peripheral: CBPeripheral = ListArray.objectAtIndex(indexPath.row) as! CBPeripheral
        let uuid:String = peripheral.identifier.UUIDString
        btDiscoverySharedInstance.connectPeripheral(uuid)
    }
    
    func didConnectPeripherals(peripheral:CBPeripheral){
        self.performSegueWithIdentifier("IdentifierAddNew", sender: nil)
    }
    
    
}

