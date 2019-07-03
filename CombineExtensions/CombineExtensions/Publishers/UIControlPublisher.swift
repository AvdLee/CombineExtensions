//
//  UIControlPublisher.swift
//  CombineExtensions
//
//  Created by Antoine van der Lee on 03/07/2019.
//  Copyright © 2019 SwiftLee. All rights reserved.
//

import Foundation
import UIKit
import Combine

/// A custom subscription to capture UIControl target events.
final class UIControlSubscription<SubscriberType: Subscriber, Control: UIControl>: Subscription where SubscriberType.Input == Control {
    private var subscriber: SubscriberType?
    private let control: Control

    init(subscriber: SubscriberType, control: Control, event: UIControl.Event) {
        self.subscriber = subscriber
        self.control = control
        control.addTarget(self, action: #selector(eventHandler), for: event)
    }

    func request(_ demand: Subscribers.Demand) {
        // We do nothing here as we only want to send events when they occur.
        // See, for more info: https://developer.apple.com/documentation/combine/subscribers/demand
    }

    func cancel() {
        subscriber = nil
    }

    @objc private func eventHandler() {
        _ = subscriber?.receive(control)
    }

    deinit {
        print("UIControlTarget deinit")
    }
}

/// A custom `Publisher` to work with our custom `UIControlSubscription`.
public struct UIControlPublisher<Control: UIControl>: Publisher {

    public typealias Output = Control
    public typealias Failure = Never

    let control: Control
    let controlEvents: UIControl.Event

    public init(control: Control, events: UIControl.Event) {
        self.control = control
        self.controlEvents = events
    }

    /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
    ///
    /// - SeeAlso: `subscribe(_:)`
    /// - Parameters:
    ///     - subscriber: The subscriber to attach to this `Publisher`.
    ///                   once attached it can begin to receive values.
    public func receive<S>(subscriber: S) where S : Subscriber, S.Failure == UIControlPublisher.Failure, S.Input == UIControlPublisher.Output {
        subscriber.receive(subscription: UIControlSubscription(subscriber: subscriber, control: control, event: controlEvents))
    }
}

/// Extending the `UIControl` types to be able to produce a `UIControl.Event` publisher.
extension CombineCompatible where Self: UIControl {
    public func publisher(for events: UIControl.Event) -> UIControlPublisher<Self> {
        return UIControlPublisher(control: self, events: events)
    }
}
