//
//  AsyncImage.swift
//  SRCarPlay
//
//  Created by Johan Thureson on 2024-06-26.
//

import SwiftUI

struct AsyncImage: View {
    @StateObject private var loader: ImageLoader
    private var placeholder: Image

    init(url: URL, placeholder: Image = Image(systemName: "photo.circle.fill")) {
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
        self.placeholder = placeholder
    }

    var body: some View {
        content
            .onAppear(perform: loader.load)
    }

    private var content: some View {
        Group {
            if let uiImage = loader.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                placeholder
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
    }
}
