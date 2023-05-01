//
//  DefaultImagesProvider.swift
//  PPOcards
//
//  Created by ser.nikolaev on 30.04.2023.
//

import UIKit
import DBCoreData

final class ImagesProvider {
    static let shared = ImagesProvider()
    
    private init() {}
    
    private let imageNames = ["t", "t1", "t2"]
    
    lazy var images: [String:UIImage] = {
        var imgs = [String:UIImage]()
        
        for name in self.imageNames {
            imgs[name] = UIImage(named: name)
        }
        
        return imgs
    }()
    
    func getImageFromDB(path: URL?) -> UIImage? {
        MyFileManager.shared.getImageFromFS(path: path)
    }
}
