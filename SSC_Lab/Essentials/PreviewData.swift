//
//  PreviewData.swift
//  Lab
//

import Foundation
import SwiftData
import UIKit

struct SampleData {
    static func insertSampleData(context: ModelContext) {
        let storageKey = "isSampleDataInserted_v1"
        
        guard !UserDefaults.standard.bool(forKey: storageKey) else { return }

        let aestheticWallID = UUID()
        
        let summerColl = WinCollection(name: "Summer 20")
        let gazzaColl = WinCollection(name: "Gazza!")
        [summerColl, gazzaColl].forEach { context.insert($0) }
        
    /// TODO: Add Note and Date !!
        let experiments = [
            Experiment(title: "COLOR SPRAY", icon: "paintpalette.fill", environment: "Outdoor", tools: "Required", timeframe: "1D", referenceURL: "https://pin.it/spray-art-inspo", labNotes: "Testing layering techniques."),
            Experiment(title: "POTTERY", icon: "hand.raised.fingers.spread.fill", environment: "Outdoor", tools: "Required", timeframe: "1D", referenceURL: "http://keramosksa.com/", labNotes: "Focusing on centering the clay."),
            Experiment(title: "SWIFT CHALLENGE", icon: "swift", environment: "Indoor", tools: "Required", timeframe: "+30D", referenceURL: "https://developer.apple.com/swift-student-challenge/", labNotes: "Finalizing RECLAB project.", isActive: true, activatedAt: .now),
            Experiment(title: "VLOG CHANNEL", icon: "video.fill", environment: "Indoor", tools: "None", timeframe: "7D", labNotes: "Planning Academy Vlogs."),
            Experiment(title: "ANIMATION", icon: "play.square.stack.fill", environment: "Indoor", tools: "None", timeframe: "7D", labNotes: "Practicing the 12 principles.")
        ]
        experiments.forEach { context.insert($0) }

        let wins = [
            Win(title: "BOOKMARK", imageData: img("img_bookmark"), logTypeIcon: "sparkle.magnifyingglass", date: exactDate("15/06/2025"), environment: "house.fill", tools: "hammer.fill", timeframe: "1D", collectionName: "Summer 20", collection: summerColl, notes: "New Interest...", icon: "bookmark.fill"),
            Win(title: "ACADEMY ACCEPT", imageData: img("img_academy"), logTypeIcon: "hands.and.sparkles.fill", date: exactDate("24/08/2025"), environment: "mountain.2.fill", tools: "ic_WithoutTools", timeframe: "+30D", collectionName: "Summer 20", collection: summerColl, notes: "One time...", icon: "apple.logo"),
            Win(title: "BLENDER", imageData: img("img_blender"), logTypeIcon: "sparkle.magnifyingglass", date: exactDate("05/09/2025"), environment: "house.fill", tools: "ic_WithoutTools", timeframe: "+30D", collectionName: "Summer 20", collection: summerColl, notes: "New Interest...", icon: "cube.transparent.fill"),
            Win(title: "SWIFT", imageData: img("img_swift"), logTypeIcon: "sparkle.magnifyingglass", date: exactDate("10/09/2025"), environment: "house.fill", tools: "ic_WithoutTools", timeframe: "+30D", collectionName: "Summer 20", collection: summerColl, notes: "New Interest...", icon: "swift"),
            Win(title: "AESTHETIC WALL", imageData: img("img_wall1"), logTypeIcon: "sparkle.magnifyingglass", date: exactDate("15/09/2025"), environment: "house.fill", tools: "hammer.fill", timeframe: "7D", collectionName: "Summer 20", collection: summerColl, notes: "First Attempt...", activityID: aestheticWallID, icon: "photo.artframe"),
            Win(title: "AESTHETIC WALL", imageData: img("img_wall2"), logTypeIcon: "sparkle.magnifyingglass", date: exactDate("22/09/2025"), environment: "house.fill", tools: "hammer.fill", timeframe: "7D", collectionName: "Summer 20", collection: summerColl, notes: "Second Attempt...", activityID: aestheticWallID, icon: "photo.artframe"),
            Win(title: "BOOK ART", imageData: img("img_bookart"), logTypeIcon: "sparkle.magnifyingglass", date: exactDate("01/10/2025"), environment: "house.fill", tools: "ic_WithoutTools", timeframe: "1D", collectionName: "Summer 20", collection: summerColl, notes: "New Interest...", icon: "pencil.line"),
            Win(title: "SUSHI", imageData: img("img_sushi"), logTypeIcon: "hands.and.sparkles.fill", date: exactDate("05/10/2025"), environment: "mountain.2.fill", tools: "ic_WithoutTools", timeframe: "+30D", collectionName: "Summer 20", collection: summerColl, notes: "One time...", icon: "mouth.fill"),
            Win(title: "CROCHET", imageData: img("img_crochet"), logTypeIcon: "sparkle.magnifyingglass", date: exactDate("12/10/2025"), environment: "house.fill", tools: "hammer.fill", timeframe: "7D", collectionName: "Summer 20", collection: summerColl, notes: "New Interest...", icon: "handbag.fill"),
            Win(title: "TIRAMISU", imageData: img("img_tiramisu"), logTypeIcon: "sparkle.magnifyingglass", date: exactDate("20/10/2025"), environment: "house.fill", tools: "hammer.fill", timeframe: "1D", collectionName: "Summer 20", collection: summerColl, notes: "New Interest...", icon: "cup.and.saucer.fill"),
            Win(title: "SUNRISE", imageData: img("img_sunrise"), logTypeIcon: "sparkle.magnifyingglass", date: exactDate("30/10/2025"), environment: "mountain.2.fill", tools: "ic_WithoutTools", timeframe: "1D", collectionName: "Summer 20", collection: summerColl, notes: "New Interest...", icon: "sunrise.fill"),
            Win(title: "MATCHA", imageData: img("img_matcha"), logTypeIcon: "sparkle.magnifyingglass", date: exactDate("05/11/2025"), environment: "house.fill", tools: "hammer.fill", timeframe: "1D", collectionName: "Summer 20", collection: summerColl, notes: "New Interest...", icon: "mug"),

            Win(title: "PAPER STARS", imageData: img("img_stars"), logTypeIcon: "sparkle.magnifyingglass", date: exactDate("15/11/2025"), environment: "house.fill", tools: "hammer.fill", timeframe: "1D", collectionName: "Gazza!", collection: gazzaColl, notes: "New Interest...", icon: "star.fill"),
            Win(title: "ONIGIRI", imageData: img("img_onigiri"), logTypeIcon: "hands.and.sparkles.fill", date: exactDate("20/11/2025"), environment: "mountain.2.fill", tools: "ic_WithoutTools", timeframe: "1D", collectionName: "Gazza!", collection: gazzaColl, notes: "One time...", icon: "triangle.bottomhalf.filled"),
            Win(title: "COOKIE", imageData: img("img_cookie"), logTypeIcon: "sparkle.magnifyingglass", date: exactDate("01/12/2025"), environment: "house.fill", tools: "hammer.fill", timeframe: "1D", collectionName: "Gazza!", collection: gazzaColl, notes: "New Interest...", icon: "suit.heart.fill"),
            Win(title: "CHOCOLATE PUDDING", imageData: img("img_pudding"), logTypeIcon: "hands.and.sparkles.fill", date: exactDate("15/12/2025"), environment: "house.fill", tools: "hammer.fill", timeframe: "1D", collectionName: "Gazza!", collection: gazzaColl, notes: "New Interest...", icon: "birthday.cake.fill"),
            Win(title: "TRADING", imageData: img("img_trading"), logTypeIcon: "sparkle.magnifyingglass", date: exactDate("10/01/2026"), environment: "house.fill", tools: "hammer.fill", timeframe: "+30D", collectionName: "Gazza!", collection: gazzaColl, notes: "New Interest...", icon: "chart.bar.xaxis.ascending"),
            Win(title: "PAPER TOWER", imageData: img("img_papertower"), logTypeIcon: "hands.and.sparkles.fill", date: exactDate("05/02/2026"), environment: "mountain.2.fill", tools: "ic_WithoutTools", timeframe: "1D", collectionName: "Gazza!", collection: gazzaColl, notes: "One time...", icon: "square.stack.3d.up.fill"),
            Win(title: "MOUSE DRAWING", imageData: img("img_mousedraw"), logTypeIcon: "sparkle.magnifyingglass", date: exactDate("25/01/2026"), environment: "house.fill", tools: "ic_WithoutTools", timeframe: "1D", collectionName: "Gazza!", collection: gazzaColl, notes: "New Interest...", icon: "computermouse.fill"),
            Win(title: "V60 & BERRY", imageData: img("img_v60"), logTypeIcon: "sparkle.magnifyingglass", date: exactDate("28/01/2026"), environment: "house.fill", tools: "hammer.fill", timeframe: "1D", collectionName: "Gazza!", collection: gazzaColl, notes: "New Interest...", icon: "takeoutbag.and.cup.and.straw.fill"),
            Win(title: "AQUARIUM", imageData: img("img_aquarium"), logTypeIcon: "hands.and.sparkles.fill", date: exactDate("30/01/2026"), environment: "mountain.2.fill", tools: "ic_WithoutTools", timeframe: "1D", collectionName: "Gazza!", collection: gazzaColl, notes: "One time...", icon: "fish.fill"),
            Win(title: "5AM STARS", imageData: img("img_5am"), logTypeIcon: "sparkle.magnifyingglass", date: exactDate("15/02/2026"), environment: "mountain.2.fill", tools: "ic_WithoutTools", timeframe: "1D", collectionName: "Gazza!", collection: gazzaColl, notes: "New Interest...", icon: "sparkles"),
        ]
        
        wins.forEach { context.insert($0) }
        
        try? context.save()
        context.processPendingChanges()
        UserDefaults.standard.set(true, forKey: storageKey)
    }

    private static func img(_ name: String) -> Data? {
        return UIImage(named: name)?.jpegData(compressionQuality: 0.8)
    }

    private static func exactDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.date(from: dateString) ?? .now
    }
}
