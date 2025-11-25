//
//  ImageLoader.swift
//  Pokemon
//
//  Created by Sharon Chao on 2025/11/25.
//

import UIKit

final class ImageLoader {
    static let shared = ImageLoader()
    private let cache = NSCache<NSURL, UIImage>()
    
    private init() {}
    
    func load(url: URL?) async -> UIImage? {
        guard let url = url else { return nil }
        if let img = cache.object(forKey: url as NSURL) { return img }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let img = UIImage(data: data) {
                cache.setObject(img, forKey: url as NSURL)
                return img
            }
            return nil
        } catch { return nil }
    }
}
