//
//  View+Extensions.swift
//  ArView
//
//  Created by Prabal Kumar on 09/10/24.
//

import SwiftUI

extension View {
    @ViewBuilder func hidden(_ shouldHide: Bool) -> some View {
        switch shouldHide {
        case true: self.hidden()
        case false: self
        }
    }
}
