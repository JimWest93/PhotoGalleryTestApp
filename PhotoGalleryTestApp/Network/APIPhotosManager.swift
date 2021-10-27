import Foundation

protocol PhotosManagerDelegate {
    func updateCollection(data: [PhotosData])
}

class APIPhotosManager {
    
    static var shared: APIPhotosManager {
        let instance = APIPhotosManager()
        return instance
    }
    
    var delegate: PhotosManagerDelegate?
    
    let url = "https://pixabay.com/api/?key=24030308-d9a32e2547662e4c215c88160&page="
    var page = 1
    
    func fetch() {
        
        let apiUrl = url + String(page)
        
        guard let url = URL(string: apiUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            DispatchQueue.global(qos: .background).async {
                if let error = error {
                    print(error)
                }
                
                guard let data = data else { return }
                
                do {
                    let gallery = try JSONDecoder().decode(Gallery.self, from: data)
                    
                    DispatchQueue.main.async {
                        self?.delegate?.updateCollection(data: gallery.hits)
                        CoreDataManager.shared.photoDataSaver(hits: gallery.hits)
                    }

                } catch let jsonError {
                    print(jsonError)
                }
                
            }
        }.resume()
    }
}
