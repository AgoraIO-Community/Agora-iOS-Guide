//
//  VideoCollectionViewController.swift
//  Awesome Video Call
//

import AgoraRtcKit
import UIKit

final class VideoCollectionViewController: UICollectionViewController {
    
    struct Item: Hashable {
        let uid: UInt
    }
    
    private let agoraRTCEngine: AgoraRtcEngineKit
    private lazy var dataSource = makeDataSource()
    
    init(agoraRTCEngine: AgoraRtcEngineKit) {
        self.agoraRTCEngine = agoraRTCEngine
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        // Required init not needed
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.register(VideoCallCollectionItemCell.self, forCellWithReuseIdentifier: "reuse-id")
        collectionView.dataSource = dataSource
        
        var snapshot = dataSource.snapshot()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot)
    }
    
    func addRemoteVideo(with uid: UInt) {
        let newItem = Item(uid: uid)
        var snapshot = dataSource.snapshot()
        snapshot.appendItems([newItem], toSection: .main)
        dataSource.apply(snapshot)
    }
    
    func removeRemoteVideo(with uid: UInt) {
        let newItem = Item(uid: uid)
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([newItem])
        dataSource.apply(snapshot)
    }
}

// MARK: - Data Source
private extension VideoCollectionViewController {
    
    enum Section: Hashable {
        case main
    }
    
    func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Item> {
        .init(collectionView: collectionView) { [weak self] collectionView, indexPath, item in
            guard let self,
                  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuse-id", for: indexPath) as? VideoCallCollectionItemCell
            else {
                assertionFailure("Dequeued reusable cell isn't VideoCallCollectionItemCell.")
                return UICollectionViewCell()
            }
            cell.configure(with: item.uid, agoraRTCEngine: agoraRTCEngine)
            return cell
        }
    }
}

// MARK: - Layout
extension VideoCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let snapshot = dataSource.snapshot()
        
        let safeAreaVSum = collectionView.safeAreaInsets.top + collectionView.safeAreaInsets.bottom
        let width = collectionView.frame.width
        let height = collectionView.frame.height - safeAreaVSum
        
        switch snapshot.numberOfItems(inSection: .main) {
        case 1:
            return CGSize(width: width, height: height)
        case 2:
            return CGSize(width: width, height: height / 2)
        case 3...4:
            return CGSize(width: width / 2, height: height / 2)
        case 5...:
            return CGSize(width: width / 3, height: height / 3)
        default:
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}
