//
//  AdditionalGames.swift
//  cc98
//
//  Created by IGOR on 17/11/2025.
//

import SwiftUI
import Combine

// MARK: - Color Match Game
struct ColorMatchGame: View {
    let game: MiniGame
    @ObservedObject var gamesManager: GamesManager
    let dismiss: () -> Void
    
    @State private var colors: [[String]] = []
    @State private var score = 0
    @State private var moves = 15
    @State private var gameOver = false
    
    let colorOptions = ["bd0e1b", "ffbe00", "0a1a3b", "00ff88", "ff6b00"]
    let gridSize = 6
    
    var body: some View {
        ZStack {
            Color(hex: "02102b")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Top Bar
                GameTopBar(score: score, secondaryInfo: "Moves: \(moves)", onDismiss: dismiss)
                
                Spacer()
                
                // Game Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: gridSize), spacing: 8) {
                    ForEach(0..<gridSize, id: \.self) { row in
                        ForEach(0..<gridSize, id: \.self) { col in
                            if row < colors.count && col < colors[row].count {
                                ColorTile(color: colors[row][col])
                                    .onTapGesture {
                                        tileTapped(row: row, col: col)
                                    }
                            }
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
            
            if gameOver {
                GameOverOverlay(
                    score: score,
                    message: moves == 0 ? "Out of moves!" : "Well done!",
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
        colors = (0..<gridSize).map { _ in
            (0..<gridSize).map { _ in colorOptions.randomElement()! }
        }
    }
    
    func tileTapped(row: Int, col: Int) {
        guard moves > 0 else { return }
        guard row < colors.count && col < colors[row].count else { return }
        
        let targetColor = colors[row][col]
        let newColor = colorOptions.filter { $0 != targetColor }.randomElement()!
        
        floodFill(row: row, col: col, targetColor: targetColor, newColor: newColor)
        moves -= 1
        
        if checkWin() {
            gameOver = true
        } else if moves == 0 {
            gameOver = true
        }
    }
    
    func floodFill(row: Int, col: Int, targetColor: String, newColor: String) {
        guard row >= 0 && row < gridSize && col >= 0 && col < gridSize else { return }
        guard row < colors.count && col < colors[row].count else { return }
        guard colors[row][col] == targetColor else { return }
        
        colors[row][col] = newColor
        score += 1
        
        floodFill(row: row - 1, col: col, targetColor: targetColor, newColor: newColor)
        floodFill(row: row + 1, col: col, targetColor: targetColor, newColor: newColor)
        floodFill(row: row, col: col - 1, targetColor: targetColor, newColor: newColor)
        floodFill(row: row, col: col + 1, targetColor: targetColor, newColor: newColor)
    }
    
    func checkWin() -> Bool {
        guard !colors.isEmpty else { return false }
        let firstColor = colors[0][0]
        return colors.allSatisfy { row in
            row.allSatisfy { $0 == firstColor }
        }
    }
    
    func resetGame() {
        score = 0
        moves = 15
        gameOver = false
        setupGame()
    }
}

struct ColorTile: View {
    let color: String
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(hex: color))
            .aspectRatio(1, contentMode: .fit)
            .shadow(radius: 2)
    }
}

// MARK: - Reaction Time Game
struct ReactionTimeGame: View {
    let game: MiniGame
    @ObservedObject var gamesManager: GamesManager
    let dismiss: () -> Void
    
    @State private var gameState: ReactionState = .waiting
    @State private var score = 0
    @State private var attempts = 0
    @State private var reactionTime: Double = 0
    @State private var timer: Timer?
    @State private var startTime: Date?
    
    enum ReactionState {
        case waiting, ready, tap, tooEarly, result
    }
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
                .onTapGesture {
                    handleTap()
                }
            
            VStack {
                // Top Bar
                HStack {
                    Button(action: {
                        timer?.invalidate()
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    Text("Attempt \(attempts)/5")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding()
                
                Spacer()
                
                VStack(spacing: 24) {
                    Image(systemName: statusIcon)
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                    
                    Text(statusText)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    if gameState == .result {
                        Text("\(Int(reactionTime))ms")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(Color(hex: "ffbe00"))
                    }
                }
                
                Spacer()
                
                if attempts >= 5 {
                    Button(action: {
                        gamesManager.updateGameScore(gameId: game.id, score: score)
                        timer?.invalidate()
                        dismiss()
                    }) {
                        Text("Finish")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "bd0e1b"))
                            .cornerRadius(12)
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            startRound()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    var backgroundColor: Color {
        switch gameState {
        case .waiting: return Color(hex: "02102b")
        case .ready: return Color(hex: "bd0e1b")
        case .tap: return Color(hex: "00ff88")
        case .tooEarly: return Color(hex: "ff6b00")
        case .result: return Color(hex: "0a1a3b")
        }
    }
    
    var statusIcon: String {
        switch gameState {
        case .waiting: return "hourglass"
        case .ready: return "hand.raised.fill"
        case .tap: return "hand.tap.fill"
        case .tooEarly: return "xmark.circle.fill"
        case .result: return "checkmark.circle.fill"
        }
    }
    
    var statusText: String {
        switch gameState {
        case .waiting: return "Get Ready..."
        case .ready: return "Wait for Green..."
        case .tap: return "TAP NOW!"
        case .tooEarly: return "Too Early!"
        case .result: return "Great!"
        }
    }
    
    func handleTap() {
        switch gameState {
        case .tap:
            if let start = startTime {
                let time = Date().timeIntervalSince(start) * 1000
                reactionTime = time
                score += max(1000 - Int(time), 0)
                gameState = .result
                attempts += 1
                timer?.invalidate()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    if attempts < 5 {
                        startRound()
                    }
                }
            }
            
        case .ready:
            gameState = .tooEarly
            attempts += 1
            timer?.invalidate()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if attempts < 5 {
                    startRound()
                }
            }
            
        default:
            break
        }
    }
    
    func startRound() {
        gameState = .waiting
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            gameState = .ready
            
            let delay = Double.random(in: 2...5)
            timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
                gameState = .tap
                startTime = Date()
            }
        }
    }
}

// MARK: - Math Challenge Game
struct MathChallengeGame: View {
    let game: MiniGame
    @ObservedObject var gamesManager: GamesManager
    let dismiss: () -> Void
    
    @State private var score = 0
    @State private var timeLeft = 60
    @State private var currentProblem = ""
    @State private var correctAnswer = 0
    @State private var options: [Int] = []
    @State private var gameStarted = false
    @State private var gameOver = false
    @State private var streak = 0
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            Color(hex: "02102b")
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Top Bar
                HStack {
                    Button(action: {
                        timer?.invalidate()
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 14))
                                Text("\(score)")
                                    .font(.system(size: 18, weight: .bold))
                            }
                            .foregroundColor(Color(hex: "ffbe00"))
                            
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 14))
                                Text("\(streak)")
                                    .font(.system(size: 18, weight: .bold))
                            }
                            .foregroundColor(Color(hex: "bd0e1b"))
                        }
                        
                        Text("Time: \(timeLeft)s")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding()
                
                if gameStarted && !gameOver {
                    Spacer()
                    
                    // Problem
                    Text(currentProblem)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                    
                    // Options
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(options, id: \.self) { option in
                            Button(action: {
                                checkAnswer(option)
                            }) {
                                Text("\(option)")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 80)
                                    .background(Color(hex: "0a1a3b"))
                                    .cornerRadius(16)
                            }
                        }
                    }
                    .padding()
                    
                    Spacer()
                } else if !gameStarted {
                    Spacer()
                    
                    Button(action: {
                        startGame()
                    }) {
                        Text("Start Challenge")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 16)
                            .background(Color(hex: "bd0e1b"))
                            .cornerRadius(16)
                    }
                    
                    Spacer()
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
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    func startGame() {
        gameStarted = true
        generateProblem()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeLeft > 0 {
                timeLeft -= 1
            } else {
                gameOver = true
                timer?.invalidate()
            }
        }
    }
    
    func generateProblem() {
        let num1 = Int.random(in: 1...20)
        let num2 = Int.random(in: 1...20)
        let operations = ["+", "-", "×"]
        let operation = operations.randomElement()!
        
        switch operation {
        case "+":
            correctAnswer = num1 + num2
            currentProblem = "\(num1) + \(num2)"
        case "-":
            correctAnswer = num1 - num2
            currentProblem = "\(num1) - \(num2)"
        case "×":
            correctAnswer = num1 * num2
            currentProblem = "\(num1) × \(num2)"
        default:
            correctAnswer = num1 + num2
            currentProblem = "\(num1) + \(num2)"
        }
        
        var opts = [correctAnswer]
        while opts.count < 4 {
            let wrong = correctAnswer + Int.random(in: -10...10)
            if wrong != correctAnswer && !opts.contains(wrong) && wrong >= 0 {
                opts.append(wrong)
            }
        }
        options = opts.shuffled()
    }
    
    func checkAnswer(_ answer: Int) {
        if answer == correctAnswer {
            score += (10 + streak * 2)
            streak += 1
        } else {
            streak = 0
        }
        generateProblem()
    }
    
    func resetGame() {
        timer?.invalidate()
        score = 0
        timeLeft = 60
        streak = 0
        gameOver = false
        gameStarted = false
    }
}

