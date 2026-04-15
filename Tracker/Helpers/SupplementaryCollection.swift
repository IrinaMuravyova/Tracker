//
//  SupplementaryCollection.swift
//  Tracker
//
//  Created by Irina Muravyeva on 06.04.2026.
//

import UIKit

// MARK: - SupplementaryCollectionDelegate
protocol SupplementaryCollectionDelegate: AnyObject {
    func getSelectedDate() -> Date
    func updateCell(with index: IndexPath)
    func showNotAllowFutureDateAlert()
}

// MARK: - SupplementaryCollection
final class SupplementaryCollection: NSObject {
    // MARK: - Static properties
    static let trackerCellIdentifier = "TrackersCell"
    
    // MARK: - Private properties
    private func weekday(from date: Date) -> Weekday {
        let calendar = Calendar.current
        let weekdayNumber = calendar.component(.weekday, from: date)
        let mappedValue = weekdayNumber == 1 ? 7 : weekdayNumber - 1
        return Weekday(rawValue: mappedValue)!
    }
    
    private let params: GeometricParams
    private var categories: [TrackerCategory]
    private var completedTrackers: [TrackerRecord]
    private var trackersFactory: TrackersFactoryProtocol? = TrackersFactory.shared
    
    // MARK: - Public properties
    weak var delegate: SupplementaryCollectionDelegate?
    weak var collectionView: UICollectionView?
    
    // MARK: - Initializes
    init(categories: [TrackerCategory], completedTrackers: [TrackerRecord], using params: GeometricParams) {
        self.categories = categories
        self.completedTrackers = completedTrackers
        self.params = params
    }
    
    // MARK: - Public methods
    func updateData(categories: [TrackerCategory], completed: [TrackerRecord]) {
        self.categories = categories
        self.completedTrackers = completed
    }
    
    // MARK: - Private methods
    private func filteredCategories(for date: Date) -> [TrackerCategory] {
        let currentWeekday = weekday(from: date)
        
        return categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                
                switch tracker.type {
                    
                case .habit:
                    switch tracker.schedule {
                    case .daysOfWeek(let days):
                        return days.contains(currentWeekday)
                    }
                    
                case .irregular:
                    guard let selectedDate = delegate?.getSelectedDate() else { return false }
                    
                    let trackerRecords = completedTrackers.filter { $0.trackerId == tracker.id }
                    
                    if let record = trackerRecords.first {
                        return isOnOrAfter(record.date, selectedDate)
                    } else { return true }
                }
            }
            
            guard !filteredTrackers.isEmpty else { return nil }
            
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
    }
    func isOnOrAfter(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        let d1 = calendar.startOfDay(for: date1)
        let d2 = calendar.startOfDay(for: date2)
        return d1 == d2
    }
}

// MARK: - UICollectionViewDataSource
extension SupplementaryCollection: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        guard let date = delegate?.getSelectedDate() else { return 0 }
        return filteredCategories(for: date)[section].trackers.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let date = delegate?.getSelectedDate() else { return UICollectionViewCell()}
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SupplementaryCollection.trackerCellIdentifier,
            for: indexPath) as! TrackersCell
        
        let filtered = filteredCategories(for: date)
        let tracker = filtered[indexPath.section].trackers[indexPath.row]
        let completedCount = completedTrackers.filter({$0.trackerId == tracker.id}).count
        
        cell.delegate = self
        
        let isDone = !(completedTrackers.filter({
            $0.trackerId == tracker.id
            && Calendar.current.startOfDay(for: $0.date) == Calendar.current.startOfDay(for: date)
        }).first == nil)
        
        cell.configureCell(with: tracker, completedCount: completedCount, isDone: isDone)
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let date = delegate?.getSelectedDate() else { return 0 }
        return filteredCategories(for: date).count
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
        
        guard let date = delegate?.getSelectedDate() else { return UICollectionReusableView()}
        header.configure(title: filteredCategories(for: date)[indexPath.section].title)
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
        UIEdgeInsets(top: 12, left: params.leftInset, bottom: 16, right: params.rightInset)
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

// MARK: - TrackersCellDelegate
extension SupplementaryCollection: TrackersCellDelegate {
    
    func didTapAddButton(in cell: TrackersCell) {
        guard
            let date = delegate?.getSelectedDate(),
            !isFutureDate(date)
        else {
            delegate?.showNotAllowFutureDateAlert()
            return
        }
        
        guard let collectionView,
              let indexPath = collectionView.indexPath(for: cell)
        else { return }
        
        let filtered = filteredCategories(for: date)
        let tracker = filtered[indexPath.section].trackers[indexPath.row]
        
        let isDone = !(completedTrackers.filter({
            $0.trackerId == tracker.id
            && Calendar.current.startOfDay(for: $0.date) == Calendar.current.startOfDay(for:(date))
        }).first == nil)
        
        if isDone {
            deleteTrackerRecord(trackerId: tracker.id)
        } else {
            addTrackerRecord(trackerId: tracker.id)
        }
        
        updateCell(with: indexPath)
    }
    
    private func isFutureDate(_ selectedDate: Date) -> Bool {
        let calendar = Calendar.current
        
        let today = calendar.startOfDay(for: Date())
        let selected = calendar.startOfDay(for: selectedDate)
        
        return selected > today
    }
    
    private func addTrackerRecord(trackerId: UUID) {
        guard let date = delegate?.getSelectedDate() else { return }

        let newRecord = TrackerRecord(trackerId: trackerId, date: date)
        completedTrackers.append(newRecord)
        
        trackersFactory?.trackerRecordsDidUpdated(with: newRecord)
    }
    
    private func deleteTrackerRecord(trackerId: UUID) {
        guard let date = delegate?.getSelectedDate() else { return }
        
        
        let index = completedTrackers.firstIndex(where: {
            $0.trackerId == trackerId
            && Calendar.current.startOfDay(for: $0.date) == Calendar.current.startOfDay(for:date)
        })
        
        guard let index else { return }
        completedTrackers.remove(at: index)
        
        trackersFactory?.trackerRecordDidCanceled(for: trackerId, at: date)
    }
    
    private func updateCell(with indexPath: IndexPath) {
        guard let trackersFactory else { return }
        categories = trackersFactory.getTrackersCategory()
        completedTrackers = trackersFactory.getCompletedTrackers()
        
        delegate?.updateCell(with: indexPath)
    }
}
