//
//  WordPuzzleView.swift
//  WordPuzzleGame
//
//  Created by peter.shih on 2019/9/16.
//  Copyright © 2019年 Peteranny. All rights reserved.
//

import UIKit

protocol WordPuzzleViewDataSource {
    var numberOfGridsInRow: Int { get }
    var numberOfGridsInColumn: Int { get }
    func grid(at: IndexPath) -> Int
    var indexPathForHighlightedGrid: IndexPath? { get }
}

class WordPuzzleView: UIView {
    var dataSource: WordPuzzleViewDataSource?
    
    var nRows: Int {
        return dataSource?.numberOfGridsInColumn ?? 0
    }
    var nColumns: Int {
        return dataSource?.numberOfGridsInRow ?? 0
    }

    var gridWidth: CGFloat {
        return frame.width / CGFloat(nColumns) - 2
    }
    var gridHeight: CGFloat {
        return frame.height / CGFloat(nRows) - 2
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        let size = CGSize(width: gridWidth, height: gridHeight)

        context.setFillColor(UIColor.yellow.cgColor)
        
        for i in 0 ..< nRows {
            for j in 0 ..< nColumns {
                let x = gridWidth * CGFloat(i) + CGFloat(i) * 2 + 1
                let y = gridHeight * CGFloat(j) + CGFloat(j) * 2 + 1
                let origin = CGPoint(x: x, y: y)
                let grid = CGRect(origin: origin, size: size)
                context.fill(grid)
            }
        }
        for i in 0 ..< nRows {
            for j in 0 ..< nColumns {
                let x = gridWidth * CGFloat(i) + CGFloat(i) * 2 + 1
                let y = gridHeight * CGFloat(j) + CGFloat(j) * 2 + 1
                let origin = CGPoint(x: x, y: y)
                let grid = CGRect(origin: origin, size: size)
                if let label = dataSource?.grid(at: IndexPath(row: i, section: j)) {
                    draw(
                        "\(label)",
                        with: UIFont.systemFont(ofSize: UIFont.systemFontSize),
                        in: grid
                    )
                }
            }
        }
    }
    
    func draw(_ s: String, with font: UIFont, in contextRect: CGRect) {
        let fontHeight = font.pointSize
        let yOffset = (contextRect.height - fontHeight) / 2.0
        let textRect = CGRect(x: contextRect.minX, y: contextRect.minY + yOffset, width: contextRect.width, height: fontHeight)
        let style: NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        style.alignment = NSTextAlignment.center
        (s as NSString).draw(in: textRect, withAttributes: [NSAttributedString.Key.paragraphStyle: style])
    }
    
    func indexPath(on point: CGPoint) -> IndexPath {
        let i = Int(point.x / (gridWidth + 2))
        let j = Int(point.y / (gridHeight + 2))
        return IndexPath(row: i, section: j)
    }
    
    func rect(for indexPath: IndexPath) -> CGRect {
        let size = CGSize(width: gridWidth, height: gridHeight)

        let i = indexPath.row
        let j = indexPath.section
        let x = gridWidth * CGFloat(i) + CGFloat(i) * 2 + 1
        let y = gridHeight * CGFloat(j) + CGFloat(j) * 2 + 1
        let origin = CGPoint(x: x, y: y)

        return CGRect(origin: origin, size: size)
    }
}
