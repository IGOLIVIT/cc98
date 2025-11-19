//
//  GamePlayView.swift
//  cc98
//
//  Created by IGOR on 17/11/2025.
//

import SwiftUI
import Combine

struct GamePlayView: View {
    let game: MiniGame
    @ObservedObject var gamesManager: GamesManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Group {
            switch game.name {
            case "Pair Match":
                MemoryMatchGame(game: game, gamesManager: gamesManager, dismiss: { presentationMode.wrappedValue.dismiss() })
            case "Quick Tap":
                QuickTapGame(game: game, gamesManager: gamesManager, dismiss: { presentationMode.wrappedValue.dismiss() })
            case "Color Match":
                ColorMatchGame(game: game, gamesManager: gamesManager, dismiss: { presentationMode.wrappedValue.dismiss() })
            case "Reaction Time":
                ReactionTimeGame(game: game, gamesManager: gamesManager, dismiss: { presentationMode.wrappedValue.dismiss() })
            case "Math Challenge":
                MathChallengeGame(game: game, gamesManager: gamesManager, dismiss: { presentationMode.wrappedValue.dismiss() })
            case "Simon Says":
                SimonSaysGame(game: game, gamesManager: gamesManager, dismiss: { presentationMode.wrappedValue.dismiss() })
            case "Number Recall":
                NumberMemoryGame(game: game, gamesManager: gamesManager, dismiss: { presentationMode.wrappedValue.dismiss() })
            case "Number Puzzle":
                NumberPuzzleGame(game: game, gamesManager: gamesManager, dismiss: { presentationMode.wrappedValue.dismiss() })
            case "Dodge Master":
                DodgeMasterGame(game: game, gamesManager: gamesManager, dismiss: { presentationMode.wrappedValue.dismiss() })
            case "Word Scramble":
                WordScrambleGame(game: game, gamesManager: gamesManager, dismiss: { presentationMode.wrappedValue.dismiss() })
            default:
                ComingSoonView(game: game, dismiss: { presentationMode.wrappedValue.dismiss() })
            }
        }
    }
}

// MARK: - Memory Match Game
struct MemoryMatchGame: View {
    let game: MiniGame
    @ObservedObject var gamesManager: GamesManager
    let dismiss: () -> Void
    
    @State private var cards: [MemoryCard] = []
    @State private var flippedCards: [Int] = []
    @State private var matchedCards: Set<Int> = []
    @State private var score = 0
    @State private var moves = 0
    @State private var gameOver = false
    @State private var isProcessing = false
    
    let symbols = ["star.fill", "heart.fill", "circle.fill", "square.fill", "triangle.fill", "diamond.fill", "hexagon.fill", "pentagon.fill"]
    
    var body: some View {
        ZStack {
            Color(hex: "02102b")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Top Bar
                GameTopBar(score: score, secondaryInfo: "Moves: \(moves)", onDismiss: dismiss)
                
                Spacer()
                
                // Game Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                    ForEach(0..<cards.count, id: \.self) { index in
                        MemoryCardView(
                            card: cards[index],
                            isFlipped: flippedCards.contains(index) || matchedCards.contains(index),
                            isMatched: matchedCards.contains(index)
                        )
                        .onTapGesture {
                            cardTapped(index)
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
            
            if gameOver {
                GameOverOverlay(
                    score: score,
                    message: "Great job!",
                    onRestart: resetGame,
                    onExit: {
                        gamesManager.updateGameScore(gameId: game.id, score: score)
                        dismiss()
                    }
                )
            }
        }
        .onAppear {
            setupGame()
        }
    }
    
    func setupGame() {
        var newCards: [MemoryCard] = []
        for symbol in symbols {
            newCards.append(MemoryCard(symbol: symbol))
            newCards.append(MemoryCard(symbol: symbol))
        }
        cards = newCards.shuffled()
    }
    
    func cardTapped(_ index: Int) {
        guard !isProcessing && !matchedCards.contains(index) && !flippedCards.contains(index) && flippedCards.count < 2 else { return }
        
        flippedCards.append(index)
        
        if flippedCards.count == 2 {
            isProcessing = true
            moves += 1
            checkForMatch()
        }
    }
    
    func checkForMatch() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            let first = flippedCards[0]
            let second = flippedCards[1]
            
            if cards[first].symbol == cards[second].symbol {
                matchedCards.insert(first)
                matchedCards.insert(second)
                score += 10
                
                if matchedCards.count == cards.count {
                    gameOver = true
                }
            }
            
            flippedCards.removeAll()
            isProcessing = false
        }
    }
    
    func resetGame() {
        matchedCards.removeAll()
        flippedCards.removeAll()
        score = 0
        moves = 0
        gameOver = false
        isProcessing = false
        setupGame()
    }
}

