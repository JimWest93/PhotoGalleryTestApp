import UIKit
import Kingfisher

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageSizeLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    private let processor = RoundCornerImageProcessor(cornerRadius: 5)
    private let indicatorView = UIActivityIndicatorView()

    func cellInit(data: PhotosData) {
        
        guard let url = URL(string: data.previewURL) else { return }
        
        KingfisherManager.shared.retrieveImage(with: url, options: [.processor(processor)], progressBlock: nil, downloadTaskUpdated: nil) { [weak self] result in
            switch result {
            case .success(let value):
                self?.imageView.image = value.image
                self?.indicatorView.removeFromSuperview()
                self?.indicatorView.stopAnimating()
            case .failure(let error):
                print(error)
                self?.cellInitIfDataEmpty()
            }
        }
        
        tagsLabel.text = data.tags
        imageSizeLabel.text = String(data.imageWidth) + "x" + String(data.imageHeight)
    }
    
    func cellInitIfDataEmpty() {
        indicatorView.frame = imageView.frame
        indicatorView.center = imageView.center
        indicatorView.startAnimating()
        imageView.addSubview(indicatorView)
        imageSizeLabel.text = ""
        tagsLabel.text = ""
    }
    
}
