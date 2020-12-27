//
//  SheetState.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 24/09/2020.
//

import Combine

class SheetState<State>: ObservableObject {
    @Published var isShowing = false
    @Published var state: State? {
        didSet { isShowing = state != nil }
    }
}
