//
//  HKNameDictionary.swift
//  geo-activist
//
//  Created by 鎌田遼 on 2020/01/07.
//  Copyright © 2020 鎌田遼. All rights reserved.
//

import HealthKit

struct HKNameDictionary {
    static public func get() -> Dictionary<UInt, (en: String, ja: String)> {
        var dictionary: Dictionary<UInt, (en: String, ja: String)> = [:]
        dictionary[HKWorkoutActivityType.archery.rawValue] = (en: "archery", ja: "アーチェリー")
        dictionary[HKWorkoutActivityType.bowling.rawValue] = (en: "bowling", ja: "ボウリング")
        dictionary[HKWorkoutActivityType.fencing.rawValue] = (en: "fencing", ja: "フェンシング")
        dictionary[HKWorkoutActivityType.gymnastics.rawValue] = (en: "gymnastics", ja: "ジムナスティック")
        dictionary[HKWorkoutActivityType.trackAndField.rawValue] = (en: "trackAndField", ja: "トラックアンドフィールド")
        dictionary[HKWorkoutActivityType.americanFootball.rawValue] = (en: "americanFootball", ja: "アメリカンフットボール")
        dictionary[HKWorkoutActivityType.australianFootball.rawValue] = (en: "australianFootball", ja: "オーストラリアンフットボール")
        dictionary[HKWorkoutActivityType.baseball.rawValue] = (en: "baseball", ja: "ベースボール")
        dictionary[HKWorkoutActivityType.basketball.rawValue] = (en: "basketball", ja: "バスケットボール")
        dictionary[HKWorkoutActivityType.cricket.rawValue] = (en: "cricket", ja: "クリケット")
        dictionary[HKWorkoutActivityType.discSports.rawValue] = (en: "discSports", ja: "ディスクスポーツ")
        dictionary[HKWorkoutActivityType.handball.rawValue] = (en: "handball", ja: "ハンドボール")
        dictionary[HKWorkoutActivityType.hockey.rawValue] = (en: "hockey", ja: "ホッケー")
        dictionary[HKWorkoutActivityType.lacrosse.rawValue] = (en: "lacrosse", ja: "ラクロス")
        dictionary[HKWorkoutActivityType.rugby.rawValue] = (en: "rugby", ja: "ラグビー")
        dictionary[HKWorkoutActivityType.soccer.rawValue] = (en: "soccer", ja: "サッカー")
        dictionary[HKWorkoutActivityType.softball.rawValue] = (en: "softball", ja: "ソフトボール")
        dictionary[HKWorkoutActivityType.volleyball.rawValue] = (en: "volleyball", ja: "バレーボール")
        dictionary[HKWorkoutActivityType.preparationAndRecovery.rawValue] = (en: "preparationAndRecovery", ja: "")
        dictionary[HKWorkoutActivityType.flexibility.rawValue] = (en: "flexibility", ja: "柔軟")
        dictionary[HKWorkoutActivityType.walking.rawValue] = (en: "walking", ja: "ウォーキング")
        dictionary[HKWorkoutActivityType.running.rawValue] = (en: "running", ja: "ランニング")
        dictionary[HKWorkoutActivityType.wheelchairWalkPace.rawValue] = (en: "wheelchairWalkPace", ja: "")
        dictionary[HKWorkoutActivityType.wheelchairRunPace.rawValue] = (en: "wheelchairRunPace", ja: "")
        dictionary[HKWorkoutActivityType.cycling.rawValue] = (en: "cycling", ja: "サイクリング")
        dictionary[HKWorkoutActivityType.handCycling.rawValue] = (en: "handCycling", ja: "")
        dictionary[HKWorkoutActivityType.coreTraining.rawValue] = (en: "coreTraining", ja: "")
        dictionary[HKWorkoutActivityType.elliptical.rawValue] = (en: "elliptical", ja: "エリプティカル")
        dictionary[HKWorkoutActivityType.functionalStrengthTraining.rawValue] = (en: "functionalStrengthTraining", ja: "機能的筋力トレーニング")
        dictionary[HKWorkoutActivityType.traditionalStrengthTraining.rawValue] = (en: "traditionalStrengthTraining", ja: "伝統的筋力トレーニング")
        dictionary[HKWorkoutActivityType.crossTraining.rawValue] = (en: "crossTraining", ja: "クロストレーニング")
        dictionary[HKWorkoutActivityType.mixedCardio.rawValue] = (en: "mixedCardio", ja: "複合カーディオトレーニング")
        dictionary[HKWorkoutActivityType.highIntensityIntervalTraining.rawValue] = (en: "highIntensityIntervalTraining", ja: "高強度インターバルトレーニング")
        dictionary[HKWorkoutActivityType.jumpRope.rawValue] = (en: "jumpRope", ja: "ジャンプロープ")
        dictionary[HKWorkoutActivityType.stairClimbing.rawValue] = (en: "stairClimbing", ja: "ステアクライミング")
        dictionary[HKWorkoutActivityType.stairs.rawValue] = (en: "stairs", ja: "ステア")
        dictionary[HKWorkoutActivityType.stepTraining.rawValue] = (en: "stepTraining", ja: "階段昇降")
        dictionary[HKWorkoutActivityType.fitnessGaming.rawValue] = (en: "fitnessGaming", ja: "フィットネスゲーミング")
        dictionary[HKWorkoutActivityType.barre.rawValue] = (en: "barre", ja: "バレー")
        dictionary[HKWorkoutActivityType.dance.rawValue] = (en: "dance", ja: "ダンス")
        dictionary[HKWorkoutActivityType.yoga.rawValue] = (en: "yoga", ja: "ヨガ")
        dictionary[HKWorkoutActivityType.mindAndBody.rawValue] = (en: "mindAndBody", ja: "マインドアンドボディ")
        dictionary[HKWorkoutActivityType.pilates.rawValue] = (en: "pilates", ja: "")
        dictionary[HKWorkoutActivityType.badminton.rawValue] = (en: "badminton", ja: "バドミントン")
        dictionary[HKWorkoutActivityType.racquetball.rawValue] = (en: "racquetball", ja: "ラケットボール")
        dictionary[HKWorkoutActivityType.squash.rawValue] = (en: "squash", ja: "スカッシュ")
        dictionary[HKWorkoutActivityType.tableTennis.rawValue] = (en: "tableTennis", ja: "卓球")
        dictionary[HKWorkoutActivityType.tennis.rawValue] = (en: "tennis", ja: "テニス")
        dictionary[HKWorkoutActivityType.climbing.rawValue] = (en: "climbing", ja: "クライミング")
        dictionary[HKWorkoutActivityType.equestrianSports.rawValue] = (en: "equestrianSports", ja: "")
        dictionary[HKWorkoutActivityType.fishing.rawValue] = (en: "fishing", ja: "釣り")
        dictionary[HKWorkoutActivityType.golf.rawValue] = (en: "golf", ja: "ゴルフ")
        dictionary[HKWorkoutActivityType.hiking.rawValue] = (en: "hiking", ja: "ハイキング")
        dictionary[HKWorkoutActivityType.hunting.rawValue] = (en: "hunting", ja: "ハンティング")
        dictionary[HKWorkoutActivityType.play.rawValue] = (en: "play", ja: "遊び")
        dictionary[HKWorkoutActivityType.crossCountrySkiing.rawValue] = (en: "crossCountrySkiing", ja: "クロスカントリースキー")
        dictionary[HKWorkoutActivityType.curling.rawValue] = (en: "curling", ja: "カーリング")
        dictionary[HKWorkoutActivityType.downhillSkiing.rawValue] = (en: "downhillSkiing", ja: "ダウンヒルスキー")
        dictionary[HKWorkoutActivityType.snowSports.rawValue] = (en: "snowSports", ja: "スノースポーツ")
        dictionary[HKWorkoutActivityType.snowboarding.rawValue] = (en: "snowboarding", ja: "スノーボード")
        dictionary[HKWorkoutActivityType.skatingSports.rawValue] = (en: "skatingSports", ja: "スケート")
        dictionary[HKWorkoutActivityType.paddleSports.rawValue] = (en: "paddleSports", ja: "パドルスポーツ")
        dictionary[HKWorkoutActivityType.rowing.rawValue] = (en: "rowing", ja: "ローイング")
        dictionary[HKWorkoutActivityType.sailing.rawValue] = (en: "sailing", ja: "セーリング")
        dictionary[HKWorkoutActivityType.surfingSports.rawValue] = (en: "surfingSports", ja: "サーフィン")
        dictionary[HKWorkoutActivityType.swimming.rawValue] = (en: "swimming", ja: "水泳")
        dictionary[HKWorkoutActivityType.waterFitness.rawValue] = (en: "waterFitness", ja: "ウォーターフィットネス")
        dictionary[HKWorkoutActivityType.waterPolo.rawValue] = (en: "waterPolo", ja: "水球")
        dictionary[HKWorkoutActivityType.waterSports.rawValue] = (en: "waterSports", ja: "ウォータースポーツ")
        dictionary[HKWorkoutActivityType.boxing.rawValue] = (en: "boxing", ja: "ボクシング")
        dictionary[HKWorkoutActivityType.kickboxing.rawValue] = (en: "kickboxing", ja: "キックボクシング")
        dictionary[HKWorkoutActivityType.martialArts.rawValue] = (en: "martialArts", ja: "マーシャルアーツ")
        dictionary[HKWorkoutActivityType.taiChi.rawValue] = (en: "taiChi", ja: "太極拳")
        dictionary[HKWorkoutActivityType.wrestling.rawValue] = (en: "wrestling", ja: "レスリング")
        dictionary[HKWorkoutActivityType.other.rawValue] = (en: "other", ja: "その他")
        // deprecated
//        dictionary[HKWorkoutActivityType.danceInspiredTraining.rawValue] = (en: "danceInspiredTraining", ja: "")
//        dictionary[HKWorkoutActivityType.mixedMetabolicCardioTraining.rawValue] = (en: "mixedMetabolicCardioTraining", ja: "")
        return dictionary
    }
}
