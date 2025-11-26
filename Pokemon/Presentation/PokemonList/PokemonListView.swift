//
//  PokemonListView.swift
//  Pokemon
//
//  Created by Sharon Chao on 2025/11/25.
//

import SwiftUI

struct PokemonListView: View {
    @StateObject private var vm = PokemonListViewModel()
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(vm.pokemons) { pokemon in
                    NavigationLink(destination: PokemonDetailView(idOrName: "\(pokemon.id)")) {
                        SinglePokemonCardListItem(pokemon: pokemon)
                            .task { if pokemon == vm.pokemons.last { await vm.loadMore() } }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                
                if vm.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .padding()
                }
            }
            .padding(.bottom, 16)
        }
        .navigationBarHidden(false)
        .background(Color(.systemGray5))
        .navigationTitle("All Pokémon")
        .task {
            await vm.loadInitial()
        }
    }
}

struct SinglePokemonCardListItem: View {
    let pokemon: Pokemon
    @ObservedObject private var favorites = FavoritesManager.shared
    
    var body: some View {
        HStack(spacing: 12) {
            RemoteImage(url: pokemon.imageURL)
                .frame(width: 60, height: 60)
                .background(Color(uiColor: .systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading) {
                Text(pokemon.name)
                    .font(.headline)
                Text("#\(pokemon.id)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                HStack(spacing: 4) {
                    ForEach(pokemon.types, id: \.self) { type in
                        Text(type.capitalized)
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Pokemon.typeColor(for: type))
                            .cornerRadius(6)
                    }
                }
            }
            Spacer()
            
            Button(action: {
                favorites.toggleFavorite(id: pokemon.id)
            }) {
                Image(uiImage: favorites.isFavorite(id: pokemon.id) ? UIImage.pokeball : UIImage.pokeball_filled
                )
                .resizable()
                .frame(width: 24, height: 24)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    PokemonListView()
}
