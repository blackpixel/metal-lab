//
//  DetailViewController.swift
//  metal prototype 1
//
//  Created by Daniel Pasco on 7/12/17.
//  Copyright © 2017 Daniel Pasco. All rights reserved.
//

//

import UIKit
import MetalKit
class DetailViewController: UIViewController {

//class DetailViewController: UIViewController, MTKViewDelegate {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    var metalView: MTKView!
    
    var metalCommandQueue: MTLCommandQueue?
    var firstTexture: MTLTexture?
    var secondTexture: MTLTexture?

    /// Metal device
    var defaultMetalDevice = MTLCreateSystemDefaultDevice()
    
    /// Metal pipeline state we use for rendering
    var renderPipelineState: MTLRenderPipelineState?
    
    func initMetal() {
        
        let debugMetalView = MTKView(frame: self.view.bounds, device: defaultMetalDevice )
        self.metalView = debugMetalView
        self.metalCommandQueue = defaultMetalDevice?.makeCommandQueue()
        
        //        self.metalView.delegate = self
        self.metalView.framebufferOnly = false
//        self.metalView.device = defaultMetalDevice
        self.metalView.contentMode = .scaleAspectFit
        self.metalView.autoResizeDrawable = true
        self.metalView.contentScaleFactor = UIScreen.main.scale
        self.metalView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.metalView.colorPixelFormat = MTLPixelFormat.bgra8Unorm_srgb
        self.view.insertSubview(self.metalView, at: 0)
    }
    
//    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//
//    }
//
//    func draw(in view: MTKView) {
//        guard
//            let currentRenderPassDescriptor = metalView.currentRenderPassDescriptor,
//            let currentDrawable = metalView.currentDrawable,
//            let renderPipelineState = renderPipelineState
//        else {
//            semaphore.signal()
//            return
//        }
//        let commandBuffer = self.metalCommandQueue.makeCommandBuffer()
//
//        let encoder = commandBuffer?.makeRenderCommandEncoder(descriptor: currentRenderPassDescriptor)
//        encoder?.pushDebugGroup("RenderFrame")
//        encoder.setRenderPipelineState(renderPipelineState)
//        encoder.setFragmentTexture(texture, at: 0)
//        encoder??.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4, instanceCount: 1)
//        encoder?.popDebugGroup()
//        encoder?.endEncoding()
//
//        commandBuffer.addScheduledHandler { [weak self] (buffer) in
//            guard let unwrappedSelf = self else { return }
//
//            unwrappedSelf.didRenderTexture(texture, withCommandBuffer: buffer, device: device)
//            unwrappedSelf.semaphore.signal()
//        }
//        commandBuffer.present(currentDrawable)
//        commandBuffer.commit()
//    }
//
//    fileprivate func initializeRenderPipelineState() {
//        guard
//            let device = device,
//            let library = device.newDefaultLibrary()
//            else { return }
//
//        let pipelineDescriptor = MTLRenderPipelineDescriptor()
//        pipelineDescriptor.sampleCount = 1
//        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
//        pipelineDescriptor.depthAttachmentPixelFormat = .invalid
//
//        /**
//         *  Vertex function to map the texture to the view controller's view
//         */
//        pipelineDescriptor.vertexFunction = library.makeFunction(name: "mapTexture")
//        /**
//         *  Fragment function to display texture's pixels in the area bounded by vertices of `mapTexture` shader
//         */
//        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "displayTexture")
//
//        do {
//            try renderPipelineState = device.makeRenderPipelineState(descriptor: pipelineDescriptor)
//        }
//        catch {
//            assertionFailure("Failed creating a render state pipeline. Can't render the texture without one.")
//            return
//        }
//    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail.description
            }
        }
        initMetal()
        renderImage()
    }

    func loadTexture(name:String)->MTLTexture? {
        let image = UIImage(named:name)
        let cgImage = image?.cgImage
        var texture:MTLTexture?
        do {
            texture = try MTKTextureLoader(device: defaultMetalDevice!).newTexture(with: cgImage!, options: nil)
        }  catch let error as NSError {
            print("[ERROR] - Failed to create texture. \(error)")
        }
        return texture
    }
    
    func renderImage() {
        
        if self.detailItem != nil {
            self.firstTexture = loadTexture(name: self.detailItem!)
            self.secondTexture = loadTexture(name: self.detailItem!)
        }
        else {
            self.firstTexture = loadTexture(name: "0.png")
            self.secondTexture = loadTexture(name: "0.png")
        }
        let texture:MTLTexture? = self.secondTexture
//        self.metalView.drawableSize = CGSize(width: (texture?.width)!, height: (texture?.height)!)
        let commandBuffer = self.metalCommandQueue?.makeCommandBuffer()
        let blitEncoder = commandBuffer?.makeBlitCommandEncoder()
        let drawable = self.metalView.currentDrawable

        blitEncoder?.copy(from: texture!, sourceSlice: 0, sourceLevel: 0,
                          sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0),
                          sourceSize: MTLSizeMake((texture?.width)!, (texture?.height)!, (texture?.depth)!),
                          to: (drawable?.texture)!, destinationSlice: 0, destinationLevel: 0,
                          destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0))
        blitEncoder?.endEncoding()
        
        // Present current drawable
        commandBuffer?.present(drawable!)
        commandBuffer?.commit()
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

    var detailItem: String? {
        didSet {
            // Update the view.
            configureView()
        }
    }
}

