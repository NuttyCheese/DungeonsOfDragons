//
//  Ext+UIImage.swift
//  DungeonsOfDragons
//
//  Created by Pavlov Boris on 12.10.2025.
//

import UIKit

extension UIImage {
    func loadPromoImage(from urlString: String, completion: @escaping (UIImage?) -> ()) {
        guard let url = URL(string: Link.urlImage + urlString) else {
            completion(nil)
            return
        }
        
        if let cachedImage = ImageCache.shared.image(forKey: urlString) {
            DispatchQueue.main.async {
                completion(cachedImage)
            }
        } else {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    print("\(#file.components(separatedBy: "/").last ?? "") \(#function) \(#line)\nОшибка загрузки изображения: \(error)\n")
                    DispatchQueue.main.async {
                        completion(Images.notPhoto.image)
                    }
                    return
                }
                
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        ImageCache.shared.save(image, forKey: urlString)
                        completion(image)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(Images.notPhoto.image)
                    }
                }
            }.resume()
        }
    }
    
    func resize(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
