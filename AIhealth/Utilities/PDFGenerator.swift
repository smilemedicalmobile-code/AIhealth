//
//  PDFGenerator.swift
//  AIhealth
//
//  Created on 2025-10-28.
//

import UIKit
import PDFKit

class PDFGenerator {
    static func generatePDF(from summary: String, patientName: String = "환자") -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "AIhealth",
            kCGPDFContextAuthor: "AI Health App",
            kCGPDFContextTitle: "건강 상담 결과"
        ]

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 8.5 * 72.0
        let pageHeight = 11.0 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let margin: CGFloat = 40

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let fileName = "건강상담결과_\(patientName)_\(Int(Date().timeIntervalSince1970)).pdf"
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let pdfURL = documentsPath.appendingPathComponent(fileName)

        do {
            try renderer.writePDF(to: pdfURL) { context in
                context.beginPage()

                var currentY: CGFloat = margin

                // Title
                let titleAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 24),
                    .foregroundColor: UIColor.black
                ]
                let title = "건강 상담 결과"
                let titleSize = title.size(withAttributes: titleAttributes)
                title.draw(at: CGPoint(x: margin, y: currentY), withAttributes: titleAttributes)
                currentY += titleSize.height + 20

                // Date
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy년 MM월 dd일"
                let dateString = "작성일: \(dateFormatter.string(from: Date()))"

                let dateAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.gray
                ]
                dateString.draw(at: CGPoint(x: margin, y: currentY), withAttributes: dateAttributes)
                currentY += 30

                // Divider
                let dividerPath = UIBezierPath()
                dividerPath.move(to: CGPoint(x: margin, y: currentY))
                dividerPath.addLine(to: CGPoint(x: pageWidth - margin, y: currentY))
                UIColor.lightGray.setStroke()
                dividerPath.stroke()
                currentY += 20

                // Content
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 6

                let attributedSummary = NSAttributedString(
                    string: summary,
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 14),
                        .foregroundColor: UIColor.black,
                        .paragraphStyle: paragraphStyle
                    ]
                )

                let contentRect = CGRect(
                    x: margin,
                    y: currentY,
                    width: pageWidth - 2 * margin,
                    height: pageHeight - currentY - margin
                )

                attributedSummary.draw(in: contentRect)

                // Footer
                let footer = "본 문서는 AI 건강 상담 결과로, 의료진의 진단을 대체하지 않습니다."
                let footerAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 10),
                    .foregroundColor: UIColor.gray
                ]

                let footerY = pageHeight - margin
                footer.draw(at: CGPoint(x: margin, y: footerY), withAttributes: footerAttributes)
            }

            return pdfURL
        } catch {
            print("Failed to create PDF: \(error)")
            return nil
        }
    }

    static func sharePDF(url: URL, from viewController: UIViewController) {
        let activityViewController = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )

        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = viewController.view
            popoverController.sourceRect = CGRect(x: viewController.view.bounds.midX,
                                                  y: viewController.view.bounds.midY,
                                                  width: 0,
                                                  height: 0)
            popoverController.permittedArrowDirections = []
        }

        viewController.present(activityViewController, animated: true)
    }
}
