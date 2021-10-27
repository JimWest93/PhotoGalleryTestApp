import Foundation

struct Gallery: Decodable {
    var hits: [PhotosData]
}

struct PhotosData: Decodable {
    var previewURL: String
    var tags: String
    var largeImageURL: String
    var imageWidth, imageHeight: Int
}
