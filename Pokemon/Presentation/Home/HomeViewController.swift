//
//  HomeViewController.swift
//  Pokemon
//
//  Created by Sharon Chao on 2025/11/25.
//

import UIKit
import SwiftUI
import Combine

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
        // 一排三個卡片
        let cardWidth = UIScreen.main.bounds.width / 3 - 24 / 3 // margin 調整
        layout.itemSize = CGSize(width: cardWidth, height: 240)
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
    
    private let regionsCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        return cv
    }()
    
    private var regionLocations: [String: Int] = [:]
    
    private let regionsLabel: UILabel = {
        let label = UILabel()
        label.text = "Regions"
        label.font = .boldSystemFont(ofSize: 24)
        return label
    }()
    
    private let featuredSeeMoreButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("See more", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        return btn
    }()
    
    private let typesSeeMoreButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("See more", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        return btn
    }()
    
    private let regionSeeMoreButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("See more", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        return btn
    }()
    
    // Data
    private var featuredPokemons: [Pokemon] = []
    private var types: [String] = []
    private var regions: [String] = []
    private var favoritesCancellable: AnyCancellable?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Pokémon"
        
        setupViews()
        setupCollectionViews()
        setupActions()
        loadData()
        
        favoritesCancellable = FavoritesManager.shared.$favoriteIDs.sink { [weak self] _ in
            self?.featuredCollection.reloadData()
        }
        
        let backButton = UIBarButtonItem()
        backButton.title = ""
        navigationItem.backBarButtonItem = backButton
        navigationController?.navigationBar.tintColor = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func setupViews() {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        
        let featuredHeaderStack = UIStackView(arrangedSubviews: [featuredLabel, featuredSeeMoreButton])
        featuredHeaderStack.axis = .horizontal
        featuredHeaderStack.alignment = .center
        featuredHeaderStack.spacing = 8
        featuredHeaderStack.distribution = .equalSpacing
        
        let typesHeaderStack = UIStackView(arrangedSubviews: [typesLabel, typesSeeMoreButton])
        typesHeaderStack.axis = .horizontal
        typesHeaderStack.alignment = .center
        typesHeaderStack.spacing = 8
        typesHeaderStack.distribution = .equalSpacing
        
        let regionHeaderStack = UIStackView(arrangedSubviews: [regionsLabel, regionSeeMoreButton])
        regionHeaderStack.axis = .horizontal
        regionHeaderStack.alignment = .center
        regionHeaderStack.spacing = 8
        regionHeaderStack.distribution = .equalSpacing
        
        let content = UIStackView(arrangedSubviews: [
            featuredHeaderStack,
            featuredCollection,
            typesHeaderStack,
            typesCollection,
            regionHeaderStack,
            regionsCollection
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
            
            featuredCollection.heightAnchor.constraint(equalToConstant: 240),
            typesCollection.heightAnchor.constraint(equalToConstant: 50),
            regionsCollection.heightAnchor.constraint(equalToConstant: 360)
        ])
        
        featuredSeeMoreButton.addTarget(self, action: #selector(didTapSeeMore), for: .touchUpInside)
    }
    
    private func setupCollectionViews() {
        featuredCollection.dataSource = self
        featuredCollection.delegate = self
        featuredCollection.register(FeaturedCell.self, forCellWithReuseIdentifier: "FeaturedCell")
        
        typesCollection.dataSource = self
        typesCollection.delegate = self
        typesCollection.register(TypeCell.self, forCellWithReuseIdentifier: "TypeCell")
        
        regionsCollection.dataSource = self
        regionsCollection.delegate = self
        regionsCollection.register(RegionCell.self, forCellWithReuseIdentifier: "RegionCell")
    }
    
    private func setupActions() {
        featuredSeeMoreButton.addTarget(self, action: #selector(didTapSeeMore), for: .touchUpInside)
    }
    
    private func loadData() {
        Task {
            do {
                // featured
                let listUseCase = FetchPokemonListUseCase(repository: PokemonRepositoryImpl())
                self.featuredPokemons = try await listUseCase.execute(limit: 9, offset: 0)
                
                // types
                let typeUseCase = FetchTypesUseCase(repository: PokemonRepositoryImpl())
                self.types = try await typeUseCase.execute()
                
                let regionUseCase = FetchRegionsUseCase(repository: PokemonRepositoryImpl())
                let allRegions = try await regionUseCase.execute()
                self.regions = Array(allRegions.prefix(6)).map { $0.name }
                
                await loadRegionCounts()
                
                DispatchQueue.main.async {
                    self.featuredCollection.reloadData()
                    self.typesCollection.reloadData()
                    self.regionsCollection.reloadData()
                }
            } catch {
                print("Load data error: \(error)")
            }
        }
    }
    
    private func loadRegionCounts() async {
        guard !regions.isEmpty else { return }
        let repo = PokemonRepositoryImpl()
        var map: [String: Int] = [:]

        for region in regions {
            do {
                // PokeAPI region endpoint expects name in lowercase; ensure correct format
                let detail = try await repo.fetchRegionDetail(name: region.lowercased())
                map[region] = detail.locations.count
            } catch {
                print("failed to fetch region \(region): \(error)")
                map[region] = 0
            }
        }

        DispatchQueue.main.async {
            self.regionLocations = map
        }
    }
    
    @objc private func didTapSeeMore() {
        let listView = PokemonListView()
        let vc = UIHostingController(rootView: listView)
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UICollectionView DataSource / Delegate
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == featuredCollection {
            return Int(ceil(Double(featuredPokemons.count) / 3.0))
        } else if collectionView == typesCollection {
            return types.count
        } else {
            return regions.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == featuredCollection {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeaturedCell", for: indexPath) as? FeaturedCell else {
                return UICollectionViewCell()
            }
            let start = indexPath.item * 3
            let end = min(start + 3, featuredPokemons.count)
            let pokesForCell = Array(featuredPokemons[start..<end])
            cell.configure(with: pokesForCell)
            
            // favorite 按鈕
            cell.favoriteAction = { poke in
                FavoritesManager.shared.toggleFavorite(id: poke.id)
                collectionView.reloadData()
            }
            
            // 3. 點擊回傳 Pokémon
            cell.didSelectPokemon = { [weak self] poke in
                let detailView = PokemonDetailView(idOrName: "\(poke.id)")
                let vc = UIHostingController(rootView: detailView)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            
            return cell
        } else if collectionView == typesCollection {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TypeCell", for: indexPath) as? TypeCell else {
                return UICollectionViewCell()
            }
            let type = types[indexPath.item]
            cell.configure(with: type)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RegionCell", for: indexPath) as! RegionCell
            let region = regions[indexPath.item]
            let count = regionLocations[region] ?? 0
            cell.configure(name: region, count: count)
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
            
        }
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == featuredCollection {
            return CGSize(width: 280, height: 240)
        } else if collectionView == typesCollection {
            return CGSize(width: 100, height: 50)
        } else {
            let totalSpacing: CGFloat = 12
            let width = (collectionView.bounds.width - totalSpacing) / 2
            return CGSize(width: width, height: 100)
        }
    }
}