// MARK: - Simon Says Game
struct SimonSaysGame: View {
    let game: MiniGame
    @ObservedObject var gamesManager: GamesManager
    let dismiss: () -> Void
    
    @State private var sequence: [Int] = []
    @State private var userSequence: [Int] = []
    @State private var showingSequence = false
    @State private var highlightedColor: Int? = nil
    @State private var score = 0
    @State private var gameOver = false
    @State private var gameStarted = false
    
    let colors = ["bd0e1b", "ffbe00", "00ff88", "0a1a3b"]
    
    var body: some View {
        ZStack {
            Color(hex: "02102b")
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Top Bar
                GameTopBar(score: score, secondaryInfo: "Round \(sequence.count)", onDismiss: dismiss)
                
                Spacer()
                
                if gameStarted {
                    // Color Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(0..<4, id: \.self) { index in
                            Button(action: {
                                if !showingSequence {
                                    colorTapped(index)
                                }
                            }) {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(hex: colors[index]))
                                    .frame(height: 150)
                                    .opacity(highlightedColor == index ? 1.0 : 0.6)
                                    .animation(.easeInOut(duration: 0.2), value: highlightedColor)
                            }
                            .disabled(showingSequence)
                        }
                    }
                    .padding()
                } else {
                    Button(action: {
                        gameStarted = true
                        addToSequence()
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
                
                Spacer()
            }
            
            if gameOver {
                GameOverOverlay(
                    score: score,
                    message: "Game Over!",
                    onRestart: resetGame,
                    onExit: {
                        gamesManager.updateGameScore(gameId: game.id, score: score)
                        dismiss()
                    }
                )
            }
        }
    }
    
    func addToSequence() {
        sequence.append(Int.random(in: 0...3))
        userSequence.removeAll()
        playSequence()
    }
    
    func playSequence() {
        showingSequence = true
        var delay = 0.0
        
        for color in sequence {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                highlightedColor = color
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    highlightedColor = nil
                }
            }
            delay += 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.5) {
            showingSequence = false
        }
    }
    
    func colorTapped(_ index: Int) {
        userSequence.append(index)
        highlightedColor = index
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            highlightedColor = nil
        }
        
        if userSequence.count == sequence.count {
            if userSequence == sequence {
                score += sequence.count * 10
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    addToSequence()
                }
            } else {
                gameOver = true
            }
        } else if userSequence.last != sequence[userSequence.count - 1] {
            gameOver = true
        }
    }
    
    func resetGame() {
        sequence.removeAll()
        userSequence.removeAll()
        score = 0
        gameOver = false
        gameStarted = false
    }
}

