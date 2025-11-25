//
//  RemoteImage.swift
//  Pokemon
//
//  Created by Sharon Chao on 2025/11/25.
//

import SwiftUI

struct RemoteImage: View {
    let url: URL?
    @State private var image: Image? = nil

    var body: some View {
        Group {
            if let image = image { image.resizable().aspectRatio(contentMode: .fit) }
            else { Rectangle().foregroundColor(.gray.opacity(0.2)) }
        }
        .task {
            await load()
        }
    }

    private func load() async {
        if let ui = await ImageLoader.shared.load(url: url) {
            image = Image(uiImage: ui)
        }
    }
}
