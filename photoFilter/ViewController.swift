//
//  ViewController.swift
//  photoFilter
//
//  Created by 有村 琢磨 on 2015/03/26.
//  Copyright (c) 2015年 takuma arimura. All rights reserved.
//

import UIKit
import CoreImage
import Social

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var originImage :UIImage! //処理前の画像
    var filteredImage :CIImage! //処理中の画像
    var outputImage :UIImage! //処理後の画像
    var captureImage :UIImage! //保存するときの画像
    //let myImage = UIImage(named: "sample.png")
    var myImage = UIImage()
    
    @IBOutlet var targetImageView: UIImageView?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        targetImageView?.contentMode = UIViewContentMode.ScaleAspectFill
        
        targetImageView?.image = UIImage(named: "big.jpg")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //カメラロールから画像を取り出す
    @IBAction func openCameraroll() {
        //UIImageViewControllerの初期化
        var openFolda = UIImagePickerController()
        
        //画像の取得先をフォトライブラリーに設定する
        openFolda.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        //デリゲートの設定
        openFolda.delegate = self
        openFolda.allowsEditing = true
        //フォトライブラリーをモーダルビューとして表示する
        self.presentViewController(openFolda, animated: true, completion: nil)
        
    }
    
    //UIImagePickerViewdelegate
    //フォトライブラリで画像が選ばれたときの処理
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, info: NSDictionary!) {
        //if info[UIImagePickerControllerOriginalImage] != nil {
            let pickingImage : UIImage = info[UIImagePickerControllerOriginalImage] as UIImage
            targetImageView?.image = pickingImage
        
    }
    
    //普通に保存するとJPEG形式で保存すると荒れるのでPNG形式に変換している
    func png() {
        //保存する範囲を指定(filterViewの範囲を取得している)
        var rect :CGRect? = targetImageView!.bounds
        UIGraphicsBeginImageContextWithOptions(rect!.size, false, 0)
        var ctx :CGContextRef = UIGraphicsGetCurrentContext()
        CGContextFillRect(ctx, rect!)
        
        targetImageView?.layer.renderInContext(ctx)
        
        //普通に保存するとJPEG形式で保存すると荒れるのでPNG形式に変換している
        var data: NSData = UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext())
        captureImage = UIImage(data: data)
        UIGraphicsEndImageContext()
    }
    
    //表示画像を保存
    @IBAction func saveImage() {
        self.png()
        
        UIImageWriteToSavedPhotosAlbum(captureImage, self, "image:didFinishSavingWithError:contextInfo:", nil)
    }
    
    
    // 保存完了した時に出すアラート
    //今後改良する
    func onCompleteCapture(screenImage: UIImage, didFinishSavingWithError error: NSError!, contextInfo: Void) {
        if error != nil {
            //プライバシー設定不許可など書き込み失敗時は -3310 (ALAssetsLibraryDataUnavailableError)
            println(error.code)
        }
    }
    
    //表示画像を削除
    @IBAction func clearImage() {
        
        targetImageView?.image = nil
    }
    
    
    //表示画像をモノクロに加工
    @IBAction func monochromeFiter() {
        //今表示されている画像の取得
        originImage = targetImageView?.image
        
        //UIImageをCIImageに変換
        filteredImage = CIImage(CGImage: originImage.CGImage)
        
        //CIFilterを作成
        var monofilter: CIFilter! = CIFilter(name: "CIColorMonochrome")
        monofilter.setValue(filteredImage, forKey: "InputImage")
        
        //フィルタ後の画像を取得
        filteredImage = monofilter.outputImage
        
        //CIImageをUIImageへ変換
        var myCIContext :CIContext = CIContext(options: nil)
        var imageRef :CGImageRef = myCIContext.createCGImage(filteredImage, fromRect: filteredImage.extent(
            ))!
        
        outputImage = UIImage(CGImage: imageRef, scale: 1.0, orientation:UIImageOrientation.Up)
        
        
        //画像を表示する
        targetImageView?.image = outputImage
    }
    
    //表示画像をセピアに加工
    @IBAction func sepiaFilter() {
        
        //今表示されている画像の取得
        originImage = targetImageView?.image
        
        //UIImageをCIImageに変換
        filteredImage = CIImage(CGImage: originImage.CGImage)
        
        //CIFilterを作成
        var sepiaFilter :CIFilter! = CIFilter(name: "CISepiaTone")
        sepiaFilter.setValue(filteredImage, forKey: "InputImage")
        
        //フィルタ後の画像を取得
        filteredImage = sepiaFilter.outputImage
        
        //CIImageをUIImageへ変換
        var myCIContext :CIContext = CIContext(options: nil)
        var imageRef :CGImageRef = myCIContext.createCGImage(filteredImage, fromRect: filteredImage.extent())
        
        outputImage = UIImage(CGImage: imageRef, scale: 1.0, orientation: UIImageOrientation.Up)
        
        //画像を表示する
        targetImageView?.image = outputImage
    }
    
    //もとに戻す
    @IBAction func undoImage() {
     
        //元の画像を表示させよう
        //targetImageView?.image = myImage
        
        targetImageView?.image = originImage
    }
    
    //Facebookに投稿
    @IBAction func facebook() {
        //投稿する画像の取得
        self.png()
        //facebookのおまじない
        let facebookPost = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        facebookPost.setInitialText("facebook投稿テスト")
        //添付する画像
        facebookPost.addImage(captureImage)
        self.presentViewController(facebookPost, animated: true, completion: nil)
        
    }
    
    


}

