//
//  IndexedTableViewHelper.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 10/12/2020.
//

import SwiftUI 

struct SectionIndexTitles: View {
    let proxy: ScrollViewProxy
    let titles: [String]
    @GestureState private var dragLocation: CGPoint = .zero
    
    var body: some View {
        VStack {
            ForEach(titles, id: \.self) { title in
                SectionIndexTitle(text: title)
                    .background(dragObserver(title: title))
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .updating($dragLocation) { value, state, _ in
                    state = value.location
                }
        )
    }
    
    func dragObserver(title: String) -> some View {
        GeometryReader { geometry in
            dragObserver(geometry: geometry, title: title)
        }
    }
    
    func dragObserver(geometry: GeometryProxy, title: String) -> some View {
        if geometry.frame(in: .global).contains(dragLocation) {
            DispatchQueue.main.async {
                proxy.scrollTo(title, anchor: .top)
            }
        }
        return Rectangle().fill(Color.clear)
    }
    
}

struct SectionIndexTitle: View {
    var text: String
    var body: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .foregroundColor(Color.gray.opacity(0.01))
            .frame(width: 30, height: 8)
            .overlay(
                Text(text)
                    .foregroundColor(.accentColor)
                    .font(Font.footnote.weight(.medium))
            )
    }
}

func sectionIndexTitles(proxy: ScrollViewProxy,
                        titles: [String]) -> some View {
    /// .sorted på sectionHeader gir default sortering, må derfor ta dette bort siden korrekt sortering skjer i "refresh"
    /// SectionIndexTitles(proxy: proxy, titles: sectionHeader.sorted())
    SectionIndexTitles(proxy: proxy, titles: titles)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding()
}

struct SectionHeader: View {
    var letter: String
    var body: some View {
        Text(letter).id(letter)
            .foregroundColor(.accentColor)
            .font(Font.title.weight(.light))
    }
}
