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
    var couponUsed: ((String) -> Void)?
    var highlightLayer: CAShapeLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCaptureSession()
        setupUI()
    }
    
    private func setupCaptureSession() {
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
    
    private func setupUI() {
        let backButton = UIButton()
        backButton.backgroundColor = Colors.greenBase
        backButton.layer.cornerRadius = 8
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        backButton.layer.zPosition = 1 // Garante que o botão fique na frente da câmera
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            backButton.widthAnchor.constraint(equalToConstant: 40),
        ])
        
        let arrowImage = UIImage(systemName: "arrow.left")?.withRenderingMode(.alwaysTemplate)
        let arrowImageView = UIImageView(image: arrowImage)
        arrowImageView.tintColor = Colors.gray100
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        backButton.addSubview(arrowImageView)
        
        NSLayoutConstraint.activate([
            arrowImageView.centerXAnchor.constraint(equalTo: backButton.centerXAnchor),
            arrowImageView.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 20),
            arrowImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                  let stringValue = readableObject.stringValue else { return }
            
            if let transformedObject = previewLayer.transformedMetadataObject(for: readableObject) {
                drawQRCodeHighlight(bounds: transformedObject.bounds)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.captureSession.stopRunning()
                self?.presentCouponModal(with: stringValue)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    private func drawQRCodeHighlight(bounds: CGRect) {
        // Remover qualquer highlight anterior
        highlightLayer?.removeFromSuperlayer()
        
        // Ajustar os limites para dar mais espaço entre o contorno e o QR code
        let padding: CGFloat = 16 // Espaço extra em torno do QR code
        let expandedBounds = bounds.insetBy(dx: -padding, dy: -padding)
        
        // Criar um contorno novo
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = Colors.greenLight.cgColor
        shapeLayer.lineWidth = 4
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        // Criar os cantos arredondados
        let path = UIBezierPath()
        let lineLength: CGFloat = 30
        
        // Superior esquerdo
        path.move(to: CGPoint(x: expandedBounds.minX, y: expandedBounds.minY + lineLength))
        path.addLine(to: CGPoint(x: expandedBounds.minX, y: expandedBounds.minY))
        path.addLine(to: CGPoint(x: expandedBounds.minX + lineLength, y: expandedBounds.minY))
        
        // Superior direito
        path.move(to: CGPoint(x: expandedBounds.maxX - lineLength, y: expandedBounds.minY))
        path.addLine(to: CGPoint(x: expandedBounds.maxX, y: expandedBounds.minY))
        path.addLine(to: CGPoint(x: expandedBounds.maxX, y: expandedBounds.minY + lineLength))
        
        // Inferior direito
        path.move(to: CGPoint(x: expandedBounds.maxX, y: expandedBounds.maxY - lineLength))
        path.addLine(to: CGPoint(x: expandedBounds.maxX, y: expandedBounds.maxY))
        path.addLine(to: CGPoint(x: expandedBounds.maxX - lineLength, y: expandedBounds.maxY))
        
        // Inferior esquerdo
        path.move(to: CGPoint(x: expandedBounds.minX + lineLength, y: expandedBounds.maxY))
        path.addLine(to: CGPoint(x: expandedBounds.minX, y: expandedBounds.maxY))
        path.addLine(to: CGPoint(x: expandedBounds.minX, y: expandedBounds.maxY - lineLength))
        
        shapeLayer.path = path.cgPath
        
        // Adicionar o contorno à visualização
        view.layer.addSublayer(shapeLayer)
        highlightLayer = shapeLayer
    }
    
    private func presentCouponModal(with code: String) {
        let alertController = UIAlertController(title: "Cupom Detectado", message: "Deseja usar o cupom \(code)?", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Não", style: .cancel, handler: { [weak self] _ in
            self?.highlightLayer?.removeFromSuperlayer()
            self?.highlightLayer = nil
            
            DispatchQueue.global(qos: .userInitiated).async {
                self?.captureSession.startRunning()
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Sim", style: .default, handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
            self?.couponUsed?(code)
        }))
        
        present(alertController, animated: true)
    }
    
    @objc
    private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
}
