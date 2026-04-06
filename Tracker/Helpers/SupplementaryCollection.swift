//
//  SupplementaryCollection.swift
//  Tracker
//
//  Created by Irina Muravyeva on 06.04.2026.
//

import UIKit

struct GeometricParams {
    let cellCount: Int
    let leftInset: CGFloat
    let rightInset: CGFloat
    let cellSpacing: CGFloat
    let paddingWidth: CGFloat
    
    init(cellCount: Int, leftInset: CGFloat, rightInset: CGFloat, cellSpacing: CGFloat) {
        self.cellCount = cellCount
        self.leftInset = leftInset
        self.rightInset = rightInset
        self.cellSpacing = cellSpacing
        self.paddingWidth = leftInset + rightInset + CGFloat(cellCount - 1) * cellSpacing
    }
}

final class SupplementaryCollection: NSObject {
    static let trackerCellIdentifier = "TrackersCell"
    
    private let params: GeometricParams
    
    let count: Int
    
    init(count: Int, using params: GeometricParams) {
        self.count = count
        self.params = params
    }
}

// MARK: - UICollectionViewDataSource
extension SupplementaryCollection: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SupplementaryCollection.trackerCellIdentifier,
            for: indexPath) as! TrackersCell
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SupplementaryCollection: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth =  availableWidth / CGFloat(params.cellCount)
        return CGSize(width: cellWidth, height:150)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        params.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 16, left: params.leftInset, bottom: 16, right: params.rightInset)
    }
}
