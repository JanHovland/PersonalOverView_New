//
//  SwiftActivityIndicator.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 13/11/2020.
//

import SwiftUI

/// https://medium.com/swiftui-made-easy/activity-view-controller-in-swiftui-593fddadee79
/// https://www.hackingwithswift.com/articles/118/uiactivityviewcontroller-by-example

struct ActivityIndicator: UIViewRepresentable {
    
    /// Plasser ActivityIndicator(isAnimating: $indicatorShowing, style: .medium, color: .gray)
    /// hvor det ikke kommer warning : Result of 'ActivityIndicator' initializer is unused
    /// Sett verdien av indicatorShowing til true for å starte ActivityIndicator
    /// Sett verdien av indicatorShowing til false for å avslutte ActivityIndicator

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style
    let color: UIColor

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        let indicatorView = UIActivityIndicatorView(style: style)
        indicatorView.color = color
        return indicatorView
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]?
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems,
                                 applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController,
                                context: UIViewControllerRepresentableContext<ActivityView>) {}
}

/*
view.sheet(isPresented: $isSheetPresented) {
 ActivityView(activityItems: ["Check out my app!",  SignUpView()], applicationActivities: [])
}
*/
