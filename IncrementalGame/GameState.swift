//
//  GameState.swift
//  IncrementalGame
//
//  Created by Ben Grande on 2017-10-12.
//  Copyright © 2017 Ben Grande. All rights reserved.
//

import Foundation
import os.log

class GameState: NSObject, NSCoding {
    
    // MARK: Properties
    
    var currencyA: Int;
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("gameState")
    
    struct PropertyKey {
        static let currencyA = "currencyA"
    }
    
    init(_ startingCurrency: Int) {
        self.currencyA = startingCurrency
    }
    
    // MARK: NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The currency is required. If we cannot decode a currency string, the initializer should fail.
        let currencyA = aDecoder.decodeInteger(forKey: PropertyKey.currencyA)
        
        self.init(currencyA)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(currencyA, forKey: PropertyKey.currencyA)
    }
    
    static func saveGameState(_ gameState: GameState) {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(gameState, toFile: GameState.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("GameState successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save GameState...", log: OSLog.default, type: .error)
        }
    }
    
    static func loadGameState() -> GameState?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: GameState.ArchiveURL.path) as? GameState
    }
}
