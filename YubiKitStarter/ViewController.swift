//
//  ViewController.swift
//  YubiKitStarter
//
//  Created by Dennis Hills on 7/16/19.
//  Copyright © 2019 Dennis Hills. All rights reserved.
//
//  About: This is the main view controller that tracks the YubiKey session state (connected or not connected and displays the key details such as serial number and firmware.
import UIKit

class ViewController: LightningInteractionViewController {

    @IBOutlet weak var lblKeyInserted: UILabel!
    @IBOutlet weak var lblSerial: UILabel!
    @IBOutlet weak var lblFirmware: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if YubiKitDeviceCapabilities.supportsLightningKey {
            // Make sure the session is started
            YubiKitManager.shared.keySession.startSession()
            
            // Enable state observation (see LightningInteractionViewController)
            observeSessionStateUpdates = true
            
            // Update the key session data manually when app loads
            //keySessionStateDidChange()
            
        } else {
            lblKeyInserted.text = "This device or OS does not support a YubiKey."
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if YubiKitDeviceCapabilities.supportsLightningKey {
            // Disable state observation (see LightningInteractionViewController)
            observeSessionStateUpdates = false
            YubiKitManager.shared.keySession.cancelCommands()
        }
    }
    
    private func updateKeyInfo() {
        let state = YubiKitManager.shared.keySession.sessionState
        if (state == .opening) {
            lblKeyInserted.text = "Opening connection to YubiKey"
            
        }
        if (state == .open) {
            guard let keyDescription = YubiKitManager.shared.keySession.keyDescription else {
                return
            }
            lblKeyInserted.text = "\(keyDescription.name) CONNECTED"
            lblKeyInserted.textColor = UIColor.green
            lblFirmware.text = "Firmware: \(keyDescription.firmwareRevision)"
            lblSerial.text = "Serial: \(keyDescription.serialNumber)"
        }
        else // closing or closed
        {
            lblKeyInserted.text = "YubiKey NOT CONNECTED"
            lblKeyInserted.textColor = UIColor.red
            lblFirmware.text = ""
            lblSerial.text = ""
            return
        }
    }
    
    // MARK: - State Observation
    
    override func keySessionStateDidChange() {
        let state = YubiKitManager.shared.keySession.sessionState
        
        if state == .closed {
            //presentLightningActionSheet(state: .insertKey, message: "Insert your YubiKey into the Lightning port.")
        }
        if state == .open {
            //dismissLightningActionSheet()
        }
        updateKeyInfo()
    }
    
    private func presentLightningActionSheetOnMain(state: LightningInteractionViewControllerState, message: String) {
        dispatchMain { [weak self] in
            self?.presentLightningActionSheet(state: state, message: message)
        }
    }
    
    private func dispatchMain(execute: @escaping ()->Void) {
        if Thread.isMainThread {
            execute()
        } else {
            DispatchQueue.main.async(execute: execute)
        }
    }
}

