//
//  ViewController.swift
//  CardNumberScan
//
//  Created by 丸本聡 on 2020/03/21.
//  Copyright © 2020 丸本聡. All rights reserved.
//

import UIKit
import Vision
import Foundation

class ViewController: UIViewController {
    
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var cameraView: UIImageView!
    
    var isCreditCardNo :Bool {
        return self.isCreditCardNo
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // カメラ撮影開始
    @IBAction func startCamera(_ sender : AnyObject) {
        
        let sourceType:UIImagePickerController.SourceType =
            UIImagePickerController.SourceType.camera
        // カメラが利用可能かチェック
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerController.SourceType.camera){
            // インスタンス作成
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
            
        }
    }

    //　撮影完了
    func imagePickerController(_ imagePicker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let pickedImage = info[.originalImage]
            as? UIImage {
            cameraView.contentMode = .scaleAspectFit
            cameraView.image = pickedImage
            
            guard let cgImage = pickedImage.cgImage else { return }
            let request = VNRecognizeTextRequest(completionHandler: self.recognizeTextHandler)
            
            request.recognitionLevel = .fast  // .accurate と .fast が選択可能
            request.recognitionLanguages = ["en_US"] // 言語を選ぶ
            request.usesLanguageCorrection = true // 訂正するかを選ぶ
            
            let requests = [request]
            let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage,  options: [:])
            
            do {
                try imageRequestHandler.perform(requests)
            } catch {
                print("error")
            }
        }
        //閉じる
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func recognizeTextHandler(request: VNRequest?, error: Error?) {
        guard let observations = request?.results as? [VNRecognizedTextObservation] else {
            return
        }
        
        var text = ""

        for observation in observations {
            let candidates = 1
            guard let bestCandidate = observation.topCandidates(candidates).first else {
                continue
            }
            
            text = bestCandidate.string // 文字認識結果
        }
        
        if text.isCreditCardNo() {
            textField.text = text
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate {
}

extension ViewController: UINavigationControllerDelegate {
}

extension String {
    func isCreditCardNo() -> Bool {
        return (self =~ "^\\d{4}-\\d{4}-\\d{4}-\\d{4}$")
    }
}
