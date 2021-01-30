//
//  ViewController.swift
//  bilibili-mask
//
//  Created by ding_qili on 2021/1/23.
//

import UIKit
import AVFoundation
import AVKit

class ViewController: UIViewController {
    
    lazy var detetor =  CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyLow])
    lazy var asset:AVURLAsset = AVURLAsset(url: URL(string: "http://localhost:8080/bb.mp4")!)
    
    lazy var avplayer:AVPlayer = AVPlayer(playerItem: AVPlayerItem(asset: self.asset))
    lazy var avplaylayer:AVPlayerLayer = {
        return AVPlayerLayer(player: self.avplayer)
    }()
    
    var output:AVPlayerItemVideoOutput = {
        return AVPlayerItemVideoOutput(pixelBufferAttributes: nil)
    }()
    
    let faceLayer = CALayer()
    let faceMaskLayer = CAShapeLayer()

    
    
    var timer:Timer{
        return Timer(timeInterval: 0.5, repeats: true) { (timer) in
            self.sendBiuBiuBiu()
            let itemTime = self.output.itemTime(forHostTime: CACurrentMediaTime())
            if self.output.hasNewPixelBuffer(forItemTime: itemTime) {
                if let pixelBuffer = self.output.copyPixelBuffer(forItemTime: itemTime, itemTimeForDisplay: nil){

                    let ciimage = CIImage(cvPixelBuffer: pixelBuffer)
                    if let faceFeature =  self.detetor?.features(in: ciimage).first as? CIFaceFeature{
                    
                        let ciImageSize = ciimage.extent.size
                        var transform = CGAffineTransform.init(scaleX: 1, y: -1)

                        transform = transform.translatedBy(x: 0, y: -ciImageSize.height)
                        var faceViewBounds = faceFeature.bounds.applying(transform)

                        
                        // Calculate the actual position and size of the rectangle in the image view
                        // 坐标系重新映射完成后，计算是视图中的位置和偏移
                        let viewSize = self.avplaylayer.bounds.size
                        let scale = min(viewSize.width / ciImageSize.width,
                                        viewSize.height / ciImageSize.height)
                        let offsetX = (viewSize.width - ciImageSize.width * scale) / 2
                        let offsetY = (viewSize.height - ciImageSize.height * scale) / 2
                        
                        faceViewBounds = faceViewBounds.applying(CGAffineTransform.init(scaleX: scale, y: scale))
                        
                       
                        faceViewBounds.origin.x += offsetX
                        faceViewBounds.origin.y += offsetY
                        
                        
                        let path = UIBezierPath(rect: self.avplaylayer.frame)
                        path.append(UIBezierPath(rect: faceViewBounds))
                        
                        self.faceMaskLayer.path =  path.cgPath
                        self.faceMaskLayer.fillRule = .evenOdd
                        
                        
                    }
                }
            }
        }
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.avplaylayer.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
//        self.avplaylayer.videoGravity = .resize
        
        self.avplayer.play()
        self.view.layer.addSublayer(self.avplaylayer)
        
        self.avplayer.currentItem?.add(output)
        RunLoop.current.add(timer, forMode: .default)
        timer.fire()
        self.avplaylayer.addSublayer(faceLayer)
        self.faceLayer.mask = self.faceMaskLayer
    }
    
    func sendBiuBiuBiu(){
        for i in 0..<10 {
            let str = "我爱冰冰！！❤️"
            let width = self.avplaylayer.frame.width
            let height = self.avplaylayer.frame.height
            let randomHeight = arc4random() % UInt32(height)
            let randomduration = arc4random() % UInt32(8)
            let color = UIColor.init(red: (((CGFloat)((arc4random() % 256)) / 255.0)), green: (((CGFloat)((arc4random() % 256)) / 255.0)), blue: (((CGFloat)((arc4random() % 256)) / 255.0)), alpha: 1.0);
            
            
            
            let text = CATextLayer()
            text.isWrapped = true
            text.string = str
            text.fontSize = 13
            text.frame = CGRect(x: self.avplaylayer.frame.width - 20, y: CGFloat(randomHeight), width: 100, height: 40)
            text.foregroundColor = color.cgColor
            
            self.faceLayer.addSublayer(text)
            
            let animation = CABasicAnimation()
            animation.keyPath = "position.x";
            animation.fromValue = width
            animation.toValue = 0
            animation.duration = CFTimeInterval(randomduration)
            text.add(animation, forKey: "basic")
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() +  .seconds(Int(randomduration))) {
                text.removeFromSuperlayer()
            }
        }
        

        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avplaylayer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.width * 4 / 3)
        faceLayer.frame = avplaylayer.frame
    }

}


