//
//  CollectionViewCell.swift
//  DragSelection
//
//  Created by 田中義久 on 2022/09/29.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    var label = UILabel()
    
    var selectedCell : Bool = false
    
    func setLayout(_ text: String){
        let size = self.frame.size.width
        label.frame = CGRect(x: 0, y: 0, width: size, height: size)
        label.text = text
        label.textAlignment = .center
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
        self.addSubview(label)
        if self.selectedCell {
            self.backgroundColor = UIColor.red
        } else {
            self.backgroundColor = UIColor.cyan
        }
    }
    
    
}
