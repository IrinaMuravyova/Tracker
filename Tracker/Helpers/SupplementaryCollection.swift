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
    private let params: GeometricParams
    private let container: CoreDataContainer
    private let viewModel: TrackerListUIModel
    
    // MARK: - Public properties
    weak var delegate: SupplementaryCollectionDelegate?
    weak var collectionView: UICollectionView?
    
    // MARK: - Initializes
    init(using params: GeometricParams, container: CoreDataContainer, viewModel: TrackerListUIModel) {
        self.params = params
        self.container = container
        self.viewModel = viewModel
    }
    
    // MARK: - Public methods
    func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        let d1 = calendar.startOfDay(for: date1)
        let d2 = calendar.startOfDay(for: date2)
        return d1 == d2
    }
}

// MARK: - UICollectionViewDataSource
extension SupplementaryCollection: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.sections.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        viewModel.sections[section].trackers.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SupplementaryCollection.trackerCellIdentifier,
            for: indexPath
        ) as? TrackersCell else {
            assertionFailure("[SupplementaryCollection] Failed to attach dequeueReusableCell к TrackersCell")
            return UICollectionViewCell()
        }

        let vm = viewModel.sections[indexPath.section].trackers[indexPath.row]

        cell.delegate = self
        
        cell.configureCell(
            with: vm,
            completedCount: vm.completedCount,
            isDone: vm.isDoneToday
        )

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }

        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SupplementaryView.reuseHeaderId,
            for: indexPath
        )
        
        guard let header = header as? SupplementaryView else {
            assertionFailure("[SupplementaryCollection] Failed to attach UICollectionReusableView к SupplementaryView")
            return UICollectionReusableView()
        }

        let title = viewModel.sections[indexPath.section].title
        header.configure(title: title)

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
        guard let indexPath = collectionView?.indexPath(for: cell)
        else { return }

        viewModel.toggleTracker(at: indexPath)
    }
}
