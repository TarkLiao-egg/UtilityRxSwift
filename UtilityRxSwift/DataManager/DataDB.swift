import Foundation
import UIKit

class DataDB: SQLModel {
    var id: Int = -1
    var title: String
    var imageData: NSData
    
    init(title: String, image: UIImage) {
        self.title = title
        self.imageData = NSData()
        super.init()
        saveImage(image)
    }
    
    required init() {
        self.title = ""
        self.imageData = NSData()
    }
    
    override func primaryKey() -> String {
        return "id"
    }
    
    override func ignoredKeys() -> [String] {
        return []
    }
}

extension DataDB {
    func saveImage(_ image: UIImage?) {
        if let nsdata = image?.pngData() {
            self.imageData = nsdata as NSData
        } else if let nsdata = image?.jpegData(compressionQuality: 0.5) {
            self.imageData = nsdata as NSData
        } else {
            self.imageData = NSData()
        }
    }
    
    func loadImage() -> UIImage? {
        if imageData == NSNull() {
            return nil
        } else {
            return UIImage(data: self.imageData as Data)
        }
    }
}
