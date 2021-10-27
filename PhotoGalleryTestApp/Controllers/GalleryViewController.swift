import UIKit

class GalleryViewController: UIViewController {
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    private var networkAlert = UIAlertController()
    
    private var isFirstLaunch = false
    private let cellId = "photoCell"
    private let cellsSpacing = 2
    private let cellsInARow = 2
    private var photosGallery: [PhotosData] = []
    private let photoManager = APIPhotosManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self
        photoManager.delegate = self
        newtworkAlertSetup()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isFirstLaunch {
            checkNetworkOnLaunch()
        }
    }
    
    func checkNetworkOnLaunch() {
        if !ReachabilityTest.isConnectedToNetwork() {
            self.present(networkAlert, animated: true, completion: nil)
        } else {
            photoManager.fetch()
            isFirstLaunch = !isFirstLaunch
        }
    }
    
    func newtworkAlertSetup() {
        
        networkAlert = UIAlertController(title: "Network Error", message: "There was an error connecting. Please check your internet connection", preferredStyle: .alert)
        
        let retryAction = UIAlertAction(title: "Retry", style: .default) { [weak self] action in
            if ReachabilityTest.isConnectedToNetwork() {
                self?.networkAlert.dismiss(animated: true, completion: nil)
                self?.photosCollectionView.isHidden = false
                self?.photoManager.fetch()
            } else {
                self?.present((self?.networkAlert)!, animated: true, completion: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        networkAlert.addAction(cancelAction)
        networkAlert.addAction(retryAction)
    }
    
}

extension GalleryViewController: PhotosManagerDelegate {
    func updateCollection(data: [PhotosData]) {
        photosGallery.append(contentsOf: data)
        photosCollectionView.reloadData()
    }
}

extension GalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if photosGallery.isEmpty {
            return 6
        }
        return photosGallery.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PhotoCollectionViewCell
        if !photosGallery.isEmpty {
            cell.cellInit(data: photosGallery[indexPath.row])
        } else {
            cell.cellInitIfDataEmpty()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let fullscreenVC = storyboard?.instantiateViewController(withIdentifier: "fullscreenVC") as! FullscreenViewController
        fullscreenVC.modalPresentationStyle = .fullScreen
        fullscreenVC.imageURL = photosGallery[indexPath.row].largeImageURL
        present(fullscreenVC, animated: true, completion: nil)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cVFrame = photosCollectionView.frame
        let cellWidth = cVFrame.width / CGFloat(cellsInARow)
        let cellHeight = cellWidth
        let totalSpacing = CGFloat((cellsInARow + 1) * cellsSpacing / cellsInARow)
        return CGSize(width: cellWidth - totalSpacing, height: cellHeight - CGFloat(cellsSpacing * 2))
    }
    
}

extension GalleryViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (photosCollectionView.contentOffset.y + photosCollectionView.frame.size.height) >= photosCollectionView.contentSize.height - 100 && ReachabilityTest.isConnectedToNetwork() {
            photoManager.page += 1
            photoManager.fetch()
        } else if (photosCollectionView.contentOffset.y + photosCollectionView.frame.size.height) >= photosCollectionView.contentSize.height - 100 && !ReachabilityTest.isConnectedToNetwork() {
            self.present(networkAlert, animated: true, completion: nil)
        }
    }
}