// MARK: - Remaining Games (Simple implementations)

struct NumberMemoryGame: View {
    let game: MiniGame
    @ObservedObject var gamesManager: GamesManager
    let dismiss: () -> Void
    
    @State private var score = 0
    @State private var currentNumber = ""
    @State private var userInput = ""
    @State private var showNumber = true
    @State private var round = 1
    @State private var gameOver = false
    
    var body: some View {
        ZStack {
            Color(hex: "02102b")
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                GameTopBar(score: score, secondaryInfo: "Round \(round)", onDismiss: dismiss)
                
                Spacer()
                
                if showNumber {
                    Text(currentNumber)
                        .font(.system(size: 64, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    TextField("Enter number", text: $userInput)
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color(hex: "0a1a3b"))
                        .cornerRadius(12)
                        .padding()
                    
                    Button(action: checkAnswer) {
                        Text("Submit")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "bd0e1b"))
                            .cornerRadius(12)
                    }
                    .padding()
                }
                
                Spacer()
            }
            
            if gameOver {
                GameOverOverlay(
                    score: score,
                    message: "Game Over!",
                    onRestart: resetGame,
                    onExit: {
                        gamesManager.updateGameScore(gameId: game.id, score: score)
                        dismiss()
                    }
                )
            }
        }
        .onAppear {
            generateNumber()
        }
    }
    
    func generateNumber() {
        let digits = min(3 + round, 10)
        currentNumber = String((0..<digits).map { _ in Int.random(in: 0...9) }.map(String.init).joined())
        showNumber = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(digits) * 0.5) {
            showNumber = false
        }
    }
    
    func checkAnswer() {
        if userInput == currentNumber {
            score += round * 10
            round += 1
            userInput = ""
            generateNumber()
        } else {
            gameOver = true
        }
    }
    
    func resetGame() {
        score = 0
        round = 1
        userInput = ""
        gameOver = false
        generateNumber()
    }
}

