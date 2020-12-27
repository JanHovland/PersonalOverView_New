//
//  ResizedImage.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 01/10/2020.
//

import SwiftUI

/// Image Resizing Techniques
/// https://nshipster.com/image-resizing/#technique-1-drawing-to-a-uigraphicsimagerenderer
func resizedImage(at url: URL, for size: CGSize) -> UIImage? {
    guard let image = UIImage(contentsOfFile: url.path) else {
        return nil
    }
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { (context) in
        image.draw(in: CGRect(origin: .zero, size: size))
    }
}
