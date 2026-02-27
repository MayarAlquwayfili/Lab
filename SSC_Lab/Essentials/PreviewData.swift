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
        
        let chalkArt = Experiment( title: "CHALK ART", icon: "sparkles", environment: "Outdoor", tools: "Required", timeframe: "1D", referenceURL: "https://www.pinterest.com/pin/2955556003410532/", labNotes: "aesthetic chalk stars on the floor! very pinteresty and colorful. Can't wait ! ")
                chalkArt.isActive = true
        
        let experiments = [
            Experiment(title: "COLOR SPRAY", icon: "paintpalette.fill", environment: "Outdoor", tools: "Required", timeframe: "1D", referenceURL: "https://pin.it/spray-art-inspo", labNotes: "wanna try the chaos vibe! let's see how messy it gets haha"),
            Experiment(title: "POTTERY", icon: "hand.raised.fingers.spread.fill", environment: "Outdoor", tools: "Required", timeframe: "1D", referenceURL: "http://keramosksa.com/", labNotes: "making my own cup and drinking from it... actually so exciting."),
            Experiment(title: "VLOG CHANNEL", icon: "video.fill", environment: "Indoor", tools: "None", timeframe: "7D", labNotes: "one of the things I want to do the most. let's do thisss !!"),
            Experiment(title: "CUSTOM HOODIE", icon: "tshirt.fill", environment: "Indoor", tools: "None", timeframe: "7D", referenceURL: "https://www.pinterest.com/pin/814025701438982413/", labNotes: "wanna design my own hoodie with some cool doodles and lyrics."),
            chalkArt,
            Experiment(title: "ANIMATION", icon: "play.square.stack.fill", environment: "Indoor", tools: "None", timeframe: "7D", labNotes: "I want to see my characters move!! Ive the scene in my head, just need the time 4 it..."),
            Experiment(title: "CAKE BAKING", icon: "birthday.cake.fill", environment: "Indoor", tools: "Required", timeframe: "1D", referenceURL: "https://www.pinterest.com/pin/188377196909977691/", labNotes: "I want to bake a cake that actually looks like it’s from a fancy store!")
        ]
        experiments.forEach { context.insert($0) }

        let wins = [
            /// Summer 20 Collection
            Win(title: "BOOKMARK", imageData: img("img_bookmark"), logTypeIcon: "sparkle.magnifyingglass", date: exactDate("16/07/2025"), environment: "house.fill", tools: "hammer.fill", timeframe: "1D", collectionName: "Summer 20", collection: summerColl, notes: "needed a blue bookmark for my new book", icon: "bookmark.fill"),
            Win(title: "ACADEMY ACCEPT", imageData: img("img_academy"), logTypeIcon: "hands.and.sparkles.fill", date: exactDate("08/08/2025"), environment: "mountain.2.fill", tools: "ic_WithoutTools", timeframe: "+30D", collectionName: "Summer 20", collection: summerColl, notes: "a dream come true, i’m so incredibly happy.", icon: "apple.logo"),
            Win(title: "BLENDER", imageData: img("img_blender"), logTypeIcon: "sparkle.magnifyingglass", date: exactDate("13/06/2025"), environment: "house.fill", tools: "ic_WithoutTools", timeframe: "+30D", collectionName: "Summer 20", collection: summerColl, notes: "Finally tried it! the result's actually fire. worth the weeks haha", icon: "cube.transparent.fill"),
            Win(title: "SWIFT", imageData: img("img_swift"), logTypeIcon: "sparkle.magnifyingglass", date: exactDate("16/06/2025"), environment: "house.fill", tools: "ic_WithoutTools", timeframe: "+30D", collectionName: "Summer 20", collection: summerColl, notes: "my first time diving into Swift. still figuring it out but we're officially starting!", icon: "swift"),
            Win(title: "AESTHETIC WALL", imageData: img("img_wall2"), logTypeIcon: "sparkle.magnifyingglass", date: exactDate("21/08/2025"), environment: "house.fill", tools: "hammer.fill", timeframe: "7D", collectionName: "Summer 20", collection: summerColl, notes: "Room makeover! changed the theme to green.", activityID: aestheticWallID, icon: "photo.artframe"),
            Win(title: "BOOK ART", imageData: img("img_bookart"), logTypeIcon: "sparkle.magnifyingglass", date: exactDate("10/08/2025"), environment: "house.fill", tools: "ic_WithoutTools", timeframe: "1D", collectionName: "Summer 20", collection: summerColl, notes: "I usually just scribble notes, but this was my first time actually drawing. my book basically just reaction art now lol", icon: "pencil.line"),
            Win(title: "SUSHI", imageData: img("img_sushi"), logTypeIcon: "hands.and.sparkles.fill", date: exactDate("13/08/2025"), environment: "mountain.2.fill", tools: "ic_WithoutTools", timeframe: "+30D", collectionName: "Summer 20", collection: summerColl, notes: "Finally tried it despite the haters. loved it, so yummy!", icon: "mouth.fill"),
            Win(title: "CROCHET", imageData: img("img_crochet"), logTypeIcon: "sparkle.magnifyingglass", date: exactDate("21/06/2025"), environment: "house.fill", tools: "hammer.fill", timeframe: "7D", collectionName: "Summer 20", collection: summerColl, notes: "Back at it with a full project! made a cute pink mini bag. missed a few stitches but she's still iconic.", icon: "handbag.fill"),
            Win(title: "TIRAMISU", imageData: img("img_tiramisu"), logTypeIcon: "sparkle.magnifyingglass", date: exactDate("18/07/2025"), environment: "house.fill", tools: "hammer.fill", timeframe: "1D", collectionName: "Summer 20", collection: summerColl, notes: "My new addiction. i'm officially famous 4 this recipe now.", icon: "cup.and.saucer.fill"),
            Win(title: "V60 & BERRY", imageData: img("img_v60"), logTypeIcon: "sparkle.magnifyingglass", date: exactDate("11/07/2025"), environment: "house.fill", tools: "hammer.fill", timeframe: "1D", collectionName: "Summer 20", collection: summerColl, notes: "Saw it and had to try!", icon: "takeoutbag.and.cup.and.straw.fill"),

            /// Gazza! Collection
            Win(title: "AESTHETIC WALL", imageData: img("img_wall1"), logTypeIcon: "sparkle.magnifyingglass", date: exactDate("24/07/2023"), environment: "house.fill", tools: "hammer.fill", timeframe: "7D", collectionName: "Gazza!", collection: gazzaColl, notes: "Pinterest vibes for the new house. started with black & beige.", activityID: aestheticWallID, icon: "photo.artframe"),
            Win(title: "SUNRISE", imageData: img("img_sunrise"), logTypeIcon: "sparkle.magnifyingglass", date: exactDate("22/07/2024"), environment: "mountain.2.fill", tools: "ic_WithoutTools", timeframe: "1D", collectionName: "Gazza!", collection: gazzaColl, notes: "I forced my fam to wake up 4 this on vacation.", icon: "sunrise.fill"),
            Win(title: "MATCHA", imageData: img("img_matcha"), logTypeIcon: "sparkle.magnifyingglass", date: exactDate("23/08/2023"), environment: "house.fill", tools: "hammer.fill", timeframe: "1D", collectionName: "Gazza!", collection: gazzaColl, notes: "Hated it a year ago, but I decided to give it one more try. now it's a daily ritual.", icon: "mug"),
            Win(title: "PAPER STARS", imageData: img("img_stars"), logTypeIcon: "sparkle.magnifyingglass", date: exactDate("27/05/2023"), environment: "house.fill", tools: "hammer.fill", timeframe: "1D", collectionName: "Gazza!", collection: gazzaColl, notes: "Was sleepy and bored scrolling pinterest... and ended up with this result!", icon: "star.fill"),
            Win(title: "ONIGIRI", imageData: img("img_onigiri"), logTypeIcon: "hands.and.sparkles.fill", date: exactDate("27/12/2024"), environment: "mountain.2.fill", tools: "ic_WithoutTools", timeframe: "1D", collectionName: "Gazza!", collection: gazzaColl, notes: "Been dying to try this forever...", icon: "triangle.bottomhalf.filled"),
            Win(title: "COOKIE", imageData: img("img_cookie"), logTypeIcon: "sparkle.magnifyingglass", date: exactDate("17/05/2023"), environment: "house.fill", tools: "hammer.fill", timeframe: "1D", collectionName: "Gazza!", collection: gazzaColl, notes: "Finally nailed the recipe! the last attempt was literally inedible, so this is a huge win!!", icon: "suit.heart.fill"),
            Win(title: "CHOCOLATE PUDDING", imageData: img("img_pudding"), logTypeIcon: "hands.and.sparkles.fill", date: exactDate("02/07/2024"), environment: "house.fill", tools: "hammer.fill", timeframe: "1D", collectionName: "Gazza!", collection: gazzaColl, notes: "Everyone’s doing the trend but my recipe definitely wins.", icon: "birthday.cake.fill"),
            Win(title: "TRADING", imageData: img("img_trading"), logTypeIcon: "sparkle.magnifyingglass", date: exactDate("15/06/2023"), environment: "house.fill", tools: "ic_WithoutTools", timeframe: "+30D", collectionName: "Gazza!", collection: gazzaColl, notes: "It was such an incredible experience!", icon: "chart.bar.xaxis.ascending"),
            Win(title: "PAPER TOWER", imageData: img("img_papertower"), logTypeIcon: "hands.and.sparkles.fill", date: exactDate("02/09/2025"), environment: "mountain.2.fill", tools: "ic_WithoutTools", timeframe: "1D", collectionName: "Gazza!", collection: gazzaColl, notes: "I challenged myself to use paper ! it held up until the second book. future architect?", icon: "square.stack.3d.up.fill"),
            Win(title: "MOUSE DRAWING", imageData: img("img_mousedraw"), logTypeIcon: "sparkle.magnifyingglass", date: exactDate("18/12/2025"), environment: "house.fill", tools: "ic_WithoutTools", timeframe: "1D", collectionName: "Gazza!", collection: gazzaColl, notes: "My favorite way to procrastinate... shocked the lines came out so clean with just a mouse.", icon: "computermouse.fill"),
            Win(title: "AQUARIUM", imageData: img("img_aquarium"), logTypeIcon: "hands.and.sparkles.fill", date: exactDate("23/11/2025"), environment: "mountain.2.fill", tools: "ic_WithoutTools", timeframe: "1D", collectionName: "Gazza!", collection: gazzaColl, notes: "I could literally live here !!! Penguin was so adorable", icon: "fish.fill"),
            Win(title: "5AM STARS", imageData: img("img_5am"), logTypeIcon: "sparkle.magnifyingglass", date: exactDate("01/01/2023"), environment: "mountain.2.fill", tools: "ic_WithoutTools", timeframe: "1D", collectionName: "Gazza!", collection: gazzaColl, notes: "", icon: "sparkles"),
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