struct NumberPuzzleGame: View {
    let game: MiniGame
    @ObservedObject var gamesManager: GamesManager
    let dismiss: () -> Void
    
    @State private var tiles: [Int] = Array(1...15) + [0]
    @State private var score = 0
    @State private var moves = 0
    @State private var gameOver = false
    
    var body: some View {
        ZStack {
            Color(hex: "02102b")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                GameTopBar(score: score, secondaryInfo: "Moves: \(moves)", onDismiss: dismiss)
                
                Spacer()
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                    ForEach(0..<16, id: \.self) { index in
                        if tiles[index] == 0 {
                            Color.clear
                                .aspectRatio(1, contentMode: .fit)
                        } else {
                            Button(action: {
                                moveTile(at: index)
                            }) {
                                Text("\(tiles[index])")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .aspectRatio(1, contentMode: .fit)
                                    .background(Color(hex: "bd0e1b"))
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
            
            if gameOver {
                GameOverOverlay(
                    score: score,
                    message: "Puzzle Solved!",
                    onRestart: resetGame,
                    onExit: {
                        gamesManager.updateGameScore(gameId: game.id, score: score)
                        dismiss()
                    }
                )
            }
        }
        .onAppear {
            shuffleTiles()
        }
    }
    
    func shuffleTiles() {
        tiles.shuffle()
        // Ensure puzzle is solvable
        while !isSolvable() {
            tiles.shuffle()
        }
    }
    
    func isSolvable() -> Bool {
        var inversions = 0
        for i in 0..<tiles.count {
            for j in (i+1)..<tiles.count {
                if tiles[i] != 0 && tiles[j] != 0 && tiles[i] > tiles[j] {
                    inversions += 1
                }
            }
        }
        return inversions % 2 == 0
    }
    
    func moveTile(at index: Int) {
        let emptyIndex = tiles.firstIndex(of: 0)!
        let row = index / 4
        let col = index % 4
        let emptyRow = emptyIndex / 4
        let emptyCol = emptyIndex % 4
        
        if (abs(row - emptyRow) == 1 && col == emptyCol) || (abs(col - emptyCol) == 1 && row == emptyRow) {
            tiles.swapAt(index, emptyIndex)
            moves += 1
            
            if checkWin() {
                score = max(1000 - moves, 0)
                gameOver = true
            }
        }
    }
    
    func checkWin() -> Bool {
        return tiles == Array(1...15) + [0]
    }
    
    func resetGame() {
        score = 0
        moves = 0
        gameOver = false
        shuffleTiles()
    }
}

struct DodgeMasterGame: View {
    let game: MiniGame
    @ObservedObject var gamesManager: GamesManager
    let dismiss: () -> Void
    
    @State private var playerPosition: CGFloat = 0
    @State private var obstacles: [(id: UUID, position: CGFloat)] = []
    @State private var score = 0
    @State private var gameOver = false
    @State private var timer: Timer?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(hex: "02102b")
                    .ignoresSafeArea()
                
                VStack {
                    GameTopBar(score: score, secondaryInfo: "Dodge!", onDismiss: {
                        timer?.invalidate()
                        dismiss()
                    })
                    
                    Spacer()
                }
                
                // Player
                Circle()
                    .fill(Color(hex: "ffbe00"))
                    .frame(width: 40, height: 40)
                    .position(x: geometry.size.width / 2 + playerPosition, y: geometry.size.height - 100)
                
                // Obstacles
                ForEach(obstacles, id: \.id) { obstacle in
                    Circle()
                        .fill(Color(hex: "bd0e1b"))
                        .frame(width: 30, height: 30)
                        .position(x: obstacle.position, y: 50)
                }
                
                if gameOver {
                    GameOverOverlay(
                        score: score,
                        message: "Game Over!",
                        onRestart: resetGame,
                        onExit: {
                            gamesManager.updateGameScore(gameId: game.id, score: score)
                            timer?.invalidate()
                            dismiss()
                        }
                    )
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let newPosition = value.translation.width
                        playerPosition = min(max(newPosition, -geometry.size.width / 2 + 40), geometry.size.width / 2 - 40)
                    }
            )
        }
        .onAppear {
            startGame()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    func startGame() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            score += 1
            // This is a simplified version
        }
    }
    
