//
//  DefaultImagesProvider.swift
//  PPOcards
//
//  Created by ser.nikolaev on 30.04.2023.
//

import UIKit
import Core
import FileManager

public final class ImagesProvider {
    public static let shared = ImagesProvider()

    private init() {}
    
    private let imageNames = ["t", "t1", "t2"]
    
    public lazy var images: [String:UIImage] = {
        var imgs = [String:UIImage]()
        
        for name in self.imageNames {
            imgs[name] = UIImage(named: name)
        }
        
        return imgs
    }()
    
    public func getImageFromDB(path: URL?) -> UIImage? {
        MyFileManager.shared.getImageFromFS(path: path)
    }
}
