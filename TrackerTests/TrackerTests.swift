//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Irina Muravyeva on 26.05.2026.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackersViewControllerTests: XCTestCase {

    func testTrackersViewController() {
        let container = CoreDataContainer()

        let viewModel = TrackerListViewModel(
            container: container
        )

        let vc = TrackersViewController(
            container: container,
            viewModel: viewModel
        )

        let navigationController = UINavigationController(
            rootViewController: vc
        )


        assertSnapshots(
            of: navigationController,
            as: [.image]
        )
//        withSnapshotTesting(record: .all) {
//            assertSnapshots(
//                of: navigationController,
//                as: [.image]
//            )
//        }
    }
}
