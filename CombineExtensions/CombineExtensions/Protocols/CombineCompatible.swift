//
//  CombineCompatible.swift
//  CombineExtensions
//
//  Created by Antoine van der Lee on 03/07/2019.
//  Copyright © 2019 SwiftLee. All rights reserved.
//

import Foundation
import UIKit
import Combine

public protocol CombineCompatible { }
extension UIControl: CombineCompatible { }

extension CombineCompatible {
    public func assign<P: Publisher>(_ publisher: P, to keyPath: ReferenceWritableKeyPath<Self, P.Output>) -> AnyCancellable where P.Failure == Never {
        return publisher.assign(to: keyPath, on: self)
    }
}
