//
//  extensions.swift
//  PPOcards
//
//  Created by Сергей Николаев on 09.04.2023.
//

import UIKit

public final class DataColorConverter {
    
    static var shared = DataColorConverter()
    
    private init() {}
    
    func RGBColorToData(color: Int) -> Data? {
        UIColor(rgb: color).data
    }
}

public extension Numeric {
    var data: Data {
        var bytes = self
        return Data(bytes: &bytes, count: MemoryLayout<Self>.size)
    }
}

public extension Data {
    func object<T>() -> T { withUnsafeBytes{$0.load(as: T.self)} }
    var color: UIColor { .init(data: self) }
}

public extension UIColor {
    convenience init(data: Data) {
        let size = MemoryLayout<CGFloat>.size
        self.init(red:   data.subdata(in: size*0..<size*1).object(),
                  green: data.subdata(in: size*1..<size*2).object(),
                  blue:  data.subdata(in: size*2..<size*3).object(),
                  alpha: data.subdata(in: size*3..<size*4).object())
    }
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        var (red, green, blue, alpha): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        return getRed(&red, green: &green, blue: &blue, alpha: &alpha) ?
        (red, green, blue, alpha) : nil
    }
    var data: Data? {
        guard let rgba = rgba else { return nil }
        return rgba.red.data + rgba.green.data + rgba.blue.data + rgba.alpha.data
    }
}

public extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}

public extension UserDefaults {

    static func exists(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }

}
