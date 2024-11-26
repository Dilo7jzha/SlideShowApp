//
//  JSONDocument.swift
//  SlideShowApp
//
//  Created by Bernhard Jenny on 26/11/2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct JSONDocument: FileDocument {
    
    static var readableContentTypes: [UTType] { [.json] }
    var json: Data
    
    init(configuration: ReadConfiguration) throws {
        guard
            let data = configuration.file.regularFileContents
        else { throw NSError() }
        self.json = data
    }
    
    init(json: Data) {
        self.json = json
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: self.json)
    }
}
