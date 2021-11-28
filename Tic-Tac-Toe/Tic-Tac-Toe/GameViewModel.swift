//
//  GameViewModel.swift
//  Tic-Tac-Toe
//
//  Created by Okan Sönmez on 21.05.21.
//

import SwiftUI

// Here is where non UI-based things happen (funcitons, if...) "business"

final class GameViewModel: ObservableObject {
    
    let columns: [GridItem] = [GridItem(.flexible()),
                               GridItem(.flexible()),
                               GridItem(.flexible())]
    
    @Published var moves: [Move?] = Array(repeating: nil, count: 9)
    @Published var isGameboardDisabled = false
    @Published var alertItem: AlertItem?
 
    func processPlayerMove(for position: Int) {
        
        // human move
        if isSquareOccupied(in: moves, forIndex: position) { return } // falls Feld besetzt ist, stopp (nicht anklickbar)
        
        moves[position] = Move(player: .human , boardIndex: position)
        
        // check for win condition HUMAN
        if checkWinCondition(for: .human, in: moves) {
            alertItem = AlertContext.humanWin
            return // so that nothing happens after that
        }
        
        // check for draw condition HUMAN
        if checkForDraw(in: moves) {
            alertItem = AlertContext.draw
            return // so that nothing happens after that
        }
        
        isGameboardDisabled = true // so lange der Computer spielt, kann nichts gedrückt werden
        
        // computer move
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in // verzögerung um 0.5sek
            let computerPosition = determineComputerMovePosition(in: moves) // welches Feld soll besetzt werden?
            moves[computerPosition] = Move(player: .computer , boardIndex: computerPosition) // Festlegen: Zug bei der computerPosition || von computer auf der Position computerPosition
            
            isGameboardDisabled = false // wenn der Computer gespielt hat, kann wieder gedrückt werden
            
            // check for win condition COMPUTER
            if checkWinCondition(for: .computer, in: moves) {
                alertItem = AlertContext.computerWin
                return // so that nothing happens after that
            }
            // check for draw condition COMPUTER
            if checkForDraw(in: moves) {
                alertItem = AlertContext.draw
                return // so that nothing happens after that
            }
        }
    }
    
    func isSquareOccupied(in moves: [Move?], forIndex index: Int) -> Bool {
        return moves.contains(where: { $0?.boardIndex == index}) // falls Feld besetzt ist, true || Sonst (Feld nicht besetzt?) false
    }
    
    // 1) If AI can win, then win
    // 2) If AI can't win but Player can, then block
    // 3) If AI can't block, then take middle square -> strategically
    // 4) If AI can't take middle square, then random available square
    func determineComputerMovePosition(in moves: [Move?]) -> Int { // wohin der Computer spielen soll
        
        // MARK:- 1) If AI can win, then win
        let winPatterns: Set<Set<Int>> = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]] // Kombinationen für einen Sieg
        
        let computerMoves = moves.compactMap({ $0 }).filter({ $0.player == .computer }) // Löscht alle nils / filtert alle computermoves
        let computerPositions = Set(computerMoves.map({ $0.boardIndex })) // trägt alle positionen von .computer zusammen
        
        for pattern in winPatterns {
            let winPositions = pattern.subtracting(computerPositions) // zieht die .human Positionen aus jedem winPattern ab; zB: [0, 1, 2] - 0 & 1 -> [2]
            
            if winPositions.count == 1 {
                // falls nurnoch ein Feld zum Sieg benötigt wird, win
                let isAvailable = !isSquareOccupied(in: moves, forIndex: winPositions.first!) // falls das Feld frei ist (nicht besetzt) -> isAvailable
                if isAvailable { return winPositions.first! } // return die Position für den Win
            }
        }
        
        // MARK:- 2) If AI can't win but Player can, then block
        let humanMoves = moves.compactMap({ $0 }).filter({ $0.player == .human }) // Filtert für alle human moves
        let humanPositions = Set(humanMoves.map({ $0.boardIndex })) // trägt alle positionen von .human zusammen
        
        for pattern in winPatterns {
            let winPositions = pattern.subtracting(humanPositions) // zieht die human position aus JEDEM winPattern ab; zB [3, 4, 5] - 3 & 4 -> [5]
            
            if winPositions.count == 1 {
                // falls dem human nurnoch ein Feld fehlt, gehe auf das Feld
                let isAvailable = !isSquareOccupied(in: moves, forIndex: winPositions.first!)
                if isAvailable { return winPositions.first! }
            }
        }
        
        // MARK:- 3) If AI can't block, then take middle square -> strategically
        let centerSquare = 4 // mittleres Feld
        if !isSquareOccupied(in: moves, forIndex: centerSquare) {
            // Falls das mittlere Feld nicht besetzt ist, gehe auf das mittlere Feld
            return centerSquare
        }
        
        // MARK:- 4) If AI can't take middle square, then take random available square
        var movePosition = Int.random(in: 0..<9) // random zahl von 0-8 (steht für die Felder)
        
        while isSquareOccupied(in: moves, forIndex: movePosition) {
            // Während das mittlere Feld besetzt ist, nimm irgendein anderes Feld, bis ein freies gefunden wurde
            movePosition = Int.random(in: 0..<9)
        }
        
        return movePosition 
    }
    
    func checkWinCondition(for player: Player, in moves: [Move?]) -> Bool {
        let winPatterns: Set<Set<Int>> = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]] // <- KOMBINATIONEN FueR EINEN WIN
        
        let playerMoves = moves.compactMap({ $0 }).filter({ $0.player == player }) // COMPACTMAP löscht alle nils, sodass nurnoch moves vorhanden sind || Filtert nach playermoves (human/coputer)
        let playerPositions = Set(playerMoves.map({ $0.boardIndex })) // sucht, ob eine win condition (aus winPatterns) vorliegt
        
        for pattern in winPatterns where pattern.isSubset(of: playerPositions) { return true } // sucht nach den winConditions und returnd true
        
        return false // falls keine vorliegt -> return false
    }
    
    func checkForDraw(in moves: [Move?]) -> Bool {
        return moves.compactMap { $0 }.count == 9 // falls 9 mal gespielt wurde ohne win -> unentschieden (true) || sonst false
    }
    func resetGame() {
        moves = Array(repeating: nil, count: 9) // alle moves (Züge) entfernen
    }
}
