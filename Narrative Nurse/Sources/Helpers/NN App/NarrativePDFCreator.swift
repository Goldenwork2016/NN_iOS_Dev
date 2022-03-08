//
//  PDFGenerator.swift
//  Narrative Nurse
//
//  Created by Voloshyn Slavik on 06.11.2020.
//  Copyright © 2020 Narrative Nurse. All rights reserved.
//

import Foundation
import PDFKit

final class NarrativePDFCreator: NSObject {

    private let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
    private let pageInsets = UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 20)

    private var workingAreaRect: CGRect {
        CGRect(x: self.pageInsets.left,
               y: self.pageInsets.top,
               width: self.pageRect.width - self.pageInsets.left - self.pageInsets.right,
               height: self.pageRect.height - self.pageInsets.top - self.pageInsets.bottom)
    }

    private var cencterPagePoint: CGPoint {
        .init(x: self.pageRect.width/2, y: self.pageRect.height/2)
    }

    let narrative: String

    init(narrative: String) {
        self.narrative = narrative
    }

    func create() -> Data {
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = [kCGPDFContextAuthor as String: "Narrative Nurse"]

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { context in
            context.beginPage()
            let companyNameBottom = addCompanyName()
            addNarrative(startAt: companyNameBottom + 20, context: context)
        }

        return data
    }

    private func addCompanyName() -> CGFloat {
        let titleFont = UIFont.systemFont(ofSize: 14)

        var attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: titleFont]

        let clientNameString = NSAttributedString(string: "Company Name: ", attributes: attributes)

        attributes[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.single.rawValue
        let underlineString = NSAttributedString(string: String(repeating: " ", count: 112), attributes: attributes)

        let attributedString = NSMutableAttributedString()
        attributedString.append(clientNameString)
        attributedString.append(underlineString)
        attributedString.append(NSAttributedString(string: " "))

        let stringSize = attributedString.size()
        let width = self.workingAreaRect.width
        let height = stringSize.height

        let stringRect = CGRect(origin: CGPoint(x: self.pageInsets.left, y: self.pageInsets.top), size: CGSize(width: width, height: height))
        attributedString.draw(in: stringRect)

        return stringRect.origin.y + stringRect.size.height
    }

    private func addClientName(topPoint: CGFloat) -> CGFloat {
        let titleFont = UIFont.systemFont(ofSize: 14)

        var attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: titleFont]

        let clientNameString = NSAttributedString(string: "Client Name: ", attributes: attributes)

        attributes[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.single.rawValue
        let underlineString = NSAttributedString(string: String(repeating: " ", count: 118), attributes: attributes)

        let attributedString = NSMutableAttributedString()
        attributedString.append(clientNameString)
        attributedString.append(underlineString)
        attributedString.append(NSAttributedString(string: " "))

        let stringSize = attributedString.size()
        let width = self.workingAreaRect.width
        let height = stringSize.height

        let stringRect = CGRect(origin: CGPoint(x: self.pageInsets.left, y: topPoint), size: CGSize(width: width, height: height))
        attributedString.draw(in: stringRect)

        return stringRect.origin.y + stringRect.size.height
    }

    private func addDateAndShift(topPoint: CGFloat) -> CGFloat {
        let titleFont = UIFont.systemFont(ofSize: 14)

        var attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: titleFont]

        let dateString = NSAttributedString(string: "Date: ", attributes: attributes)
        let shiftString = NSAttributedString(string: "Shift: ", attributes: attributes)

        attributes[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.single.rawValue
        let underlineString = NSAttributedString(string: String(repeating: " ", count: 56), attributes: attributes)

        let attributedString = NSMutableAttributedString()
        attributedString.append(dateString)
        attributedString.append(underlineString)
        attributedString.append(NSAttributedString(string: String(repeating: " ", count: 10)))
        attributedString.append(shiftString)
        attributedString.append(underlineString)
        attributedString.append(NSAttributedString(string: " "))

        let stringSize = attributedString.size()
        let width = self.workingAreaRect.width
        let height = stringSize.height

        let stringRect = CGRect(origin: CGPoint(x: self.pageInsets.left, y: topPoint), size: CGSize(width: width, height: height))
        attributedString.draw(in: stringRect)

        return stringRect.origin.y + stringRect.size.height
    }

    @discardableResult
    private func addNarrative(startAt: CGFloat, context: UIGraphicsPDFRendererContext) -> CGFloat {
        // 1
        let textFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)

        // 2
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .justified
        paragraphStyle.lineBreakMode = .byWordWrapping

        // 3
        let textAttributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: textFont
        ] as [NSAttributedString.Key: Any]

        //4
        let currentText = CFAttributedStringCreate(nil,
                                                   self.narrative as CFString,
                                                   textAttributes as CFDictionary)
        //5
        let framesetter = CTFramesetterCreateWithAttributedString(currentText!)

        //6
        var currentRange = CFRangeMake(0, 0)
        var currentPage = 0
        var done = false
        var startAt = startAt
        repeat {
            currentPage += 1

            let clientNameBottom = addClientName(topPoint: startAt)
            let dateAndShiftBottom = addDateAndShift(topPoint: clientNameBottom + 20)
            startAt = dateAndShiftBottom + 30

            //8
            /*Draw a logo at the bottom of each page.*/
            drawLogo()
            drawPageNumber(page: currentPage)
            drawLines(startAt: startAt, context: context)

            //9
            /*Render the current page and update the current range to
             point to the beginning of the next page. */
            currentRange = renderNarrativePage(currentPage,
                                      withTextRange: currentRange,
                                      andFramesetter: framesetter,
                                      startAt: startAt)

            //10
            /* If we're at the end of the text, exit the loop. */
            if currentRange.location == CFAttributedStringGetLength(currentText) {
                done = true
            } else {
                //7
                /* Mark the beginning of a new page.*/
                context.beginPage()
                startAt = self.pageInsets.top
            }

        } while !done

        return CGFloat(currentRange.location + currentRange.length)
    }

    private func drawLines(startAt: CGFloat, context: UIGraphicsPDFRendererContext) {
        context.cgContext.setStrokeColor(UIColor.black.cgColor)
        context.cgContext.setLineWidth(1)

        let lineSpacing: CGFloat = 14
        var nextPosition = startAt + lineSpacing
        while nextPosition < self.pageRect.height - self.pageInsets.bottom {
            context.cgContext.move(to: CGPoint(x: self.pageInsets.left, y: nextPosition))
            context.cgContext.addLine(to: CGPoint(x: self.pageRect.width - self.pageInsets.right, y: nextPosition))
            nextPosition += lineSpacing
        }

        context.cgContext.drawPath(using: .fillStroke)
    }

    private func renderNarrativePage(_ pageNum: Int, withTextRange currentRange: CFRange, andFramesetter framesetter: CTFramesetter?, startAt: CGFloat) -> CFRange {
        var currentRange = currentRange
        // Get the graphics context.
        let currentContext = UIGraphicsGetCurrentContext()

        // Put the text matrix into a known state. This ensures
        // that no old scaling factors are left in place.
        currentContext?.textMatrix = .identity

        // Create a path object to enclose the text. Use 72 point
        // margins all around the text.
        let frameRect = CGRect(x: self.pageInsets.left, y: startAt * (-1), width: self.workingAreaRect.width, height: self.pageRect.height - startAt - self.pageInsets.bottom)
        let framePath = CGMutablePath()
        framePath.addRect(frameRect, transform: .identity)

        // Get the frame that will do the rendering.
        // The currentRange variable specifies only the starting point. The framesetter
        // lays out as much text as will fit into the frame.
        let frameRef = CTFramesetterCreateFrame(framesetter!, currentRange, framePath, nil)

        // Core Text draws from the bottom-left corner up, so flip
        // the current transform prior to drawing.
        currentContext?.translateBy(x: 0, y: frameRect.height)
        currentContext?.scaleBy(x: 1.0, y: -1.0)

        // Draw the frame.
        CTFrameDraw(frameRef, currentContext!)

        // Update the current range based on what was drawn.
        currentRange = CTFrameGetVisibleStringRange(frameRef)
        currentRange.location += currentRange.length
        currentRange.length = CFIndex(0)

        return currentRange
    }

    private func drawPageNumber(page: Int) {
        let titleFont = UIFont.systemFont(ofSize: 12)

        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: titleFont]

        let attributedString = NSAttributedString(string: "Page \(page)", attributes: attributes)

        let stringSize = attributedString.size()

        let stringRect = CGRect(origin: CGPoint(x: self.pageInsets.left, y: self.pageRect.height - self.pageInsets.bottom), size: stringSize)
        attributedString.draw(in: stringRect)
    }

    private func drawLogo() {
        let logo = #imageLiteral(resourceName: "logoOneRow")

        let k = logo.size.width / logo.size.height
        let height = self.pageInsets.bottom - 27
        let width = height * k

        let rect = CGRect(x: self.pageRect.width - self.pageInsets.right - width, y: self.pageRect.height - self.pageInsets.bottom + 2, width: width, height: height)

        logo.draw(in: rect)
    }
}
