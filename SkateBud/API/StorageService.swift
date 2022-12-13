//
//  StorageService.swift
//  SkateBud
//
//  Created by Victor on 2022-10-25.
//

import Foundation
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import ProgressHUD
import AVFoundation

class StorageService {
    
    // saveVideoMessage function - copying file into another directory
    static func saveVideoMessage(url: URL, id: String, onSuccess: @escaping(_ value: Any) -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        let ref = Ref().storageSpecificVideoMessage(id: id)
        var finalUrl = url
        do {
            if #available(iOS 13, *) {
                //If on iOS13 slice the URL to get the name of the file
                let urlString = url.relativeString
                let urlSlices = urlString.split(separator: ".")
                //Create a temp directory using the file name
                let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                let targetURL = tempDirectoryURL.appendingPathComponent(String(urlSlices[1])).appendingPathExtension(String(urlSlices[2]))

                //Copy the video over
                do { try FileManager.default.copyItem(at: url, to: targetURL) }
                catch {
                    print("error#034846589")
                }
                finalUrl = targetURL
            } else {
                finalUrl = url
            }
        }

        ref.putFile(from: finalUrl, metadata: nil) { (metadata, error) in
            // NOTE: metadata is nil
            if error != nil {
                onError(error!.localizedDescription)
            }
            ref.downloadURL(completion: { (videoUrl, error) in
                // PROBLEM: videoUrl is nil
                if let thumbnailImage = self.thumbnailImageForFileUrl(url) {
                    StorageService.savePhotoMessage(image: thumbnailImage, id: id, onSuccess: { (value) in
                        if let dict = value as? Dictionary<String, Any> {
                            var dictValue = dict
                            if let videoUrlString = videoUrl?.absoluteString {
                                dictValue["videoUrl"]  = videoUrlString
                            }
                            onSuccess(dictValue)
                        }
                    }, onError: { (errorMessage) in
                        onError(errorMessage)
                    })
                }
            })
        }
    }
    
    // saveVideoMessage function using putData
//            static func saveVideoMessage(url: URL, id: String, onSuccess: @escaping(_ value: Any) -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
//            let ref = Ref().storageSpecificVideoMessage(id: id)
//
//            let metadata = StorageMetadata()
//            // specify MIME type
//            metadata.contentType = "video/quicktime"
//
//            // convert video url to data
//            if let videoUrlData = NSData(contentsOf: url) as Data? {
//                // use putData instead of put file *
//                ref.putData(videoUrlData, metadata: metadata) { (metadata, error) in
//                    if error != nil {
//                        onError(error!.localizedDescription)
//                    }
//                    ref.downloadURL(completion: { (videoUrl, error) in
//                        // PROBLEM: videoUrl is nil
//                        if let thumbnailImage = self.thumbnailImageForFileUrl(url) {
//                            StorageService.savePhotoMessage(image: thumbnailImage, id: id, onSuccess: { (value) in
//                                if let dict = value as? Dictionary<String, Any> {
//                                    var dictValue = dict
//                                    if let videoUrlString = videoUrl?.absoluteString {
//                                        dictValue["videoUrl"]  = videoUrlString
//                                    }
//                                    onSuccess(dictValue)
//                                }
//                            }, onError: { (errorMessage) in
//                                onError(errorMessage)
//                            })
//                        }
//                    })
//                }
//            }
//        }
        
        // saveVideoMessage function using putFile
