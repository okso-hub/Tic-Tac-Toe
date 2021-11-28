//
//  Alerts.swift
//  Tic-Tac-Toe
//
//  Created by Okan Sönmez on 16.05.21.
//

import SwiftUI

struct AlertItem: Identifiable {
    
    let id = UUID()
    var title: Text
    var message: Text
    var buttonTitle: Text
}

struct AlertContext {
    
    static let humanWin = AlertItem(title: Text("Du hast gewonnen!"),
                                    message: Text("Beeindruckend, du hast grade die schlauste KI besiegt!"),
                                    buttonTitle: Text("Erneut spielen"))
    
    static let computerWin = AlertItem(title: Text("Du hast verloren!"),
                                       message: Text("Wie peinlich, du hast grade gegen einen Computer verloren!"),
                                       buttonTitle: Text("Erneut spielen"))
    
    static let draw = AlertItem(title: Text("Unentschieden!"),
                                message: Text("Beeindruckend, du bist auf Augenhöhe mit der KI!"),
                                buttonTitle: Text("Erneut spielen"))
 
    // static let => dadurch kann man das direkt callen (zB: AlertContext.draw(title: , message: , buttonTitle: )
}
