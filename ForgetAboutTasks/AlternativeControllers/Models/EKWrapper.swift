//
//  EKWrapper.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 07.03.2023.
//

import UIKit
import CalendarKit
import EventKit

public final class EKWrapper: EventDescriptor {
    public var startDate: Date {
        get {
            return ekEvent.startDate
        }
        set {
            ekEvent.startDate = newValue
        }
    }
    public var endDate: Date {
        get {
            return ekEvent.endDate
        }
        set {
            ekEvent.endDate = newValue
        }
    }
    public var isAllDay: Bool {
        get {
            return ekEvent.isAllDay
        }
        set {
            ekEvent.isAllDay = newValue
        }
    }
    public var text: String {
        get {
            return ekEvent.title
        }
        set {
            ekEvent.title = newValue
        }
    }
  public var attributedText: NSAttributedString?
  public var lineBreakMode: NSLineBreakMode?
  public var color = SystemColors.systemBlue {
    didSet {
      updateColors()
    }
  }
  public var backgroundColor = SystemColors.systemBlue.withAlphaComponent(0.3)
  public var textColor = SystemColors.label
  public var font = UIFont.boldSystemFont(ofSize: 12)
  public var userInfo: Any?
  public weak var editedEvent: EventDescriptor? {
    didSet {
      updateColors()
    }
  }

    public private(set) var ekEvent: EKEvent
    public init(eventKitEvent: EKEvent) {
        self.ekEvent = eventKitEvent
        updateColors()
    }

  public func makeEditable() -> EKWrapper {
      let cloned = Self(eventKitEvent: ekEvent)
      cloned.editedEvent = self
      return cloned
//      let cloned = Event(eventKitEvent: ekEvent)
//    cloned.startDate = startDate
//    cloned.endDate = endDate
//    cloned.isAllDay = isAllDay
//    cloned.text = text
//    cloned.attributedText = attributedText
//    cloned.lineBreakMode = lineBreakMode
//    cloned.color = color
//    cloned.backgroundColor = backgroundColor
//    cloned.textColor = textColor
//    cloned.userInfo = userInfo
//    cloned.editedEvent = self
//    return cloned
  }

  public func commitEditing() {
    guard let edited = editedEvent else {return}
    edited.startDate = startDate
    edited.endDate = endDate
  }

  private func updateColors() {
    (editedEvent != nil) ? applyEditingColors() : applyStandardColors()
  }

  private func applyStandardColors() {
    backgroundColor = color.withAlphaComponent(0.3)
    var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
    textColor = UIColor(hue: h, saturation: s, brightness: b * 0.4, alpha: a)
  }

  private func applyEditingColors() {
    backgroundColor = color
    textColor = .white
  }
}
