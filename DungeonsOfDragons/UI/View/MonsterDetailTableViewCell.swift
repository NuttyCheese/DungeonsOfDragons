//
//  MonsterDetailTableViewCell.swift
//  DungeonsOfDragons
//
//  Created by Pavlov Boris on 12.10.2025.
//

import UIKit

final class MonsterDetailTableViewCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, value: String) {
        titleLabel.attributedText = htmlToAttributedString(html: title, textColor: .gray)
        valueLabel.attributedText = htmlToAttributedString(html: value, textColor: .white)
    }
}

private extension MonsterDetailTableViewCell {
    func setupView() {
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .gray
        
        valueLabel.font = UIFont.preferredFont(forTextStyle: .body)
        valueLabel.numberOfLines = 0
        valueLabel.lineBreakMode = .byWordWrapping
        valueLabel.textColor = .white
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.backgroundColor = .black
        stackView.layer.cornerRadius = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)

        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func htmlToAttributedString(html: String, textColor: UIColor) -> NSAttributedString? {
        guard let data = html.data(using: .utf8) else { return nil }
        
        do {
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]
            
            let attributedString = try NSAttributedString(data: data, options: options, documentAttributes: nil)
            
            let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
            mutableAttributedString.addAttribute(.foregroundColor, value: textColor, range: NSRange(location: 0, length: mutableAttributedString.length))
            
            return mutableAttributedString
        } catch {
            print("Ошибка преобразования HTML в аттрибутированный текст: \(error)")
            return nil
        }
    }
}
