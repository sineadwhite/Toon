//
//  JSONParsable.swift
//  4Click
//
//  Created by Hardik Davda on 9/11/17.
//  Copyright © 2017 SLP-World. All rights reserved.
//

import Foundation

typealias JSONType = [String: Any]

protocol JSONParsable {
    init?(json: JSONType?)
}
