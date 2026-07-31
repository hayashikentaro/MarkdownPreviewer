import SwiftUI
import WebKit

struct MarkdownWebView: NSViewRepresentable {
    let html: String
    let baseURL: URL?
    let onOpenURL: (URL) -> Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(onOpenURL: onOpenURL)
    }

    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = false

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsMagnification = true
        webView.setValue(false, forKey: "drawsBackground")
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(html, baseURL: baseURL)
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        let onOpenURL: (URL) -> Bool

        init(onOpenURL: @escaping (URL) -> Bool) {
            self.onOpenURL = onOpenURL
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
