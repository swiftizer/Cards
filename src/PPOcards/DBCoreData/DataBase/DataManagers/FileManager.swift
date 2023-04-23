//
//  FileManager.swift
//  PPOcards
//
//  Created by Сергей Николаев on 09.04.2023.
//

import UIKit

protocol FileManagerDescription {
    func putImageToFS(with image: UIImage) -> URL?
    func getImageFromFS(path: URL?) -> UIImage?
    func deleteFile(at path: URL?)
    func getDocumentDirUrl() -> URL?
}

enum FileError: Error {
    case invalidUrl
    case emptyData
}

final class MyFileManager: FileManagerDescription {
    static let shared: FileManagerDescription = MyFileManager()

    private init() {}

    func putImageToFS(with image: UIImage) -> URL? {
        guard let documentsUrl = getDocumentDirUrl() else {
            print("documentsUrl Error!")
            return nil
        }

        let fileName = UUID().uuidString + ".png"
        let fileURL = documentsUrl.appendingPathComponent(fileName)

        if let imageData = image.pngData() {
            do {
                try imageData.write(to: fileURL, options: .atomic)
                print("Image saved to file system at: \(fileURL)")
                return fileURL
            } catch {
                print("Error saving image to file system: \(error)")
                return nil
            }
        } else {
            print("Error converting UIImage to png data")
            return nil
        }

    }


    func getImageFromFS(path: URL?) -> UIImage? {
        guard let fileURL = path else {
            print("Invalid file URL")
            return nil
        }

        do {
            let imageData = try Data(contentsOf: fileURL)
            let image = UIImage(data: imageData)
            return image
        } catch {
            print("Error loading image from file system: \(error)")
            return nil
        }
    }

    func deleteFile(at path: URL?) {
        guard let filePath = path else {
            print("Invalid file path")
            return
        }

        do {
            try FileManager.default.removeItem(at: filePath)
            print("File successfully deleted")
        } catch {
            print("Error deleting file: \(error)")
        }
    }


    func getDocumentDirUrl() -> URL? {
        return try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    }
}
