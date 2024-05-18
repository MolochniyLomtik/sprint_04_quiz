import Foundation

final class StatisticServiceImplementation: StatisticService {
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    
    func store(correct count: Int, total amount: Int) {
        let newGameRecord = GameRecord(correct: count, total: amount, date: Date())
        
        let currentBestGame = bestGame
        if count >= currentBestGame.correct {
            userDefaults.set(try? JSONEncoder().encode(newGameRecord), forKey: Keys.bestGame.rawValue)
        }
        
        let totalCorrect = userDefaults.integer(forKey: Keys.correct.rawValue) + count
        userDefaults.set(totalCorrect, forKey: Keys.correct.rawValue)
        
        let totalQuestions = userDefaults.integer(forKey: Keys.total.rawValue) + amount
        userDefaults.set(totalQuestions, forKey: Keys.total.rawValue)
        
        let gamesCount = userDefaults.integer(forKey: Keys.gamesCount.rawValue) + 1
        userDefaults.set(gamesCount, forKey: Keys.gamesCount.rawValue)
    }
    
    
    var totalAccuracy: Double {
        let totalCorrect = userDefaults.integer(forKey: Keys.correct.rawValue)
        let totalQuestions = userDefaults.integer(forKey: Keys.total.rawValue)
        return totalQuestions > 0 ? Double(totalCorrect) / Double(totalQuestions) : 0
    }
    
    var gamesCount: Int {
        return userDefaults.integer(forKey: Keys.gamesCount.rawValue)
    }
    
    var bestGame: GameRecord {
        guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
              let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
            return GameRecord(correct: 0, total: 0, date: Date())
        }
        return record
    }
}
