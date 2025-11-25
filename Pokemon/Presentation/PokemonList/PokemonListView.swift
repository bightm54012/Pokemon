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
        NavigationView {
            List {
                ForEach(vm.pokemons) { pokemon in
                    NavigationLink(destination: PokemonDetailView(idOrName: "\(pokemon.id)")) {
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
                            }
                        }
                    }
                    .task {
                        if pokemon == vm.pokemons.last {
                            await vm.loadMore()
                        }
                    }
                }

                if vm.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
            .navigationTitle("Pokémon List")
            .task {
                await vm.loadInitial()
            }
        }
    }
}

#Preview {
    PokemonListView()
}
