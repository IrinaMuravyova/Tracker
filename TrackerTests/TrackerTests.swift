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

    func testTrackersViewControllerLight() {
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
            as: [.image(traits: .init(userInterfaceStyle: .light))]
        )
//        withSnapshotTesting(record: .all) {
//            assertSnapshots(
//                of: navigationController,
//                as: [.image(traits: .init(userInterfaceStyle: .light))]
//            )
//        }
    }
    
    func testTrackersViewControllerDark() {
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
            as: [.image(traits: .init(userInterfaceStyle: .dark))]
        )
//        withSnapshotTesting(record: .all) {
//            assertSnapshots(
//                of: navigationController,
//                as: [.image(traits: .init(userInterfaceStyle: .dark))]
//            )
//        }
    }
}
