//  DateFieldRow.swift
//  Eureka ( https://github.com/xmartlabs/Eureka )
//
//  Copyright (c) 2016 Xmartlabs SRL ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

public protocol DatePickerRowProtocol: class {
    var minimumDate : NSDate? { get set }
    var maximumDate : NSDate? { get set }
    var minuteInterval : Int? { get set }
}


public class DateCell : Cell<NSDate>, CellType {
    
    lazy public var datePicker = UIDatePicker()
    
    public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public override func setup() {
        super.setup()
        accessoryType = .None
        editingAccessoryType =  .None
        datePicker.datePickerMode = datePickerMode()
        datePicker.addTarget(self, action: #selector(DateCell.datePickerValueChanged(_:)), forControlEvents: .ValueChanged)
    }
    
    deinit {
        datePicker.removeTarget(self, action: nil, forControlEvents: .AllEvents)
    }
    
    public override func update() {
        super.update()
        selectionStyle = row.isDisabled ? .None : .Default
        datePicker.setDate(row.value ?? NSDate(), animated: row is CountDownPickerRow)
        datePicker.minimumDate = (row as? DatePickerRowProtocol)?.minimumDate
        datePicker.maximumDate = (row as? DatePickerRowProtocol)?.maximumDate
        if let minuteIntervalValue = (row as? DatePickerRowProtocol)?.minuteInterval{
            datePicker.minuteInterval = minuteIntervalValue
        }
        if row.isHighlighted {
            textLabel?.textColor = tintColor
        }
    }
    
    public override func didSelect() {
        super.didSelect()
        row.deselect()
    }
    
    override public var inputView : UIView? {
        if let v = row.value{
            datePicker.setDate(v, animated:row is CountDownRow)
        }
        return datePicker
    }
    
    func datePickerValueChanged(sender: UIDatePicker){
        row.value = sender.date
        detailTextLabel?.text = row.displayValueFor?(row.value)
    }
    
    private func datePickerMode() -> UIDatePickerMode{
        switch row {
        case is DateRow:
            return .Date
        case is TimeRow:
            return .Time
        case is DateTimeRow:
            return .DateAndTime
        case is CountDownRow:
            return .CountDownTimer
        default:
            return .Date
        }
    }
    
    public override func cellCanBecomeFirstResponder() -> Bool {
        return canBecomeFirstResponder()
    }
    
    public override func canBecomeFirstResponder() -> Bool {
        return !row.isDisabled;
    }
}


public class _DateFieldRow: Row<NSDate, DateCell>, DatePickerRowProtocol, NoValueDisplayTextConformance {
    
    /// The minimum value for this row's UIDatePicker
    public var minimumDate : NSDate?
    
    /// The maximum value for this row's UIDatePicker
    public var maximumDate : NSDate?
    
    /// The interval between options for this row's UIDatePicker
    public var minuteInterval : Int?
    
    /// The formatter for the date picked by the user
    public var dateFormatter: NSDateFormatter?
    
    public var noValueDisplayText: String? = nil
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = { [unowned self] value in
            guard let val = value, let formatter = self.dateFormatter else { return nil }
            return formatter.stringFromDate(val)
        }
    }
}