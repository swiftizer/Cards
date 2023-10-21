//
//  Array+pagination.swift
//  API V1
//
//  Created by ser.nikolaev on 17.10.2023.
//

import Foundation

extension Array {
    func paginate(limit: Int, offset: Int?) -> Array {
        let start = offset ?? 0
        let end = Swift.min(start + limit, count)
        if (start < end) {
            return Array(self[start..<end])
        }
        return []
    }
}

