//
//  PokemonDetailView.swift
//  Pokemon
//
//  Created by Sharon Chao on 2025/11/25.
//

import SwiftUI

struct PokemonDetailView: View {
    @StateObject private var vm: PokemonDetailViewModel
    let idOrName: String
    
    init(idOrName: String) {
        _vm = StateObject(wrappedValue: PokemonDetailViewModel(idOrName: idOrName))
        self.idOrName = idOrName
    }
    
    var body: some View {
        VStack {
            if let p = vm.pokemon {
                ScrollView {
                    VStack(spacing: 20) {
                        RemoteImage(url: p.imageURL)
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                            .shadow(radius: 10)

                        Text(p.name)
                            .font(.largeTitle)
                            .bold()

                        HStack {
                            ForEach(p.types, id: \.self) { t in
                                Text(t.capitalized)
                                    .padding(8)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("ID: \(p.id)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        Spacer()
                    }
                    .padding()
                }
            } else if vm.isLoading {
                ProgressView()
            } else if let error = vm.error {
                Text("Error: \(error.localizedDescription)")
            } else {
                EmptyView()
            }
        }
        .navigationTitle("Detail")
        .onAppear {
            Task {
                await vm.load()
            }
        }
    }
}


#Preview {
    PokemonDetailView(idOrName: "")
}
