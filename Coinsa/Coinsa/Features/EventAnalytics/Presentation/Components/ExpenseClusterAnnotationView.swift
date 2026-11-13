//
//  ExpenseClusterAnnotationView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 24.04.2026.
//

import MapKit
import SwiftUI

/// Групповая метка с общей иконкой траты и количеством участников.
final class ExpenseClusterAnnotationView: MKAnnotationView {
    private let iconView = UIImageView(image: UIImage(systemName: Expense.secondaryIcon))
    private let countLabel = UILabel()

    override init(annotation: (any MKAnnotation)?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor(Expense.accentColor)
        
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        
        countLabel.textColor = .white
        countLabel.font = .monospacedDigitSystemFont(ofSize: 14, weight: .semibold)
        
        addSubview(iconView)
        addSubview(countLabel)
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.35
        layer.shadowRadius = 5
        layer.shadowOffset = CGSize(width: 0, height: 3)
        
        collisionMode = .rectangle
        displayPriority = .defaultHigh
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()
        
        guard let cluster = annotation as? MKClusterAnnotation else { return }
        
        countLabel.text = String(cluster.memberAnnotations.count)
        let labelSize = countLabel.sizeThatFits(CGSize(width: 200, height: 40))
        bounds = CGRect(x: 0, y: 0, width: 44 + labelSize.width, height: 40)
        layer.cornerRadius = 20
        iconView.frame = CGRect(x: 12, y: 10, width: 18, height: 20)
        countLabel.frame = CGRect(x: 35, y: 0, width: labelSize.width, height: 40)
    }
}
