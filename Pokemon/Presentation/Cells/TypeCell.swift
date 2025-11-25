//
//  TypeCell.swift
//  Pokemon
//
//  Created by Sharon Chao on 2025/11/25.
//

import UIKit

class TypeCell: UICollectionViewCell {
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        contentView.backgroundColor = .lightGray
        contentView.layer.cornerRadius = 8
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func configure(with type: String) {
        label.text = type
    }
}
