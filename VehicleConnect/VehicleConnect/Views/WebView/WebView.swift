/********************************************************************************
 * Copyright (c) 2023-24 Harman International
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 ********************************************************************************/

import WebKit
import SwiftUI

/// Webview to display the web pages
struct WebView: UIViewRepresentable {
    enum WorkState: String {
        case initial
        case done
        case working
        case errorOccurred
    }

    var urlString: String
    @Binding var workState: WorkState

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        switch self.workState {
        case .initial:
            if let url = URL(string: self.urlString) {
                uiView.load(URLRequest(url: url))
            }
        default:
            break
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
          self.parent.workState = .working
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            self.parent.workState = .errorOccurred
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            self.parent.workState = .done
        }

        init(_ parent: WebView) {
            self.parent = parent
        }
    }
}
