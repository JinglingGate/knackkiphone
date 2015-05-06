//
//  ImageCache.swift
//  Knackk
//
//  Created by Erik Wetterskog on 12/18/14.
//  Copyright (c) 2014 antiblank. All rights reserved.
//

import Foundation
import CoreData

class ImageCache: NSManagedObject {

    @NSManaged var urlString: String
    @NSManaged var lastUsage: Double
    @NSManaged var imageData: NSData
    @NSManaged var imageType: String

}
