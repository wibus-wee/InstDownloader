//
//  FooterView.swift
//  InstDownloader
//
//  Created by wibus on 2024/10/26.
//

import SwiftUI

struct FooterView: View {
    var body: some View {
        VStack() {
            Divider()
                .padding()

            HStack(spacing: 10) {
                Text("InstDownloader © Wibus.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("于 2024 年 10 月 20 日发布")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}
