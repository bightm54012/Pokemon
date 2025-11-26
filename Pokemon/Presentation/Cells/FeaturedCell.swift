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
    private let typesStack = UIStackView()
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
        
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        favoriteButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        favoriteButton.addTarget(self, action: #selector(didTapFavorite), for: .touchUpInside)
        
        typesStack.axis = .horizontal
        typesStack.spacing = 4
        typesStack.alignment = .center
        typesStack.distribution = .fillProportionally
        typesStack.translatesAutoresizingMaskIntoConstraints = false

        let middleStack = UIStackView(arrangedSubviews: [UIStackView(arrangedSubviews: [idLabel, nameLabel]), typesStack])
        middleStack.axis = .vertical
        middleStack.spacing = 4
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
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with poke: Pokemon) {
        idLabel.text = "#\(poke.id)"
        nameLabel.text = poke.name
        
        typesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for type in poke.types {
            let label = createTypeLabel(for: type)
            typesStack.addArrangedSubview(label)
        }

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
        let image: UIImage = isFav ? .pokeballRed : .pokeballGray
        favoriteButton.setImage(image, for: .normal)
        favoriteButton.imageView?.contentMode = .scaleAspectFit
        favoriteButton.contentHorizontalAlignment = .fill
        favoriteButton.contentVerticalAlignment = .fill
    }
    
    private func createTypeLabel(for type: String) -> UILabel {
        let label = PaddingLabel()
        label.text = type.capitalized
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.backgroundColor = UIColor(Pokemon.typeColor(for: type))
        label.layer.cornerRadius = 6
        label.layer.masksToBounds = true
        label.textAlignment = .center
        return label
    }
    
    @objc private func didTapFavorite() {
        favoriteButtonAction?()
    }
}

class PaddingLabel: UILabel {
    var topInset: CGFloat = 4
    var bottomInset: CGFloat = 4
    var leftInset: CGFloat = 10
    var rightInset: CGFloat = 10

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(
            top: topInset,
            left: leftInset,
            bottom: bottomInset,
            right: rightInset
        )
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + leftInset + rightInset,
            height: size.height + topInset + bottomInset
        )
    }
}
