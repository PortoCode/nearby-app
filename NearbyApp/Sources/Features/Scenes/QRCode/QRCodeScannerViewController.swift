//
// Created by Rodrigo Porto.
// Copyright © 2024 PortoCode. All Rights Reserved.
//

import UIKit
import AVFoundation

class QRCodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var qrCodeDetected: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // Configurar a sessão de captura
            self.captureSession = AVCaptureSession()
            
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
                print("Câmera não disponível")
                return
            }
            
            let videoInput: AVCaptureDeviceInput
            do {
                videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch {
                print("Erro ao acessar a câmera: \(error)")
                return
            }
            
            if self.captureSession.canAddInput(videoInput) {
                self.captureSession.addInput(videoInput)
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            if self.captureSession.canAddOutput(metadataOutput) {
                self.captureSession.addOutput(metadataOutput)
                
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.qr]
            }
            
            // Atualizar a UI na main thread
            DispatchQueue.main.async {
                self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                self.previewLayer.frame = self.view.layer.bounds
                self.previewLayer.videoGravity = .resizeAspectFill
                self.view.layer.addSublayer(self.previewLayer)
                
                // Iniciar a captura em um thread de background
                DispatchQueue.global(qos: .userInitiated).async {
                    self.captureSession.startRunning()
                }
            }
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                  let stringValue = readableObject.stringValue else { return }
            
            captureSession.stopRunning()
            
            DispatchQueue.main.async { [weak self] in
                self?.dismiss(animated: true) {
                    self?.qrCodeDetected?(stringValue)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
}
