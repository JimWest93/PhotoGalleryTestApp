import UIKit
import Kingfisher

class FullscreenViewController: UIViewController {
    
    @IBOutlet weak var fullscreenImageView: UIImageView!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    
    private let indicatorView = UIActivityIndicatorView()
    private var errorAlert = UIAlertController()
    private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale(identifier: "en_EN")
        dateFormatter.dateFormat = "dd MMMM yy"
        return dateFormatter
    }()
    
    var imageURL = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageScrollView.delegate = self
        setupViews()
        getImage()
        infoLabelSetup()
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func setupViews() {
        indicatorView.frame = fullscreenImageView.frame
        indicatorView.center = fullscreenImageView.center
        fullscreenImageView.addSubview(indicatorView)
        indicatorView.startAnimating()
        
        view.bringSubviewToFront(cancelButton)
        view.bringSubviewToFront(infoLabel)
        
        imageScrollView.minimumZoomScale = 1.0
        imageScrollView.maximumZoomScale = 4.0
        
        errorAlert = UIAlertController(title: "Cannot Load Photo", message: "There was an error loading this photo.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel) { [weak self] action in
            self?.dismiss(animated: true, completion: nil)
        }
        errorAlert.addAction(cancelAction)
    }
    
    func infoLabelSetup() {
        let date = CoreDataManager.shared.notesData(photoURL: imageURL)?.date ?? Date()
        let dateString = dateFormatter.string(from: date)
        infoLabel.text = dateString
    }
    
    func getImage() {
        
        guard let url = URL(string: imageURL) else {return}
        
        KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil, downloadTaskUpdated: nil) { [weak self] result in
            switch result {
            case .success(let value):
                self?.fullscreenImageView.image = value.image
                self?.indicatorView.stopAnimating()
                self?.indicatorView.removeFromSuperview()
            case .failure(let error):
                print(error)
                self?.present((self?.errorAlert)!, animated: true, completion: nil)
            }
        }
        
    }
    
}

extension FullscreenViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return fullscreenImageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        imageScrollView.zoomScale = 1.0
    }
    
}