struct MemoryCard: Identifiable {
    let id = UUID()
    let symbol: String
}

struct MemoryCardView: View {
    let card: MemoryCard
    let isFlipped: Bool
    let isMatched: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(isFlipped ? (isMatched ? Color.green.opacity(0.3) : Color(hex: "bd0e1b")) : Color(hex: "0a1a3b"))
                .aspectRatio(1, contentMode: .fit)
            
            if isFlipped {
                Image(systemName: card.symbol)
                    .font(.system(size: 30))
                    .foregroundColor(.white)
            }
        }
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.easeInOut(duration: 0.3), value: isFlipped)
    }
}

// MARK: - Quick Tap Game
struct QuickTapGame: View {
    let game: MiniGame
    @ObservedObject var gamesManager: GamesManager
    let dismiss: () -> Void
    
    @State private var score = 0
    @State private var timeLeft = 30
    @State private var targetPosition = CGPoint(x: 100, y: 100)
    @State private var gameStarted = false
    @State private var gameOver = false
    @State private var timer: Timer?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(hex: "02102b")
                    .ignoresSafeArea()
                
                VStack {
                    // Top Bar
                    GameTopBar(score: score, secondaryInfo: "Time: \(timeLeft)s", onDismiss: {
                        timer?.invalidate()
                        dismiss()
                    })
                    
                    Spacer()
                }
                
                if gameStarted && !gameOver {
                    // Target
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "bd0e1b"), Color(hex: "ffbe00")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .position(targetPosition)
                        .shadow(radius: 10)
                        .onTapGesture {
                            targetTapped(in: geometry.size)
                        }
                }
                
                if !gameStarted {
                    Button(action: {
                        startGame()
                        moveTarget(in: geometry.size)
                    }) {
                        Text("Start Game")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 16)
                            .background(Color(hex: "bd0e1b"))
                            .cornerRadius(16)
                    }
                }
                
                if gameOver {
                    GameOverOverlay(
                        score: score,
                        message: "Time's up!",
                        onRestart: resetGame,
                        onExit: {
                            gamesManager.updateGameScore(gameId: game.id, score: score)
                            timer?.invalidate()
                            dismiss()
                        }
                    )
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    func startGame() {
        gameStarted = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeLeft > 0 {
                timeLeft -= 1
            } else {
                gameOver = true
                timer?.invalidate()
            }
        }
    }
    
    func targetTapped(in size: CGSize) {
        score += 1
        moveTarget(in: size)
    }
    
    func moveTarget(in size: CGSize) {
        let newX = CGFloat.random(in: 60...(size.width - 60))
        let newY = CGFloat.random(in: 120...(size.height - 120))
        withAnimation(.easeOut(duration: 0.3)) {
            targetPosition = CGPoint(x: newX, y: newY)
        }
    }
    
    func resetGame() {
        timer?.invalidate()
        score = 0
        timeLeft = 30
        gameOver = false
        gameStarted = false
    }
}

// MARK: - Reusable Components
struct GameTopBar: View {
    let score: Int
    let secondaryInfo: String
    let onDismiss: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text("Score: \(score)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "ffbe00"))
                Text(secondaryInfo)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding()
    }
}

// MARK: - Game Over Overlay
struct GameOverOverlay: View {
    let score: Int
    let message: String
    let onRestart: () -> Void
    let onExit: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(hex: "ffbe00"))
                
                Text(message)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Score: \(score)")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Color(hex: "ffbe00"))
                
                HStack(spacing: 16) {
                    Button(action: onRestart) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Restart")
                        }
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "0a1a3b"))
                        .cornerRadius(12)
                    }
                    
                    Button(action: onExit) {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("Done")
                        }
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "bd0e1b"))
                        .cornerRadius(12)
                    }
                }
            }
            .padding(40)
            .background(Color(hex: "02102b"))
            .cornerRadius(24)
            .padding(.horizontal, 40)
        }
    }
}

// MARK: - Coming Soon View
struct ComingSoonView: View {
    let game: MiniGame
    let dismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color(hex: "02102b")
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Button(action: dismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding()
                
                Spacer()
                
                Image(systemName: game.icon)
                    .font(.system(size: 80))
                    .foregroundColor(Color(hex: "ffbe00"))
                
                Text("Coming Soon")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text(game.name)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                
                Text("This game is under development")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.top, 8)
                
                Spacer()
            }
        }
    }
}
