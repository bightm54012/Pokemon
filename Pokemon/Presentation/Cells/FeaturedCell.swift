//
//  FeaturedCell.swift
//  Pokemon
//
//  Created by Sharon Chao on 2025/11/25.
//

import UIKit

class FeaturedCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let idLabel = UILabel()
    let favoriteButton = UIButton(type: .system)

    var favoriteButtonAction: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        imageView.contentMode = .scaleAspectFit
        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        idLabel.font = .systemFont(ofSize: 14, weight: .regular)
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)

        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(idLabel)
        contentView.addSubview(favoriteButton)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        idLabel.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),

            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            idLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            idLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            favoriteButton.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 8),
            favoriteButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: 24),
            favoriteButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(with pokemon: Pokemon) {
        nameLabel.text = pokemon.name
        idLabel.text = "#\(pokemon.id)"
        
        if let url = pokemon.imageURL {
            Task { [weak self] in
                guard let self = self else { return }
                let image = await ImageLoader.shared.load(url: url)
                await MainActor.run {
                    self.imageView.image = image
                }
            }
        } else {
            imageView.image = nil
        }

        updateFavorite(isFav: FavoritesManager.shared.isFavorite(id: pokemon.id))
    }


    func updateFavorite(isFav: Bool) {
        let sym = isFav ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: sym), for: .normal)
    }
}
