//
//  PDFCreator.swift
//  SQLManager
//
//  Created by Никита Пивоваров on 15.03.2023.
//

import Foundation
import CoreGraphics
import UIKit
import Algorithms

class PDFCreator {
    
    let defaultOffset: CGFloat = 20
    let tableDataHeaderTitles: [String]
    let tableDataItems: [[String]]
    
    init(tableDataItems: [[String]], tableDataHeaderTitles: [String]) {
        self.tableDataItems = tableDataItems
        self.tableDataHeaderTitles = tableDataHeaderTitles
    }
    
    func create() -> Data {
        // default page format
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: UIGraphicsPDFRendererFormat())
        
        let data = renderer.pdfData { context in
            context.beginPage()
            let cgContext = context.cgContext
            drawTableHeaderRect(drawContext: cgContext, pageRect: pageRect)
            drawTableHeaderTitles(drawContext: cgContext, pageRect: pageRect)
            drawTableContentInnerBordersAndText(context: context, drawContext: cgContext, pageRect: pageRect)
        }
        return data
    }
    
    func calculateNumberOfElementsPerPage(with pageRect: CGRect) -> Int {
        let rowHeight = (defaultOffset * 3)
        let number = Int((pageRect.height - rowHeight) / rowHeight)
        return number
    }
}

extension PDFCreator {
    
    func drawTableHeaderRect(drawContext: CGContext, pageRect: CGRect) {
        drawContext.saveGState()
        drawContext.setLineWidth(3.0)
        
        // Draw header's 1 top horizontal line
        drawContext.move(to: CGPoint(x: defaultOffset, y: defaultOffset))
        drawContext.addLine(to: CGPoint(x: pageRect.width - defaultOffset, y: defaultOffset))
        drawContext.strokePath()
        
        // Draw header's 1 bottom horizontal line
        drawContext.move(to: CGPoint(x: defaultOffset, y: defaultOffset * 3))
        drawContext.addLine(to: CGPoint(x: pageRect.width - defaultOffset, y: defaultOffset * 3))
        drawContext.strokePath()
        
        // Draw header's vertical lines
        drawContext.setLineWidth(2.0)
        drawContext.saveGState()
        let tabWidth = (pageRect.width - defaultOffset * 2) / CGFloat(tableDataHeaderTitles.count)
        for verticalLineIndex in 0...tableDataHeaderTitles.count {
            let tabX = CGFloat(verticalLineIndex) * tabWidth
            drawContext.move(to: CGPoint(x: tabX + defaultOffset, y: defaultOffset))
            drawContext.addLine(to: CGPoint(x: tabX + defaultOffset, y: defaultOffset * 3))
            drawContext.strokePath()
        }
        
        drawContext.restoreGState()
    }
    
    func drawTableHeaderTitles(drawContext: CGContext, pageRect: CGRect) {
        // prepare title attributes
        let textFont = UIFont.systemFont(ofSize: 16.0, weight: .medium)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping
        let titleAttributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: textFont
        ]
        
        // draw titles
        let tabWidth = (pageRect.width - defaultOffset * 2) / CGFloat(tableDataHeaderTitles.count)
        for titleIndex in 0..<tableDataHeaderTitles.count {
            let attributedTitle = NSAttributedString(string: tableDataHeaderTitles[titleIndex].capitalized, attributes: titleAttributes)
            let tabX = CGFloat(titleIndex) * tabWidth
            let textRect = CGRect(x: tabX + defaultOffset,
                                  y: defaultOffset * 3 / 2,
                                  width: tabWidth,
                                  height: defaultOffset * 2)
            attributedTitle.draw(in: textRect)
        }
    }
    
    func drawTableContentInnerBordersAndText(context: UIGraphicsPDFRendererContext, drawContext: CGContext, pageRect: CGRect) {
        drawContext.setLineWidth(1.0)
        drawContext.saveGState()
        
        let defaultStartY = defaultOffset * 3
        
        let chunked = tableDataItems.chunks(ofCount: 11)
        
        chunked.enumerated().forEach { (value, chunk) in
            var multiplier = 0
            for elementIndex in chunk.startIndex..<chunk.endIndex {
                let yPosition = CGFloat(multiplier) * defaultStartY + defaultStartY
                multiplier += 1
                // Draw content's elements texts
                let textFont = UIFont.systemFont(ofSize: 13.0, weight: .regular)
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                paragraphStyle.lineBreakMode = .byWordWrapping
                let textAttributes = [
                    NSAttributedString.Key.paragraphStyle: paragraphStyle,
                    NSAttributedString.Key.font: textFont
                ]
                let tabWidth = (pageRect.width - defaultOffset * 2) / CGFloat(tableDataHeaderTitles.count)
                
                for titleIndex in 0..<tableDataHeaderTitles.count {
                    let attributedText = NSAttributedString(string: chunk[elementIndex][titleIndex], attributes: textAttributes)
                    let tabX = CGFloat(titleIndex) * tabWidth
                    let textRect = CGRect(x: tabX + defaultOffset,
                                          y: yPosition + defaultOffset,
                                          width: tabWidth,
                                          height: defaultOffset * 3)
                    attributedText.draw(in: textRect)
                }
                
                // Draw content's vertical lines
                for verticalLineIndex in 0...tableDataHeaderTitles.count {
                    let tabX = CGFloat(verticalLineIndex) * tabWidth
                    drawContext.move(to: CGPoint(x: tabX + defaultOffset, y: yPosition))
                    drawContext.addLine(to: CGPoint(x: tabX + defaultOffset, y: yPosition + defaultStartY))
                    drawContext.strokePath()
                }
                
                // Draw content's element bottom horizontal line
                drawContext.move(to: CGPoint(x: defaultOffset, y: yPosition + defaultStartY))
                drawContext.addLine(to: CGPoint(x: pageRect.width - defaultOffset, y: yPosition + defaultStartY))
                drawContext.strokePath()
            }
            drawTableHeaderRect(drawContext: drawContext, pageRect: pageRect)
            drawTableHeaderTitles(drawContext: drawContext, pageRect: pageRect)
            if value != chunked.count - 1 {
                context.beginPage()
            }
        }
        drawContext.restoreGState()
    }
}
