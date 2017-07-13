//
//  DetailViewController.swift
//  metal prototype 1
//
//  Created by Daniel Pasco on 7/12/17.
//  Copyright © 2017 Daniel Pasco. All rights reserved.
//

import UIKit
import MetalKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var metalView: MTKView!
    
    var metalCommandQueue: MTLCommandQueue!
    var imageTexture: MTLTexture?
    var metalDevice: MTLDevice!
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail.description
            }
        }
        if let defaultDevice = MTLCreateSystemDefaultDevice() {
            self.metalDevice = defaultDevice
            self.metalCommandQueue = self.metalDevice.makeCommandQueue()
            self.metalView.device = self.metalDevice
            if let image = UIImage(named:"0.png") {
                do {
                    if let cgImage = image.cgImage {
                        do {
                            let imageTexture = try MTKTextureLoader(device: metalDevice).newTexture(with: cgImage, options: nil)
                            do {
                                if let commandBuffer = metalCommandQueue.makeCommandBuffer() {
                                    do {
                                        // Copy the image texture to the texture of the current drawable
                                        if let blitEncoder = commandBuffer.makeBlitCommandEncoder() {
                                            do {
                                                if let drawable = metalView.currentDrawable {
                                                    do {
                                                        blitEncoder.copy(from: imageTexture, sourceSlice: 0, sourceLevel: 0,
                                                                         sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0),
                                                                         sourceSize: MTLSizeMake(imageTexture.width, imageTexture.height, imageTexture.depth),
                                                                         to: drawable.texture, destinationSlice: 0, destinationLevel: 0,
                                                                                    destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0))
                                                        blitEncoder.endEncoding()
                                                        
                                                        // Present current drawable
                                                        commandBuffer.present(drawable)
                                                        commandBuffer.commit()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        catch let error as NSError {
                            print("[ERROR] - Failed to create texture. \(error)")
                        }
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: NSDate? {
        didSet {
            // Update the view.
            configureView()
        }
    }
}

