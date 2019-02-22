import UIKit
import AVFoundation

open class LFView: UIView {
    open static var defaultBackgroundColor: UIColor = .black

    open override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }

    open override var layer: AVCaptureVideoPreviewLayer {
        return super.layer as! AVCaptureVideoPreviewLayer
    }

    public var videoGravity: AVLayerVideoGravity = .resizeAspect {
        didSet {
            layer.videoGravity = videoGravity
        }
    }

    var orientation: AVCaptureVideoOrientation = .landscapeLeft {
        didSet {
            layer.connection.map {
                if $0.isVideoOrientationSupported {
                    $0.videoOrientation = orientation
                }
            }
        }
    }
    var position: AVCaptureDevice.Position = .front
    
    public var image : UIImage!

    private weak var currentStream: NetStream? {
        didSet {
            oldValue?.mixer.videoIO.drawable = nil
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        awakeFromNib()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        attachStream(nil)
    }

    override open func awakeFromNib() {
        backgroundColor = LFView.defaultBackgroundColor
        layer.backgroundColor = LFView.defaultBackgroundColor.cgColor
    }

    open func attachStream(_ stream: NetStream?) {
        guard let stream: NetStream = stream else {
            layer.session?.stopRunning()
            layer.session = nil
            currentStream = nil
            return
        }

        stream.mixer.session.beginConfiguration()
        layer.session = stream.mixer.session
        orientation   = stream.mixer.videoIO.orientation
//        let myLayer = CALayer()
//        let myImage = image.cgImage
//        myLayer.frame = CGRect(x: 10, y: 10, width: 200, height: 200)
//        myLayer.contents = myImage
//        layer.addSublayer(myLayer)
        
        stream.mixer.session.commitConfiguration()

        stream.lockQueue.async {
            stream.mixer.videoIO.drawable = self
            self.currentStream = stream
            stream.mixer.startRunning()
        }
    }
}

extension LFView: NetStreamDrawable {
    // MARK: NetStreamDrawable
    func draw(image: CIImage) {
    }
}
