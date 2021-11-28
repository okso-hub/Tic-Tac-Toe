//
//  GameView.swift
//  Tic-Tac-Toe
//
//  Created by Okan Sönmez on 13.05.21.
//

import SwiftUI

struct GameView: View {
    
    @StateObject private var viewModel = GameViewModel()
    
    var body: some View {

        GeometryReader { geometry in
            VStack {
                Spacer()
                Text("Tic Tac Toe")
                    .font(.system(size: 55, weight: .bold, design: .default))
                Text("programmiert von Okan Sönmez")
                    .font(.system(size: 21, weight: .light, design: .default))
                Spacer()
                LazyVGrid(columns: viewModel.columns, spacing: 5) {
                    ForEach(0..<9) { i in // 0 up until BUT NOT INCLUDING 9
                        ZStack {
                            GameSquareView(proxy: geometry)
                            PlayerIndicator(systemImageName: viewModel.moves[i]?.indicator ?? "")
                        }
                        .onTapGesture {
                            viewModel.processPlayerMove(for: i)
                        }
                    }
                }
                Spacer()
            }
            
        }
        .disabled(viewModel.isGameboardDisabled)
        .padding()
        .alert(item: $viewModel.alertItem, content: { alertItem in
            Alert(title: alertItem.title,
                  message: alertItem.message,
                  dismissButton: .default(alertItem.buttonTitle, action: { viewModel.resetGame() }))
        })
        
    }
}

enum Player {
    case human, computer
}

struct Move {
    let player: Player // welcher Spieler?
    let boardIndex: Int // welche Stelle?
    
    var indicator: String {
        return player == .human ? "xmark" : "circle" // mensch? => X || computer? => O
    } // Sonne: sun.max | Mond: moon || Ameise: "ant" || Schildröte: "tortoise" || Apple Logo: "applelogo" || Herz: suit.heartsf
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
        
    }
}

struct GameSquareView: View {
    
    var proxy: GeometryProxy
    
    var body: some View {
        // MARK: GAMEBOARD
        Circle()
            .foregroundColor(.blue).opacity(0.5)
            .frame(width: proxy.size.width/3 - 15,
                   height: proxy.size.width/3 - 15)
    }
}

struct PlayerIndicator: View {
    
    var systemImageName: String
    var body: some View {
        // MARK: Modifier für X & O
        Image(systemName: systemImageName)
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 40)
            .foregroundColor(.white)
    }
}
