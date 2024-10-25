//
//  SearchView.swift
//  InstDownloader
//
//  Created by wibus on 2024/10/24.
//

import SwiftUI


struct SearchView: View {
    @Binding var searchText: String
    var onSearch: () -> Void
    
    var body: some View {
        HStack {
            TextField("搜索伴奏", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("搜索", action: onSearch)
        }
        .padding()
    }
}