    func resetGame() {
        timer?.invalidate()
        score = 0
        gameOver = false
        obstacles.removeAll()
        playerPosition = 0
        startGame()
    }
}

struct WordScrambleGame: View {
    let game: MiniGame
    @ObservedObject var gamesManager: GamesManager
    let dismiss: () -> Void
    
    @State private var currentWord = ""
    @State private var scrambledWord = ""
    @State private var userInput = ""
    @State private var score = 0
    @State private var timeLeft = 60
    @State private var gameOver = false
    @State private var timer: Timer?
    
    let words = ["SWIFT", "GAME", "CODE", "PUZZLE", "BRAIN", "LOGIC", "MEMORY", "ACTION", "SCORE", "LEVEL"]
    
    var body: some View {
        ZStack {
            Color(hex: "02102b")
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                GameTopBar(score: score, secondaryInfo: "Time: \(timeLeft)s", onDismiss: {
                    timer?.invalidate()
                    dismiss()
                })
                
                Spacer()
                
                Text(scrambledWord)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(Color(hex: "ffbe00"))
                    .tracking(8)
                
                TextField("Unscramble", text: $userInput)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .autocapitalization(.allCharacters)
                    .padding()
                    .background(Color(hex: "0a1a3b"))
                    .cornerRadius(12)
                    .padding()
                
                Button(action: checkWord) {
                    Text("Submit")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "bd0e1b"))
                        .cornerRadius(12)
                }
                .padding()
                
                Spacer()
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
        .onAppear {
            startGame()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    func startGame() {
        generateWord()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeLeft > 0 {
                timeLeft -= 1
            } else {
                gameOver = true
                timer?.invalidate()
            }
        }
    }
    
    func generateWord() {
        currentWord = words.randomElement()!
        scrambledWord = String(currentWord.shuffled())
    }
    
    func checkWord() {
        if userInput.uppercased() == currentWord {
            score += currentWord.count * 10
            userInput = ""
            generateWord()
        }
    }
    
    func resetGame() {
        timer?.invalidate()
        score = 0
        timeLeft = 60
        userInput = ""
        gameOver = false
        startGame()
    }
}
