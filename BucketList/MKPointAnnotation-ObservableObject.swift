//
//  MKPointAnnotation-ObservableObject.swift
//  BucketList
//
//  Created by Jules Lee on 1/15/20.
//  Copyright © 2020 Jules Lee. All rights reserved.
//

import MapKit

extension MKPointAnnotation: ObservableObject {
    public var wrappedTitle: String {
        get {
            self.title ?? "Unknown value"
        }

        set {
            title = newValue
        }
    }

    public var wrappedSubtitle: String {
        get {
            self.subtitle ?? "Unknown value"
        }

        set {
            subtitle = newValue
        }
    }
}
