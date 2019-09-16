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

    var grids: [[Int]] = {
        var grids: [[Int]] = []
        for i in 0..<8 {
            grids.append([])
            for _ in 0..<8 {
                grids[i].append(0)
            }
        }
        return grids
    }()
    var highlightedIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        wordPuzzleView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(willKeyboardShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willKeyboardHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @IBAction func didTapGrid(_ sender: UITapGestureRecognizer) {
        guard !textField.isEditing else {
            return
        }
        let point = sender.location(in: wordPuzzleView)
        let indexPath = wordPuzzleView.indexPath(on: point)
        let rect = wordPuzzleView.rect(for: indexPath)
        highlightedIndexPath = indexPath
        textField.frame = rect
        textField.isHidden = false
        textField.becomeFirstResponder()
    }
    
    @objc func doneUpdateHighlightedGrid() {
        if let indexPath = highlightedIndexPath, let num = Int(textField.text ?? "") {
            cancelUpdateHighlightedGrid()
            grids[indexPath.section][indexPath.row] = num
            wordPuzzleView.setNeedsDisplay()
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
}

extension ViewController: WordPuzzleViewDataSource {
    var numberOfGridsInRow: Int {
        return grids.count
    }
    
    var numberOfGridsInColumn: Int {
        return grids.first?.count ?? 0
    }
    
    func grid(at indexPath: IndexPath) -> Int {
        return grids[indexPath.section][indexPath.row]
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
        textField.text = String(grids[indexPath.section][indexPath.row])
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.location == 0, range.length == 0 || range.length == 1 {
            return true
        }
        return false
    }
}
