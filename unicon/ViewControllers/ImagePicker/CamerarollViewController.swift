//
//  CamerarollViewController.swift
//  unicon
//
//  Created by Imajin Kawabe on 2018/06/30.
//  Copyright © 2018年 Imajin Kawabe. All rights reserved.
//

import UIKit
import Photos
import CropViewController

class CamerarollViewController: UIViewController, UICollectionViewDelegate, CropViewControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var imageArray = [UIImage]()
    var selectedImage = UIImage()
    
    var fetchResults = PHFetchResult<PHAsset>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib: UINib = UINib(nibName: "CameraRollCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "CameraRollCollectionViewCell")
        
        setup()
        libraryRequestAuthorization()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setup() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // UICollectionViewCellのマージン等の設定
        let flowLayout: UICollectionViewFlowLayout! = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width / 3 - 4,
                                     height: UIScreen.main.bounds.width / 3 - 4)
        flowLayout.sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 6
        
        collectionView.collectionViewLayout = flowLayout
    }
    
    // カメラロールへのアクセス許可
    fileprivate func libraryRequestAuthorization() {
        PHPhotoLibrary.requestAuthorization({ [weak self] status in
            guard let wself = self else {
                return
            }
            switch status {
            case .authorized:
                wself.grabPhotos()
            case .denied:
                wself.showDeniedAlert()
            case .notDetermined:
                print("NotDetermined")
            case .restricted:
                print("Restricted")
            }
        })
    }
    
    // カメラロールから全て取得する
    func grabPhotos() {
        
        let group = DispatchGroup()
        group.enter()
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        fetchResults = fetchResult
        
        group.leave()
        
        group.notify(queue: .main, execute: {
            self.collectionView.reloadData()
        })
        
    }
    
    func grabOnePhoto(selectedRow: Int) {
        let imgManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        
        imgManager.requestImage(for: fetchResults.object(at: selectedRow) , targetSize: CGSize(width: 1200, height: 1200), contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, error) in
            if let img = image {
                self.selectedImage = img
                self.presentCropViewController()
            }
        })
    }
    
    // カメラロールへのアクセスが拒否されている場合のアラート
    fileprivate func showDeniedAlert() {
        let alert: UIAlertController = UIAlertController(title: "エラー",
                                                         message: "「写真」へのアクセスが拒否されています。設定より変更してください。",
                                                         preferredStyle: .alert)
        let cancel: UIAlertAction = UIAlertAction(title: "キャンセル",
                                                  style: .cancel,
                                                  handler: nil)
        let ok: UIAlertAction = UIAlertAction(title: "設定画面へ",
                                              style: .default,
                                              handler: { [weak self] (action) -> Void in
                                                guard let wself = self else {
                                                    return
                                                }
                                                wself.transitionToSettingsApplition()
        })
        alert.addAction(cancel)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func transitionToSettingsApplition() {
        let url = URL(string: UIApplicationOpenSettingsURLString)
        if let url = url {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func presentCropViewController() {
        let image: UIImage = selectedImage
        
        let cropViewController = CropViewController(image: image)
        cropViewController.delegate = self
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.aspectRatioPickerButtonHidden = true
        cropViewController.customAspectRatio = CGSize(width: 19.0, height: 24.0)
        cropViewController.resetAspectRatioEnabled = false
        cropViewController.rotateButtonsHidden = true
        
        
        present(cropViewController, animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
}

extension CamerarollViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CameraRollCollectionViewCell", for: indexPath) as! CameraRollCollectionViewCell
        
        let imgManeger = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .fastFormat
        imgManeger.requestImage(for: fetchResults.object(at: indexPath.row) , targetSize: CGSize(width: 150, height: 150), contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, error) in
            if let img = image {
                cell.photoImageView.image = img
            }
        })
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        grabOnePhoto(selectedRow: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ToNext") {
            let cropVC: CropImageViewController = (segue.destination as? CropImageViewController)!
            cropVC.selectedImage = selectedImage
        }
    }
}
