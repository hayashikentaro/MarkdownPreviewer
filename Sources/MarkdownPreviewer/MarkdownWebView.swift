import SwiftUI
import WebKit

struct MarkdownWebView: NSViewRepresentable {
    let html: String
    let baseURL: URL?
    let onOpenURL: (URL) -> Bool
    let onWebViewReady: (WKWebView?) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onOpenURL: onOpenURL, onWebViewReady: onWebViewReady)
    }

    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = false

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsMagnification = true
        webView.setValue(false, forKey: "drawsBackground")
        context.coordinator.onWebViewReady(webView)
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(html, baseURL: baseURL)
    }

    static func dismantleNSView(_ webView: WKWebView, coordinator: Coordinator) {
        coordinator.onWebViewReady(nil)
        webView.navigationDelegate = nil
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        let onOpenURL: (URL) -> Bool
        let onWebViewReady: (WKWebView?) -> Void

        init(
            onOpenURL: @escaping (URL) -> Bool,
            onWebViewReady: @escaping (WKWebView?) -> Void
        ) {
            self.onOpenURL = onOpenURL
            self.onWebViewReady = onWebViewReady
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard navigationAction.navigationType == .linkActivated,
                  let url = navigationAction.request.url
            else {
                decisionHandler(.allow)
                return
            }

            let allowedSchemes = ["file", "http", "https", "mailto"]
            guard let scheme = url.scheme?.lowercased(), allowedSchemes.contains(scheme) else {
                decisionHandler(.cancel)
                return
            }

            guard onOpenURL(url) else {
                decisionHandler(.allow)
                return
            }

            decisionHandler(.cancel)
        }
    }
}
