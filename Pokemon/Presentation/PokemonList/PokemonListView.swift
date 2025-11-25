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
        HStack {
            RemoteImage(url: pokemon.imageURL)
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading) {
                Text(pokemon.name)
                    .font(.headline)
                Text("#\(pokemon.id)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(pokemon.types.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            
            Button(action: {
                favorites.toggleFavorite(id: pokemon.id)
            }) {
                Image(systemName: favorites.isFavorite(id: pokemon.id) ? "heart.fill" : "heart")
                    .foregroundColor(.red)
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
