//
//  FeaturedCell.swift
//  Pokemon
//
//  Created by Sharon Chao on 2025/11/25.
//

import UIKit

class FeaturedCell: UICollectionViewCell {
    private let containerView = UIView()
    private let stack = UIStackView()
    
    var pokemons: [Pokemon] = []
    var didSelectPokemon: ((Pokemon) -> Void)?
    var favoriteAction: ((Pokemon) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
        setupStack()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
        setupStack()
    }
    
    private func setupCell() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        clipsToBounds = false
        
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    private func setupStack() {
        stack.axis = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: containerView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    func configure(with pokemons: [Pokemon]) {
        self.pokemons = pokemons
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for poke in pokemons {
            let card = SinglePokemonCardView()
            card.configure(with: poke)
            card.favoriteButtonAction = { [weak self] in
                self?.favoriteAction?(poke)
            }
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
            card.addGestureRecognizer(tap)
            card.isUserInteractionEnabled = true
            
            stack.addArrangedSubview(card)
        }
    }
    
    @objc private func cardTapped(_ gesture: UITapGestureRecognizer) {
        guard let card = gesture.view as? SinglePokemonCardView,
              let index = stack.arrangedSubviews.firstIndex(of: card) else { return }
        let poke = pokemons[index]
        didSelectPokemon?(poke)
    }
}

// MARK: - Single Pokemon Card
class SinglePokemonCardView: UIView {
    private let imageView = UIImageView()
    private let idLabel = UILabel()
    private let nameLabel = UILabel()
    private let typeLabel = UILabel()
    let favoriteButton = UIButton(type: .system)
    
    var favoriteButtonAction: (() -> Void)?
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 0
        
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        imageView.backgroundColor = .systemGray5
        imageView.layer.cornerRadius = 8
        
        idLabel.font = .systemFont(ofSize: 12)
        nameLabel.font = .systemFont(ofSize: 14, weight: .medium)
        typeLabel.font = .systemFont(ofSize: 12)
        typeLabel.numberOfLines = 1
        
        favoriteButton.tintColor = .systemRed
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        favoriteButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        favoriteButton.addTarget(self, action: #selector(didTapFavorite), for: .touchUpInside)
        
        let middleStack = UIStackView(arrangedSubviews: [UIStackView(arrangedSubviews: [idLabel, nameLabel]), typeLabel])
        middleStack.axis = .vertical
        middleStack.spacing = 12
        middleStack.alignment = .leading
        
        let mainStack = UIStackView(arrangedSubviews: [imageView, middleStack, favoriteButton])
        mainStack.axis = .horizontal
        mainStack.alignment = .center
        mainStack.spacing = 8
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with poke: Pokemon) {
        idLabel.text = "#\(poke.id)"
        nameLabel.text = poke.name
        typeLabel.text = poke.types.joined(separator: ", ")
        
        if let url = poke.imageURL {
            Task {
                let image = await ImageLoader.shared.load(url: url)
                await MainActor.run { self.imageView.image = image }
            }
        } else {
            imageView.image = nil
        }
        
        updateFavorite(isFav: FavoritesManager.shared.isFavorite(id: poke.id))
    }
    
    func updateFavorite(isFav: Bool) {
        let sym = isFav ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: sym), for: .normal)
    }
    
    @objc private func didTapFavorite() {
        favoriteButtonAction?()
    }
}

