//
//  PulucViewController.swift
//  AceAnimals
//
//  Created by Sun on 2025/3/21.
//

import UIKit
import SpriteKit

class PulucViewController: UIViewController {
    @IBOutlet weak var skView: SKView!
    @IBOutlet weak var rollButton: UIButton!
    @IBOutlet weak var diceImageView: UIImageView!
    @IBOutlet weak var whiteScoreLabel: UILabel!
    @IBOutlet weak var blackScoreLabel: UILabel!
    
    var gameScene: PulucGameScene!
    var currentPlayer: Player = .white
    var whiteScore = 0
    var blackScore = 0
    var whiteCaptured = 0
    var blackCaptured = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3){
            self.showGameRules()
            self.setupGame()
        }
        
    }
    
    func setupGame() {
        gameScene = PulucGameScene(size: skView.bounds.size)
        gameScene.viewController = self
        skView.presentScene(gameScene)
        whiteCaptured = 0
        blackCaptured = 0
        updateScoreLabels()
    }
    
    @IBAction func rollDiceTapped(_ sender: UIButton) {
        let rollValue = rollDice()
        diceImageView.image = UIImage(named: "dice\(rollValue)")
        gameScene.handleMove(rollValue: rollValue, player: currentPlayer)
        switchTurn()
    }
    
    func rollDice() -> Int {
        return Int.random(in: 1...5) // Simulating casting sticks
    }
    
    func switchTurn() {
        currentPlayer = (currentPlayer == .white) ? .black : .white
    }
    
    func updateScore(player: Player) {
        if player == .white {
            whiteScore += 1
            blackCaptured += 1
        } else {
            blackScore += 1
            whiteCaptured += 1
        }
        updateScoreLabels()
        checkWinCondition()
    }
    
    func updateScoreLabels() {
        whiteScoreLabel.text = "Collect: \(whiteScore)"
        blackScoreLabel.text = "Collect: \(blackScore)"
    }
    
    func checkWinCondition() {
        if blackCaptured == 5 {
            showGameOver(winner: .white)
        } else if whiteCaptured == 5 {
            showGameOver(winner: .black)
        }
    }
    
    func showGameRules() {
        let rules = "Rules of Puluc:\n- Each player has 5 pieces.\n- Roll the dice to move pieces forward.\n- Capturing an opponent's piece allows you to carry it forward.\n- If a piece reaches the opponent's end, captured pieces are removed.\n- The game ends when all opponent pieces are captured or eliminated."
        
        let alert = UIAlertController(title: "Game Rules", message: rules, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        alert.view.subviews.first?.subviews.first?.subviews.first?.subviews.first?.backgroundColor = .black
        let bg = UIImageView(image: UIImage(named: "bg"))
        bg.alpha = 0.5
        alert.view.subviews.first?.subviews.first?.subviews.first?.subviews.first?.insertSubview(bg,at: 0)
        alert.view.subviews.first?.subviews.first?.subviews.first?.subviews.last?.subviews.first?.backgroundColor = .systemGray6
        
        present(alert, animated: true)
        
    }
    
    func showGameOver(winner: Player) {
        let winnerText = winner == .white ? "Red Wins!" : "Black Wins!"
        let alert = UIAlertController(title: "Game Over", message: "\(winnerText)\nRestarting Game...", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Restart", style: .default, handler: { _ in
            self.restartGame()
        }))
        
        alert.view.subviews.first?.subviews.first?.subviews.first?.subviews.first?.backgroundColor = .black
        let bg = UIImageView(image: UIImage(named: "bg"))
        bg.alpha = 0.5
        alert.view.subviews.first?.subviews.first?.subviews.first?.subviews.first?.insertSubview(bg,at: 0)
        alert.view.subviews.first?.subviews.first?.subviews.first?.subviews.last?.subviews.first?.backgroundColor = .systemGray6
        
        present(alert, animated: true, completion: nil)
    }
    
    func restartGame() {
        whiteScore = 0
        blackScore = 0
        setupGame()
    }
    
    @IBAction func BackBtn(_ sender : Any) {
          navigationController?.popViewController(animated: true)
      }
}

enum Player {
    case white
    case black
}

class PulucGameScene: SKScene {
    var board: SKSpriteNode!
    var whitePieces: [GamePiece] = []
    var blackPieces: [GamePiece] = []
    let boardSlots = 9
    let pieceSize: CGFloat = 40.0
    var boardPositions: [CGPoint] = []
    var viewController: PulucViewController?
    
    override func didMove(to view: SKView) {
        
        setupBoard()
        setupPieces()
    }
    
    func setupBoard() {
        board = SKSpriteNode(color: UIColor.clear, size: CGSize(width: frame.width * 0.8, height: frame.height * 0.4))
        board.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(board)
        view?.scene?.backgroundColor = .clear
        let slotWidth = board.size.width / CGFloat(boardSlots)
        for i in 0..<boardSlots {
            let xPosition = board.frame.minX + (CGFloat(i) * slotWidth) + (slotWidth / 2)
            boardPositions.append(CGPoint(x: xPosition, y: board.position.y))
        }
    }
    
    func setupPieces() {
        for _ in 0..<5 {
            let whitePiece = createPiece(player: .white)
            let blackPiece = createPiece(player: .black)
            
            whitePiece.position = boardPositions.first!
            blackPiece.position = boardPositions.last!
            
            whitePieces.append(whitePiece)
            blackPieces.append(blackPiece)
            
            addChild(whitePiece)
            addChild(blackPiece)
        }
    }
    
    func createPiece(player: Player) -> GamePiece {
        let texture = SKTexture(imageNamed: player == .white ? "c1" : "c2")
        let piece = GamePiece(texture: texture, size: CGSize(width: pieceSize, height: pieceSize))
        piece.player = player
        return piece
    }
    
    func handleMove(rollValue: Int, player: Player) {
        let pieces = (player == .white) ? whitePieces : blackPieces
        
        if pieces.isEmpty {
            viewController?.showGameOver(winner: player == .white ? .black : .white)
            return
        }
        
        if let piece = pieces.first(where: { $0.canMove }) {
            let currentIndex = boardPositions.firstIndex(of: piece.position) ?? -1
            let newIndex = currentIndex + rollValue
            
            if newIndex >= boardSlots {
                piece.returnToHome()
                viewController?.updateScore(player: player)
                return
            }
            
            let targetPosition = boardPositions[newIndex]
            piece.move(to: targetPosition)
            checkCapture(piece: piece, player: player)
        }
    }
    
    func checkCapture(piece: GamePiece, player: Player) {
        var opponentPieces = (player == .white) ? blackPieces : whitePieces
        
        if let opponentPiece = opponentPieces.first(where: { $0.position == piece.position }) {
            opponentPiece.isCaptured = true
            opponentPieces.removeAll(where: { $0 == opponentPiece })
            viewController?.updateScore(player: player)
        }
    }
    
   
}


class GamePiece: SKSpriteNode {
    var player: Player!
    var canMove: Bool = true
    var isCaptured: Bool = false
    var capturedPieces: [GamePiece] = []
    
    func move(to position: CGPoint) {
        let moveAction = SKAction.move(to: position, duration: 0.5)
        run(moveAction)
    }
    
    func returnToHome() {
        let homePosition = (player == .white) ? CGPoint(x: -200, y: 0) : CGPoint(x: 200, y: 0)
        let moveHome = SKAction.move(to: homePosition, duration: 0.5)
        run(moveHome) {
            self.canMove = false
        }
    }
}
