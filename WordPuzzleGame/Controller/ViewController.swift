//
//  ViewController.swift
//  WordPuzzleGame
//
//  Created by peter.shih on 2019/9/16.
//  Copyright © 2019年 Peteranny. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var wordPuzzleView: WordPuzzleView!
    @IBOutlet weak var textField: UITextField!

    let fixedGrids: [[Int?]] = [
        [  2,  6,  9,  3,  5,  8,  4,  1,  7],
        [  4,  7,  3,  9,  1,  6,  2,  8,  5],
        [  8,  1,nil,  4,  7,  2,nil,  6,  3],
        [  7,  5,  2,  1,  9,  4,  6,  3,  8],
        [  1,  9,  4,  8,  6,  3,  7,  5,  2],
        [  6,  3,  8,  7,  2,nil,  1,  9,  4],
        [  3,  4,  7,  6,  8,  1,  5,  2,  9],
        [  5,  8,  1,  2,  4,  9,  3,  7,  6],
        [  9,  2,  6,nil,  3,  7,nil,  4,  1],
    ]
    var grids: [[Int?]] = [] {
        didSet {
            wordPuzzleView.setNeedsDisplay()
            if hasDoneSudoku {
                win()
            }
        }
    }
    var hasDoneHorizontalSudoku: Bool {
        for i in 0..<9 {
            var set: Set<Int> = []
            for j in 0..<9 {
                guard let num = grids[i][j] else {
                    return false
                }
                if set.contains(num) {
                    return false
                }
                set.insert(num)
            }
        }
        return true
    }
    var hasDoneVerticalSudoku: Bool {
        for i in 0..<9 {
            var set: Set<Int> = []
            for j in 0..<9 {
                guard let num = grids[j][i] else {
                    return false
                }
                if set.contains(num) {
                    return false
                }
                set.insert(num)
            }
        }
        return true
    }
    var hasDoneSquareSudoku: Bool {
        for i in 0..<9 {
            var set: Set<Int> = []
            for j in (i/3)*3 ..< (i/3)*3 + 3 {
                for k in (i%3)*3 ..< (i%3)*3 + 3 {
                    guard let num = grids[j][k] else {
                        return false
                    }
                    if set.contains(num) {
                        return false
                    }
                    set.insert(num)
                }
            }
        }
        return true
    }
    var hasDoneSudoku: Bool {
        return hasDoneHorizontalSudoku && hasDoneVerticalSudoku && hasDoneSquareSudoku
    }
    var highlightedIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        wordPuzzleView.dataSource = self
        
        grids = fixedGrids
        
        NotificationCenter.default.addObserver(self, selector: #selector(willKeyboardShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willKeyboardHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @IBAction func didTapGrid(_ sender: UITapGestureRecognizer) {
        guard !textField.isEditing else {
            return
        }
        let point = sender.location(in: wordPuzzleView)
        let indexPath = wordPuzzleView.indexPath(on: point)
        guard !isFixed(at: indexPath) else {
            return
        }
        let rect = wordPuzzleView.rect(for: indexPath)
        highlightedIndexPath = indexPath
        textField.frame = rect
        textField.isHidden = false
        textField.becomeFirstResponder()
    }
    
    @objc func doneUpdateHighlightedGrid() {
        guard let indexPath = highlightedIndexPath else {
            return
        }
        let num = Int(textField.text ?? "")
        cancelUpdateHighlightedGrid()
        if let num = num {
            grids[indexPath.section][indexPath.row] = num
        } else {
            grids[indexPath.section][indexPath.row] = nil
        }
    }
    
    @objc func cancelUpdateHighlightedGrid() {
        textField.resignFirstResponder()
        highlightedIndexPath = nil
        textField.isHidden = true
    }
    
    @objc func willKeyboardShow(_ notification: Notification) {
        if let indexPath = highlightedIndexPath, let keyboardRect = notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect {
            let gridRect = view.convert(wordPuzzleView.rect(for: indexPath), from: wordPuzzleView)
            let yOffset = max(0, gridRect.maxY - keyboardRect.minY - view.bounds.minY)
            view.bounds.origin.y += yOffset
        }
    }

    @objc func willKeyboardHide(_ notification: Notification) {
        view.bounds.origin.y = 0
    }
    
    @IBAction func didTapResetButton(_ sender: UIButton) {
        grids = fixedGrids
    }
    
    func win() {
        let alertController: UIAlertController = {
            let alert = UIAlertController(title: "You Win", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            return alert
        }()
        present(alertController, animated: true)
    }
}

extension ViewController: WordPuzzleViewDataSource {
    var numberOfGridsInRow: Int {
        return grids.count
    }
    
    var numberOfGridsInColumn: Int {
        return grids.first?.count ?? 0
    }
    
    func grid(at indexPath: IndexPath) -> Int? {
        return grids[indexPath.section][indexPath.row]
    }
    
    func isFixed(at indexPath: IndexPath) -> Bool {
        return fixedGrids[indexPath.section][indexPath.row] != nil
    }
    
    var indexPathForHighlightedGrid: IndexPath? {
        return highlightedIndexPath
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let indexPath = highlightedIndexPath else {
            return
        }
        textField.keyboardType = .decimalPad
        textField.inputAccessoryView = {
            let toolbar = UIToolbar()
            toolbar.barStyle = .default
            toolbar.items = [
                UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelUpdateHighlightedGrid)),
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
                UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneUpdateHighlightedGrid))
            ]
            toolbar.sizeToFit()
            return toolbar
        }()
        if let num = grids[indexPath.section][indexPath.row] {
            textField.text = "\(num)"
        } else {
            textField.text = nil
        }
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.location == 0, range.length == 0 || range.length == 1 {
            return true
        }
        return false
    }
}
