//
//  ViewController.swift
//  DragSelection
//
//  Created by 田中義久 on 2022/09/29.
//

import UIKit

class ViewController: UIViewController {
    // 特に設定する部分
    var data = [String]()
    let numOfRow:CGFloat = 5
    
    @IBOutlet var collectionView: CollectionView!
    
    var selectedIndices = [Int]()
    var cachedSelectedIndices = [Int]()
    var updateSelectedIndices = [Int]()
    var updateBooleanValue = false
    var scrollStartHeightTop = CGFloat()
    var scrollStartHeightBottom = CGFloat()
    var shouldFinish = false
    var cellSize = CGSize()
    
    private var autoScrollTimer = Timer()
    var isNeedToStartTimer = true

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        collectionView.additionalDelegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = .lightGray
        
        for i in 1...150{
            data.append( String(i) )
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        scrollStartHeightTop = self.view.safeAreaInsets.top + 50
        scrollStartHeightBottom = scrollStartHeightTop + collectionView.frame.height - 100
        let width = ( self.view.frame.width - 9 * (numOfRow + 1) ) / numOfRow
        cellSize = CGSize(width: width, height: width)
        collectionView.reloadData()
    }
}

extension ViewController: AdditionalDelegate{
    func selectTouchEndedCells() {
        DispatchQueue.main.async {
            self.shouldFinish = true
            self.stopAutoScrollIfNeeded()
        }
    }
    
    func selectTouchBeganCell(touches: Set<UITouch>, beganPoint: CGPoint?) {
        if let indexPath = self.collectionView.indexPathForItem(at: beganPoint!) {
            self.collectionView.previewRangeSelectedIndexPathes.append(indexPath)
            updateCollectionView(indexPath)
            cachedSelectedIndices = selectedIndices
        }
    }
    
    /**
     移動した座標間に含まれるセルの選択ステータスを変更する
     - paremeter beganPoint: 選択を開始した座標
     - parameter movedPoint: 選択範囲の終端の座標
     */
    func selectTouchRangeCells(touches: Set<UITouch>, beganPoint: CGPoint?, movedPoint: CGPoint?) {
        if let locationPoint = touches.first?.location(in: self.view){
            let timeInterval = 0.1
            if(locationPoint.y <= scrollStartHeightTop){
                collectionView.isScrollEnabled = true
                startAutoScroll(duration: timeInterval, direction: "up")
            } else if(scrollStartHeightBottom <= locationPoint.y){
                collectionView.isScrollEnabled = true
                startAutoScroll(duration: timeInterval, direction: "down")
            } else{
                collectionView.isScrollEnabled = false
                stopAutoScrollIfNeeded()
            }
        }
        // 座標内に含まれるセルを取得する
        if let beganPoint = beganPoint, let movedPoint = movedPoint{
            if let beganIndexPath = collectionView.indexPathForItem(at: beganPoint), let movedIndexPath = collectionView.indexPathForItem(at: movedPoint){
                updateSelectedIndices = []
                for item in min(beganIndexPath.item, movedIndexPath.item)...max(beganIndexPath.item, movedIndexPath.item){
                    updateSelectedIndices.append(item)
                }
                selectedIndices = []
                if(updateBooleanValue){
                    for i in cachedSelectedIndices{
                        selectedIndices.append(i)
                    }
                    for i in updateSelectedIndices {
                        if( !selectedIndices.contains(i) ){
                            selectedIndices.append(i)
                        }
                    }
                } else{
                    for i in cachedSelectedIndices{
                        if( !updateSelectedIndices.contains(i) ){
                            selectedIndices.append(i)
                        }
                    }
                }
                collectionView.reloadData()
            }
        }
    }
}


extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        // 選択済みセルのインデックス情報にこのセルのインデックス情報が含まれている場合、選択状態にする
        if selectedIndices.contains(indexPath.item) {
            cell.selectedCell = true
        } else {
            cell.selectedCell = false
        }
        cell.setLayout(data[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        updateCollectionView(indexPath)
    }
    
    func updateCollectionView(_ indexPath: IndexPath){
        if( selectedIndices.contains(indexPath.item) ){
            selectedIndices.remove(at: selectedIndices.firstIndex(of: indexPath.item)!)
            updateBooleanValue = false
        } else{
            selectedIndices.append(indexPath.item)
            updateBooleanValue = true
        }
        print(updateBooleanValue)
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
}

//スクロールのための関数
extension ViewController{
// 自動スクロールを開始する
    private func startAutoScroll(duration: TimeInterval, direction: String) {
        if isNeedToStartTimer {
            // 表示されているCollectionViewのOffsetを取得
            var currentOffsetY = collectionView.contentOffset.y
            // 自動スクロールを終了させるかどうか
            shouldFinish = false
            autoScrollTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: true, block: { [weak self] (_) in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    // item2つ分ずつスクロールさせる
                    switch direction {
                    case "up":
                        currentOffsetY = (currentOffsetY - 10 < 0) ? 0 : currentOffsetY - 10
                        self.shouldFinish = currentOffsetY == 0
                    case "down":
                        let highLimit = self.collectionView.contentSize.height - self.collectionView.bounds.size.height
                        currentOffsetY = (currentOffsetY + 10 > highLimit) ? highLimit : currentOffsetY + 10
                        self.shouldFinish = currentOffsetY == highLimit
                    default: break
                    }
                    UIView.animate(withDuration: duration, animations: {
                        self.collectionView.setContentOffset(CGPoint(x: 0, y: currentOffsetY), animated: false)
                    }, completion: { _ in
                        if self.shouldFinish { self.stopAutoScrollIfNeeded() }
                    })
                }
            })
        }
        isNeedToStartTimer = false
    }

    // 自動スクロールを停止する
    private func stopAutoScrollIfNeeded() {
        DispatchQueue.main.async {
            self.isNeedToStartTimer = true
            self.shouldFinish = true
            self.view.layer.removeAllAnimations()
            self.autoScrollTimer.invalidate()
        }
    }
}
