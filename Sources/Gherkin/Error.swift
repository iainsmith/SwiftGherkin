//
//  Error.swift
//  Gherkin
//
//  Created by iainsmith on 28/03/2018.
//

enum GherkinError: Error {
    case standard
    case noFile(path: String)
}
