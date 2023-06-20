//
//  LockscreenWidgetBundle.swift
//  LockscreenWidget
//
//  Created by Константин Малков on 19.06.2023.
//

import WidgetKit
import SwiftUI

@main
struct LockscreenWidgetBundle: WidgetBundle {
    var body: some Widget {
        LockscreenWidget()
        LockscreenWidgetLiveActivity()
    }
}