//          static func saveVideoMessage(url: URL, id: String, onSuccess: @escaping(_ value: Any) -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
//            let ref = Ref().storageSpecificVideoMessage(id: id)
//            ref.putFile(from: url, metadata: nil) { (metadata, error) in
//                // NOTE: metadata is nil
//                if error != nil {
//                    onError(error!.localizedDescription)
//                }
//                ref.downloadURL(completion: { (videoUrl, error) in
//                    // PROBLEM: videoUrl is nil
//                    if let thumbnailImage = self.thumbnailImageForFileUrl(url) {
//                        StorageService.savePhotoMessage(image: thumbnailImage, id: id, onSuccess: { (value) in
//                            if let dict = value as? Dictionary<String, Any> {
//                                var dictValue = dict
//                                if let videoUrlString = videoUrl?.absoluteString {
//                                    dictValue["videoUrl"]  = videoUrlString
//                                }
//                                onSuccess(dictValue)
//                            }
//                        }, onError: { (errorMessage) in
//                            onError(errorMessage)
//                        })
//                    }
//                })
//            }
//        }
    
    static func thumbnailImageForFileUrl(_ url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        var time = asset.duration
        time.value = min(time.value, 2)
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch let error as NSError {
            print(error.localizedDescription)
            return nil
        }
    }
    
    static func savePhotoMessage(image: UIImage?, id: String, onSuccess: @escaping(_ value: Any) -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        if let imagePhoto = image {
            let ref = Ref().storageSpecificImageMessage(id: id)
            if let data = imagePhoto.jpegData(compressionQuality: 0.5) {
                
                ref.putData(data, metadata: nil) { (metadata, error) in
                    if error != nil {
                        onError(error!.localizedDescription)
                    }
                    ref.downloadURL(completion: { (url, error) in
                        if let metaImageUrl = url?.absoluteString {
                            let dict: Dictionary<String, Any> = [
                                "imageUrl": metaImageUrl as Any,
                                "height": imagePhoto.size.height as Any,
                                "width": imagePhoto.size.width as Any,
                                "text": "" as Any
                            ]
                            onSuccess(dict)
                        }
                    })
                }
            }
        }
    }
    
    static func savePhotoProfile(image: UIImage, uid: String, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.4) else {
            return
        }
        
        let storageProfileRef = Ref().storageSpecificProfile(uid: uid)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        storageProfileRef.putData(imageData, metadata: metadata, completion: { (StorageMetaData, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            
            storageProfileRef.downloadURL(completion: { ( url, error) in
                if let metaImageUrl = url?.absoluteString {
                    
                    if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    {
                        changeRequest.photoURL = url
                        changeRequest.commitChanges(completion: { (error) in
                            if let error = error {
                                ProgressHUD.showError(error.localizedDescription)
                            } else {
                                NotificationCenter.default.post(name: NSNotification.Name("updateProfileImage"), object: nil)
                            }
                            
                        })
                    }
                    
                    Ref().databaseSpecificUser(uid: uid).updateChildValues([PROFILE_IMAGE_URL: metaImageUrl], withCompletionBlock: {
                        (error, ref) in
                        if error == nil {
                            onSuccess()
                        } else {
                            onError(error!.localizedDescription)
                        }
                    })
                }
            })
            
        })
    }
    
    static func savePhoto(username: String, uid: String, data: Data, metadata: StorageMetadata, storageProfileRef: StorageReference, dict: Dictionary<String, Any>, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        
        storageProfileRef.putData(data, metadata: metadata, completion: { (StorageMetaData, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            
            storageProfileRef.downloadURL(completion: { ( url, error) in
                if let metaImageUrl = url?.absoluteString {
                    
                    if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    {
                        changeRequest.photoURL = url
                        changeRequest.displayName = username
                        changeRequest.commitChanges(completion: { (error) in
                            if let error = error {
                                ProgressHUD.showError(error.localizedDescription)
                            }
                        })
                    }
                    
                    var dictTemp = dict
                    dictTemp[PROFILE_IMAGE_URL] = metaImageUrl
                    
                    Ref().databaseSpecificUser(uid: uid).updateChildValues(dictTemp, withCompletionBlock: {
                        (error, ref) in
                        if error == nil {
                            onSuccess()
                        } else {
                            onError(error!.localizedDescription)
                        }
                    })
                }
            })
            
        })
    }
}
