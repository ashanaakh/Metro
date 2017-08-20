//
//  Searcher.swift
//  Metro
//
//  Created by Ali on 5/8/17.
//  Copyright © 2017 Ali. All rights reserved.
//

import Foundation

// MARK: Modefied Depth-First-Search
class Searcher {

    let matrix: [[Double]]
    var paths: [[Int]]

    init(matrix: [[Double]]) {
        self.matrix = matrix
        paths = []
    }

    func search(start: Int, end: Int) {
        paths = []
        search(start: start, end: end, path: [])
    }

    private func search(start: Int, end: Int, path: [Int]) {
        for (index, value) in matrix[start].enumerated() {
            if !path.contains(index) && value != 0 {
                if index != end {
                    search(start: index, end: end, path: path + [start]);
                } else {
                    paths.append(path + [start, index]);
                }
            }
        }
    }
}
