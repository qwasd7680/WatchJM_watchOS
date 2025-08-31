//
//  ZoomableImageView.swift
//  WatchJM
//
//  Created by 周敬博 on 2025/8/26.
//


import SwiftUI
import SDWebImageSwiftUI

struct ZoomableImageView: View {
    let imageURL: URL
    @State private var currentScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    
    var body: some View {
        WebImage(url: imageURL)
            .onSuccess { image, data, cacheType in
            }
            .resizable()
            .aspectRatio(contentMode: .fit)
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .frame(minHeight: 100)
        
            .scaleEffect(currentScale)
            .offset(offset)
            .gesture(
                TapGesture(count: 2)
                    .onEnded {
                        withAnimation(.easeInOut) {
                            currentScale = currentScale == 1.0 ? 2.5 : 1.0
                            offset = .zero
                        }
                    }
            )
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if currentScale > 1.0 {
                            offset = gesture.translation
                        }
                    }
                    .onEnded { _ in }
            )
    }
}
