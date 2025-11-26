//
//  PokemonDetailView.swift
//  Pokemon
//
//  Created by Sharon Chao on 2025/11/25.
//

import SwiftUI

struct PokemonDetailView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: PokemonDetailViewModel
    let idOrName: String

    init(idOrName: String) {
        _vm = StateObject(wrappedValue: PokemonDetailViewModel(idOrName: idOrName))
        self.idOrName = idOrName
    }

    var body: some View {
        ZStack {
            if let p = vm.pokemon {
                ScrollView {
                    VStack(spacing: 0) {
                        
                        // MARK: - Dynamic Gradient Header
                        ZStack {
                            p.headerGradient
                                .frame(height: 320)
                                .clipShape(RoundedCornerShape(corners: [.bottomLeft, .bottomRight], radius: 50))
                                .padding(.top, -14)

                            // MARK: Pokemon Image
                            VStack {
                                // MARK: Top Bar
                                HStack {
                                    // Back
                                    Button(action: {
                                        dismiss()
                                    }) {
                                        Image(systemName: "chevron.left")
                                            .font(.title3.bold())
                                            .foregroundColor(.white)
                                            .padding()
                                            .background(Color.white.opacity(0.25))
                                            .clipShape(Circle())
                                    }

                                    Spacer()
                                    
                                    Text("#\(String(format: "%03d", p.id))")
                                        .font(.title2.bold())
                                        .foregroundColor(.white)

                                    Spacer()
                                    
                                    Button(action: {
                                        FavoritesManager.shared.toggleFavorite(id: p.id)
                                        vm.objectWillChange.send()
                                    }) {
                                        Image(uiImage: FavoritesManager.shared.isFavorite(id: p.id)
                                                ? UIImage.pokeball
                                                : UIImage.pokeball_filled
                                        )
                                        .resizable()
                                        .frame(width: 36, height: 36)
                                        .padding(10)
                                        .clipShape(Circle())
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.top, 50)
                                
                                Spacer()
                                
                                RemoteImage(url: p.imageURL)
                                    .frame(width: 220, height: 220)
                                    .clipShape(Circle())
                                    .shadow(radius: 10)
                                    .offset(y: 60)
                            }
                        }
                        
                        Spacer().frame(height: 60)
                        
                        // MARK: NAME
                        Text(p.name.capitalized)
                            .font(.largeTitle.bold())
                        
                        // MARK: TYPE TAGS
                        HStack(spacing: 10) {
                            ForEach(p.types, id: \.self) { type in
                                Text(type.capitalized)
                                    .font(.headline)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(Pokemon.typeColor(for: type))
                                    .foregroundColor(.white)
                                    .cornerRadius(18)
                            }
                        }
                        .padding(.top, 20)

                        // MARK: Weight & Height
                        HStack(spacing: 60) {
                            VStack {
                                Text("\(Double(p.weight)/10, specifier: "%.1f") KG")
                                    .font(.title3.bold())
                                Text("Weight")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            
                            VStack {
                                Text("\(Double(p.height)/10, specifier: "%.1f") M")
                                    .font(.title3.bold())
                                Text("Height")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 20)

                        // MARK: Base Stats Title
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Base Stats")
                                .font(.title2.bold())
                                .padding(.top, 20)

                            StatBar(name: "HP",  value: p.hp,  color: .red)
                            StatBar(name: "ATK", value: p.atk, color: .orange)
                            StatBar(name: "DEF", value: p.def, color: .blue)
                            StatBar(name: "SPD", value: p.spd, color: .cyan)
                        }
                        .padding(.horizontal)
                        .padding(.top, 40)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .ignoresSafeArea(.all)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            Task { await vm.load() }
        }
    }
}

// MARK: - Stat Row Component
struct StatBar: View {
    let name: String
    let value: Int
    let color: Color
    private let maxValue: Double = 255

    var body: some View {
        HStack(spacing: 20) {
            Text(name)
                .font(.system(size: 16).weight(.medium))
                .frame(width: 40, alignment: .leading)
                .foregroundColor(.gray)
            
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 20)

                Capsule()
                    .fill(color)
                    .frame(width: CGFloat(Double(value) / maxValue) * 200, height: 20)
                
                HStack {
                    Spacer()
                    Text("\(value)/255")
                        .font(.system(size: 12).weight(.medium))
                        .frame(width: 60, alignment: .trailing)
                    Spacer()
                }
            }
        }
        
    }
}


// MARK: - Rounded Bottom Corner
struct RoundedCornerShape: Shape {
    var corners: UIRectCorner
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    PokemonDetailView(idOrName: "")
}
