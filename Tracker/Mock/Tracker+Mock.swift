////
////  Tracker+Mock.swift
////  Tracker
////
////  Created by Irina Muravyeva on 15.04.2026.
////
//
//import Foundation
//
//extension Tracker {
//    static func mock(trackersId: [UUID]) -> [Tracker] {
//        [
//            Tracker(
//                id: trackersId[0],
//                name: "Поливать растение",
//                color: .colorselection5,
//                emoji: "❤️",
//                schedule: TrackerSchedule.daysOfWeek([.monday]),
//                type: .habit
//            ),
//            Tracker(
//                id: trackersId[1],
//                name: "Кошка заслонила камеру на созвоне",
//                color: .colorselection2,
//                emoji: "😻",
//                schedule: TrackerSchedule.daysOfWeek([.tuesday]),
//                type: .habit
//            ),
//            Tracker(
//                id: trackersId[2],
//                name: "Бабушка прислала открытку в ватсапе",
//                color: .colorselection1,
//                emoji: "🌺",
//                schedule: TrackerSchedule.daysOfWeek([.monday, .thursday]),
//                type: .habit
//            ),
//            Tracker(
//                id: trackersId[3],
//                name: "Свидание в апреле",
//                color: .colorselection14,
//                emoji: "❤️",
//                schedule: TrackerSchedule.daysOfWeek([.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]),
//                type: .habit
//            ),
//            Tracker(
//                id: trackersId[4],
//                name: "Сдать проект",
//                color: .colorselection14,
//                emoji: "❤️",
//                schedule: TrackerSchedule.daysOfWeek([]),
//                type: .irregular
//            )
//        ]
//    }
//    
//    static func mockId() -> [UUID] {
//        [
//            UUID(uuidString: "F8A3AFEF-0D47-4EBF-8070-D8DC1D119D04")!,
//            UUID(uuidString: "107C3003-CAC0-4299-B468-B05AB3F6675D")!,
//            UUID(uuidString: "7C072853-EF2D-4EF0-A10D-6EE73339CDC8")!,
//            UUID(uuidString: "CD4E5590-C456-4ABB-91BA-C95D76250DE5")!,
//            UUID(uuidString: "A3F1C2B4-9D6E-4C8A-8F12-7E5B3D91A6C0")!
//        ]
//    }
//}
