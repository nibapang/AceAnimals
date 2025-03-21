//
//  DiceGameViewController.swift
//  AceAnimals
//
//  Created by Sun on 2025/3/21.
//

import UIKit

class DiceGameViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var diceImageView: UIImageView!
    @IBOutlet weak var rollButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    
    var gridNumbers: [[Int]] = []
    var totalSum = 0
    var remainingSum = 0
    var timer: Timer?
    var timeRemaining = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 5
            layout.minimumLineSpacing = 5
            layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        }
        
        setupGame()
    }
    
    func setupGame() {
        timeRemaining = 30
        timerLabel.text = "\(timeRemaining)s"
        generateGridNumbers()
        calculateTotalSum()
        startTimer()
        collectionView.reloadData()
    }
    
    func generateGridNumbers() {
        gridNumbers = Array(repeating: Array(repeating: 0, count: 3), count: 4)
        var positions: [(Int, Int)] = []
        
        while positions.count < 12 {
            let row = Int.random(in: 0..<4)
            let col = Int.random(in: 0..<3)
            if !positions.contains(where: { $0 == (row, col) }) {
                positions.append((row, col))
                gridNumbers[row][col] = Int.random(in: 1...9)
            }
        }
        
        for row in 0..<4 {
            for col in 0..<3 {
                if !positions.contains(where: { $0 == (row, col) }) {
                    gridNumbers[row][col] = 0
                }
            }
        }
        
        collectionView.reloadData()
    }
    
    func calculateTotalSum() {
        totalSum = gridNumbers.flatMap { $0 }.reduce(0, +)
        remainingSum = totalSum
        totalLabel.text = "Total: \(totalSum)"
        remainingLabel.text = "Remaining: \(remainingSum)"
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        timeRemaining -= 1
        timerLabel.text = "\(timeRemaining)s"
        if timeRemaining <= 0 {
            timer?.invalidate()
            showGameOverAlert()
        }
    }
    
    @IBAction func rollDiceTapped(_ sender: UIButton) {
        let diceRoll = Int.random(in: 0...6)
        remainingSum -= diceRoll
        remainingSum = max(remainingSum, 0) // Ensuring it doesn't go below zero
        
        diceImageView.image = UIImage(named: "pokerd\(diceRoll)")
        remainingLabel.text = "Remaining: \(remainingSum)"
        
        showDiceAlert(diceRoll)
    }
    
    func showDiceAlert(_ diceRoll: Int) {
        let alert = UIAlertController(title: "Dice Roll", message: "You rolled a \(diceRoll)", preferredStyle: .alert)
        present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            alert.dismiss(animated: true)
            if self.remainingSum == 0 {
                self.showWinAlert()
            }
        }
    }
    
    func showGameOverAlert() {
        let alert = UIAlertController(title: "Game Over", message: "Time is up! Restarting game...", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.setupGame()
        })
        self.present(alert, animated: true, completion: nil)
    }

    func showWinAlert() {
        timer?.invalidate() // Stop timer when the player wins
        let alert = UIAlertController(title: "You Win!", message: "You reduced the total to zero! Restarting game...", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.setupGame()
        })
        self.present(alert, animated: true, completion: nil) // Ensuring alert is shown
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! GridCell
        let number = gridNumbers[indexPath.section][indexPath.item]
        cell.numberImageView.image = UIImage(named: "number\(number)")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.width - 20) / 3
        let cellHeight = (collectionView.frame.height - 20) / 2
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    @IBAction func BackBtn (_ sender : Any) {
          navigationController?.popViewController(animated: true)
      }
}

class GridCell: UICollectionViewCell {
    @IBOutlet weak var numberImageView: UIImageView!
}
