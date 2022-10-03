//
//  CollectionView.swift
//  DragSelection
//
//  Created by 田中義久 on 2022/09/29.
//

import UIKit

protocol AdditionalDelegate{
    func selectTouchBeganCell(touches: Set<UITouch>, beganPoint: CGPoint?)
    func selectTouchRangeCells(touches: Set<UITouch>, beganPoint: CGPoint?, movedPoint: CGPoint?)
    func selectTouchEndedCells()
}

class CollectionView: UICollectionView{
    var additionalDelegate: AdditionalDelegate?
    
    var touchesBeganPoint: CGPoint?
    var touchesMovedPoint: CGPoint?
    
//    var parentViewController: ViewController!
    var previewRangeSelectedIndexPathes = [IndexPath]()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.touchesBeganPoint = touches.first?.location(in: self)
        
        // タップした座標のセルの選択ステータスを変更する
        self.additionalDelegate?.selectTouchBeganCell(touches: touches, beganPoint: touchesBeganPoint)
//        print("CV began", touchesBeganPoint)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        if let locationPoint = touches.first?.location(in: self) {
            self.touchesMovedPoint = locationPoint
        }
        
        // タップした範囲内のセルの選択ステータスを変更する
        self.additionalDelegate?.selectTouchRangeCells(touches: touches, beganPoint: touchesBeganPoint, movedPoint: touchesMovedPoint)
//        print("CV moved", touchesMovedPoint)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.touchesBeganPoint = nil
        self.touchesMovedPoint = nil
        self.previewRangeSelectedIndexPathes.removeAll()
        
        // タッチイベントが終了したので、スクロールを可能に戻す
        self.isScrollEnabled = true
        
        // 範囲選択表示を削除する
        self.additionalDelegate?.selectTouchEndedCells()
        print("CV ended")
    }
}
