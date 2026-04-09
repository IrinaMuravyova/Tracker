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

protocol SupplementaryCollectionDelegate: AnyObject {
    func getSelectedData() -> Date
//    func getSelectedTrackerId() -> UUID
    func updateCell(with index: IndexPath)
}

final class SupplementaryCollection: NSObject {
    static let trackerCellIdentifier = "TrackersCell"
    
    private let params: GeometricParams
    private var categories: [TrackerCategory]
    private var completedTrackers: [TrackerRecord]
    private var selectedDate = Date()
    private var trackersFactory = TrackersFactory.shared
    
    weak var delegate: SupplementaryCollectionDelegate?
    weak var collectionView: UICollectionView?
    
    init(categories: [TrackerCategory], completedTrackers: [TrackerRecord], using params: GeometricParams) {
        self.categories = categories
        self.completedTrackers = completedTrackers
        self.params = params
    }
}

// MARK: - UICollectionViewDataSource
extension SupplementaryCollection: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        categories[section].trackers.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SupplementaryCollection.trackerCellIdentifier,
            for: indexPath) as! TrackersCell
        
        let tracker = categories[indexPath.section].trackers[indexPath.row]
        let completedCount = completedTrackers.filter({$0.trackerId == tracker.id}).count
        
        cell.delegate = self
        guard let delegate else { return UICollectionViewCell()}
        let isDone = !(completedTrackers.filter({
            $0.trackerId == tracker.id
            && Calendar.current.startOfDay(for: $0.date) == Calendar.current.startOfDay(for:(delegate.getSelectedData()))
        }).first == nil)
   
        cell.configureCell(with: tracker, completedCount: completedCount, isDone: isDone)
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard kind == UICollectionView.elementKindSectionHeader else {
            assertionFailure("[SupplementaryCollection] elementKindSectionHeader has not been implemented")
            return UICollectionReusableView()
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SupplementaryView.reuseHeaderId,
            for: indexPath
        ) as! SupplementaryView
        
        header.configure(title: categories[indexPath.section].title)
        return header
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let header = SupplementaryView(frame: .zero)
        header.configure(title: "пример для расчета высоты")
        
        let targetSize = CGSize(
            width: collectionView.frame.width,
            height: UIView.layoutFittingExpandedSize.height
        )
        
        return header.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
}

extension SupplementaryCollection: TrackersCellDelegate {

    func didTapAddButton(in cell: TrackersCell) {
        guard let collectionView,
              let indexPath = collectionView.indexPath(for: cell),
              let delegate else { return }

        let tracker = categories[indexPath.section].trackers[indexPath.row]
        
        let isDone = !(completedTrackers.filter({
            $0.trackerId == tracker.id
            && Calendar.current.startOfDay(for: $0.date) == Calendar.current.startOfDay(for:(delegate.getSelectedData()))
        }).first == nil)
        
        if isDone {
            deleteTrackerRecord(trackerId: tracker.id)
        } else {
            addTrackerRecord(trackerId: tracker.id)
        }
        
        updateCell(with: indexPath)
    }
    
    private func addTrackerRecord(trackerId: UUID) {
        guard let delegate else { return }
        selectedDate = delegate.getSelectedData()
       
        let newRecord = TrackerRecord(trackerId: trackerId, date: selectedDate)
        completedTrackers.append(newRecord)
        
        trackersFactory.trackerRecordsDidUpdated(with: newRecord)
    }
    
    private func deleteTrackerRecord(trackerId: UUID) {
        guard let delegate else { return }
        selectedDate = delegate.getSelectedData()
        
        let index = completedTrackers.firstIndex(where: {
            $0.trackerId == trackerId
            && Calendar.current.startOfDay(for: $0.date) == Calendar.current.startOfDay(for:(delegate.getSelectedData()))
        })
                                                 
        guard let index else { return }
        completedTrackers.remove(at: index)
        
        trackersFactory.trackerRecordDidCanceled(for: trackerId, at: selectedDate)
    }
    
    private func updateCell(with indexPath: IndexPath) {
        categories = trackersFactory.getTrackersCategory()
        completedTrackers = trackersFactory.getCompletedTrackers()
        
        delegate?.updateCell(with: indexPath)
    }
}


