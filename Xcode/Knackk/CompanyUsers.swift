//
//  CompanyUsers.swift
//  Knackk
//
//  Created by Erik Wetterskog on 12/10/14.
//  Copyright (c) 2014 antiblank. All rights reserved.
//

import Foundation
import CoreData

class CompanyUsers: NSManagedObject {

    @NSManaged var userId: String
    @NSManaged var userName: String
    @NSManaged var emailPrefix: String
    @NSManaged var pictureUrl: String

}
