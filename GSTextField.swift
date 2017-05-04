//
//  GSTextField.swift
//  GreystoneApp
//
//  Created by Ashish Mishra on 8/11/16.
//  Copyright © 2016 Ashish Mishra. All rights reserved.
//

import UIKit

class GSTextField: UITextField {

    var leftTextMargin : CGFloat = 0.0
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        var newBounds = bounds
        newBounds.origin.x += leftTextMargin
        return newBounds
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var newBounds = bounds
        newBounds.origin.x += leftTextMargin
        return newBounds
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        var newBounds = bounds
        newBounds.origin.x += leftTextMargin
        return newBounds
    }

}
