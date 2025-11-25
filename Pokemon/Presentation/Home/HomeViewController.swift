//
//  HomeViewController.swift
//  Pokemon
//
//  Created by Sharon Chao on 2025/11/25.
//

import UIKit
import SwiftUI

class HomeViewController: UIViewController {
    // MARK: - UI Elements
    private let featuredLabel: UILabel = {
        let label = UILabel()
        label.text = "Featured Pokémon"
        label.font = .boldSystemFont(ofSize: 24)
        return label
    }()

    private let featuredCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 120, height: 160)
        layout.minimumLineSpacing = 12
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        return cv
    }()

    private let typesLabel: UILabel = {
        let label = UILabel()
        label.text = "Types"
        label.font = .boldSystemFont(ofSize: 24)
        return label
    }()

    private let typesCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 50)
        layout.minimumLineSpacing = 8
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        return cv
    }()

    private let regionsLabel: UILabel = {
        let label = UILabel()
        label.text = "Regions"
        label.font = .boldSystemFont(ofSize: 24)
        return label
    }()

    private let regionsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()

    private let seeMoreButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("See more", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        return btn
    }()

    // Data
    private var featuredPokemons: [Pokemon] = []
    private var types: [String] = []
    private var regions: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Pokémon"
        setupViews()
        setupActions()
        setupCollectionViews()
        loadData()
    }

    private func setupViews() {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        let content = UIStackView(arrangedSubviews: [
            featuredLabel,
            featuredCollection,
            typesLabel,
            typesCollection,
            regionsLabel,
            regionsStack,
            seeMoreButton
        ])
        content.axis = .vertical
        content.spacing = 16
        content.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(content)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 16),
            content.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 16),
            content.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -16),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -16),

            featuredCollection.heightAnchor.constraint(equalToConstant: 160),
            typesCollection.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupActions() {
        seeMoreButton.addTarget(self, action: #selector(didTapSeeMore), for: .touchUpInside)
    }

    private func setupCollectionViews() {
        featuredCollection.dataSource = self
        featuredCollection.delegate = self
        featuredCollection.register(FeaturedCell.self, forCellWithReuseIdentifier: "FeaturedCell")

        typesCollection.dataSource = self
        typesCollection.delegate = self
        typesCollection.register(TypeCell.self, forCellWithReuseIdentifier: "TypeCell")
    }

    private func loadData() {
        // 請呼叫 UseCase / ViewModel 取得資料
        Task {
            do {
                let useCase = FetchPokemonListUseCase(repository: PokemonRepositoryImpl())
                self.featuredPokemons = try await useCase.execute(limit: 9, offset: 0)
                DispatchQueue.main.async { self.featuredCollection.reloadData() }

                let typeUseCase = FetchTypesUseCase(repository: PokemonRepositoryImpl())
                self.types = try await typeUseCase.execute()
                DispatchQueue.main.async { self.typesCollection.reloadData() }

                // Regions 部分：依題目為「前6筆靜態」 → 可用常數陣列
                self.regions = ["Kanto","Johto","Hoenn","Sinnoh","Unova","Kalos"]
                DispatchQueue.main.async { self.setupRegions() }
            } catch {
                print("Load data error: \(error)")
            }
        }
    }

    private func setupRegions() {
        regionsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for region in regions {
            let label = UILabel()
            label.text = region
            label.font = .systemFont(ofSize: 18)
            regionsStack.addArrangedSubview(label)
        }
    }

    @objc private func didTapSeeMore() {
        let listView = PokemonListView()
        let vc = UIHostingController(rootView: listView)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == featuredCollection {
            return featuredPokemons.count
        } else if collectionView == typesCollection {
            return types.count
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == featuredCollection {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeaturedCell", for: indexPath) as? FeaturedCell else {
                return UICollectionViewCell()
            }
            let poke = featuredPokemons[indexPath.item]
            cell.configure(with: poke)
            cell.favoriteButtonAction = { [weak self] in
                FavoritesManager.shared.toggleFavorite(id: poke.id)
                cell.updateFavorite(isFav: FavoritesManager.shared.isFavorite(id: poke.id))
            }
            return cell

        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TypeCell", for: indexPath) as? TypeCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: types[indexPath.item])
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == featuredCollection {
            let poke = featuredPokemons[indexPath.item]
            let detailView = PokemonDetailView(idOrName: "\(poke.id)")
            let vc = UIHostingController(rootView: detailView)
            navigationController?.pushViewController(vc, animated: true)
        } else if collectionView == typesCollection {
            // 若你要實作按 type 篩選，可在此處處理
        }
    }
}
