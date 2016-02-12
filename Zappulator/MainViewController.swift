//
//  MainViewController.swift
//  Zappulator
//
//  Created by Aleksander Skjoelsvik on 2/2/16.
//  Copyright © 2016 Aleksander Skjoelsvik. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    /*  TO DO:
        1. Add calculations label
            1. Fix 4" layout
        2. Support landscape orientation
        3. Support iPads
    */
    
    // MARK: CONSTANTS
    
    // Constants
    let maxInteger = 1_000_000_000.0
    
    // Holds the different operations
    typealias Operation = (Double, Double) -> Double
    let operations: [String: Operation] = [
        "+": {(a, b) in a + b},
        "-": {(a, b) in a - b},
        "x": {(a, b) in a * b},
        "/": {(a, b) in a / b}
    ]
    
    // MARK: OUTLETS
    
    // Outlets for the different labels
    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var calculationsLabel: UILabel!
    
    // MARK: VARIABLES
    
    // Variables to hold the different calculations and statuses
    var totalSum = 0.0
    var currentNumber = 0.0
    var currentOperator: Operation?
    var decimalInput = false
    
    // MARK: - INITIALIZATION

    // Initialize the view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Reset the labels
        updateSumLabel(0)
        calculationsLabel.text = ""
        
        // Add long press gesture recognizer to sum label for copy functionality
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: "sumLabelDidLongPress:")
        sumLabel.addGestureRecognizer(gestureRecognizer)
    }
    
    // MARK: VIEW LAYOUT
    
    // Update sum label text
    func updateSumLabel(value: Double) {
        
        // Formatter adds separator and removes decimal point if not necesarry
        let numberFormatter = NSNumberFormatter()
        numberFormatter.groupingSeparator = " "
        numberFormatter.numberStyle = .DecimalStyle
        
        sumLabel.text = numberFormatter.stringFromNumber(value)
    }
    
    // MARK: USER INTERACTION
    
    // Called when long pressing on sum label
    func sumLabelDidLongPress(recognizer: UIGestureRecognizer) {
        if let recognizerView = recognizer.view, recognizerSuperView = recognizerView.superview {
            
            // Create and display the menu controller
            let menuController = UIMenuController.sharedMenuController()
            menuController.setTargetRect(recognizerView.frame, inView: recognizerSuperView)
            menuController.setMenuVisible(true, animated: true)
            recognizerView.becomeFirstResponder()
        }
    }
    
    // MARK: ACTIONS
    
    // Executed when pressing button 0-9
    @IBAction func numberButtonDidPress(sender: UIButton) {
        
        // Tag of button represents number value
        let input = sender.tag
        
        // If the user is currently inputting a decimal value
        if decimalInput {
            
            // Make sure the number isn't already a decimal number (zappulator only allows decimal input of size 1)
            if rint(currentNumber) == currentNumber {
            
                // Move the new number one spot down
                var newNumber = Double(input) / 10.0
                
                // Add to current number
                newNumber = currentNumber + newNumber
                currentNumber = newNumber
            }
            
        // If the user is inputting any other value
        } else {
            // Multiply current number by 10 to move one spot up
            var newNumber = currentNumber * 10.0
            
            // Add inputted number
            newNumber += Double(input)
            
            // Make sure new number is not above the max
            if newNumber < maxInteger {
                currentNumber = newNumber
            }
        }

        // Update the label
        updateSumLabel(currentNumber)
    }
    
    // Executed when pressing button + - x /
    @IBAction func operatorButtonDidPress(sender: UIButton) {
        
        // Remove decimal input
        decimalInput = false
        
        // Execute any pending operations
        if let operation = currentOperator {
            totalSum = operation(totalSum, currentNumber)
        } else {
            totalSum = Double(currentNumber)
        }
        
        // Set the current operator to the pressed operator
        currentOperator = operations[sender.currentTitle!]
        
        // Reset the current number
        currentNumber = 0
        
        // Update the label
        updateSumLabel(totalSum)
    }
    
    // Executed when pressing button =
    @IBAction func sumButtonDidPress(sender: UIButton) {
        
        // Remove decimal input
        decimalInput = false
        
        // Execute any pending operations
        if let operation = currentOperator {
            totalSum = operation(totalSum, currentNumber)
        } else {
            totalSum = Double(currentNumber)
        }
        
        // Reset operator and current number
        currentOperator = nil
        currentNumber = 0
        
        updateSumLabel(totalSum)
    }
    
    // Executed when pressing button ac
    @IBAction func allClearButtonDidPress(sender: UIButton) {
        decimalInput = false
        totalSum = 0
        currentNumber = 0
        currentOperator = nil
        updateSumLabel(0)
    }
    
    // Executed when pressing the +/- button
    @IBAction func negateButtonDidPress(sender: UIButton) {
        
        // Update the total sum if there is no current number (i.e. after a calculation and the sum is displayed in the field)
        if currentNumber == 0 && totalSum != 0 {
            totalSum = -totalSum
        
        // Otherwise just negate the current number
        } else {
            currentNumber = -currentNumber
        }
        
        updateSumLabel(currentNumber)
    }
    
    // Executed when pressing the % button
    @IBAction func percentButtonDidPress(sender: UIButton) {
        
        if totalSum == 0 {
            // If there is no sum, simply get the percent value of the current integer
            currentNumber = currentNumber / 100
        } else {
            // Otherwise get the current value as a percent of the total sum
            currentNumber = totalSum * (currentNumber / 100)
        }
        
        updateSumLabel(currentNumber)
    }
    
    // Executed when pressing the , button
    @IBAction func decimalButtonDidPress(sender: UIButton) {
        decimalInput = true
    }
}

// MARK:

// UILabel extension to add copy functionality
extension UILabel {

    // Override this to allow the label to become the first responder
    override public func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    // Override this to let the label know it can perform a certain action
    override public func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        return (action == "copy:")
    }
    
    // Override this for copy functionality
    override public func copy(sender: AnyObject?) {
        UIPasteboard.generalPasteboard().string = text
    }
}