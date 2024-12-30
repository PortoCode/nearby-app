//
// Created by Rodrigo Porto.
// Copyright © 2024 PortoCode. All Rights Reserved.
//

import Foundation
import UIKit
import AVFoundation

class DetailsViewController: UIViewController {
    var place: Place?
    var categoryName: String?
    
    private enum ViewState {
        case loading
        case loaded(Place)
        case error(String)
    }
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray100
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.titleLG
        label.textColor = Colors.gray600
        return label
    }()
    
    private let categoryImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.tintColor = Colors.greenBase
        return image
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.textMD
        label.textColor = Colors.gray500
        label.numberOfLines = 0
        return label
    }()
    
    private let infoTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.subtitle
        label.textColor = Colors.gray500
        label.text = "Informações"
        label.numberOfLines = 0
        return label
    }()
    
    private let regulationTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.subtitle
        label.textColor = Colors.gray500
        label.text = "Regulamento"
        return label
    }()
    
    private let couponTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.subtitle
        label.textColor = Colors.gray500
        label.text = "Utilize esse cupom"
        return label
    }()
    
    private let infoStackView = UIStackView()
    
    private let regulationLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.textSM
        label.textColor = Colors.gray500
        label.numberOfLines = 0
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        
        let regulationText = """
        • Válido apenas para consumo no local
        • Disponível até 31/12/2024
        """
        
        let attributedText = NSAttributedString(
            string: regulationText,
            attributes: [
                .paragraphStyle: paragraphStyle,
                .font: Typography.textSM,
                .foregroundColor: Colors.gray500
            ]
        )
        label.attributedText = attributedText
        
        return label
    }()
    
    private let couponStackView: UIStackView = {
        let iconImageView = UIImageView(image: UIImage(named: "ticket"))
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = Colors.greenBase
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [iconImageView])
        stackView.axis = .horizontal
        stackView.backgroundColor = Colors.greenExtraLight
        stackView.layer.cornerRadius = 8
        stackView.spacing = 4
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        
        return stackView
    }()
    
    private let couponCodeLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.titleMD
        label.textColor = Colors.gray600
        label.textAlignment = .center
        return label
    }()
    
    private let qrCodeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Ler QR Code", for: .normal)
        button.backgroundColor = Colors.greenBase
        button.titleLabel?.font = Typography.action
        button.setTitleColor(Colors.gray100, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray200
        return view
    }()
    
    private let divider2: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray200
        return view
    }()
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.greenBase
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        
        let arrowImage = UIImage(systemName: "arrow.left")?.withRenderingMode(.alwaysTemplate)
        let arrowImageView = UIImageView(image: arrowImage)
        arrowImageView.tintColor = Colors.gray100
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(arrowImageView)
        
        NSLayoutConstraint.activate([
            arrowImageView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            arrowImageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 20),
            arrowImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        return button
    }()
    
    private var stateView: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStateView()
        configureDetails()
        setupQRCodeButton()
        setupBackButton()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        view.backgroundColor = Colors.gray100
        scrollView.addSubview(contentView)
        contentView.addSubview(coverImageView)
        contentView.addSubview(containerView)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(categoryImageView)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(infoTitleLabel)
        containerView.addSubview(infoStackView)
        containerView.addSubview(divider)
        containerView.addSubview(regulationTitleLabel)
        containerView.addSubview(regulationLabel)
        containerView.addSubview(divider2)
        containerView.addSubview(couponTitleLabel)
        containerView.addSubview(couponStackView)
        
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        
        couponStackView.addArrangedSubview(couponCodeLabel)
        infoStackView.axis = .vertical
        infoStackView.spacing = 8
        setupTranslates()
        setupConstraints()
    }
    
    private func setupTranslates() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryImageView.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        infoTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        infoStackView.translatesAutoresizingMaskIntoConstraints = false
        divider.translatesAutoresizingMaskIntoConstraints = false
        regulationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        regulationLabel.translatesAutoresizingMaskIntoConstraints = false
        divider2.translatesAutoresizingMaskIntoConstraints = false
        couponTitleLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            coverImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            coverImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.4),
            coverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            containerView.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: -20),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            
            categoryImageView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 12),
            categoryImageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            categoryImageView.widthAnchor.constraint(equalToConstant: 24),
            categoryImageView.heightAnchor.constraint(equalToConstant: 24),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            
            infoTitleLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 32),
            infoTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            
            infoStackView.topAnchor.constraint(equalTo: infoTitleLabel.bottomAnchor, constant: 12),
            
            divider.topAnchor.constraint(equalTo: infoStackView.bottomAnchor, constant: 16),
            divider.heightAnchor.constraint(equalToConstant: 1),
            
            regulationTitleLabel.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 16),
            regulationTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            
            regulationLabel.topAnchor.constraint(equalTo: regulationTitleLabel.bottomAnchor, constant: 12),
            
            divider2.topAnchor.constraint(equalTo: regulationLabel.bottomAnchor, constant: 16),
            divider2.heightAnchor.constraint(equalToConstant: 1),
            
            couponTitleLabel.topAnchor.constraint(equalTo: divider2.bottomAnchor, constant: 16),
            couponTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            
            couponStackView.topAnchor.constraint(equalTo: couponTitleLabel.bottomAnchor, constant: 12),
            couponStackView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        applyLateralContraints(to: descriptionLabel)
        applyLateralContraints(to: infoStackView)
        applyLateralContraints(to: divider)
        applyLateralContraints(to: divider2)
        applyLateralContraints(to: regulationLabel)
        applyLateralContraints(to: couponStackView)
    }
    
    private func applyLateralContraints(to view: UIView) {
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
        ])
    }
    
    private func setupStateView() {
        stateView.isHidden = true
        stateView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
        view.addSubview(stateView)
        
        stateView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stateView.topAnchor.constraint(equalTo: view.topAnchor),
            stateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupQRCodeButton() {
        containerView.addSubview(qrCodeButton)
        qrCodeButton.translatesAutoresizingMaskIntoConstraints = false
        qrCodeButton.isUserInteractionEnabled = true
        qrCodeButton.addTarget(self, action: #selector(readQRCode), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            qrCodeButton.heightAnchor.constraint(equalToConstant: 44),
            qrCodeButton.topAnchor.constraint(equalTo: couponStackView.bottomAnchor, constant: 16),
            qrCodeButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -32),
            qrCodeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            qrCodeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24)
        ])
    }
    
    @objc
    private func readQRCode() {
        requestCameraAccess { [weak self] granted in
            guard granted else {
                self?.showCameraAccessAlert()
                return
            }
            self?.presentQRCodeScanner()
        }
    }
    
    func requestCameraAccess(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    private func showCameraAccessAlert() {
        let alert = UIAlertController(
            title: "Acesso à Câmera Negado",
            message: "Por favor, permita o acesso à câmera nas configurações para usar esta funcionalidade.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.addAction(UIAlertAction(title: "Abrir Configurações", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
            }
        })
        present(alert, animated: true)
    }
    
    func presentCouponModal(with code: String) {
        let alertController = UIAlertController(title: "Cupom Detectado", message: "Deseja usar o cupom \(code)?", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Não", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Sim", style: .default, handler: { _ in
            self.useCoupon(code: code)
        }))
        
        present(alertController, animated: true)
    }
    
    private func presentQRCodeScanner() {
        let scannerVC = QRCodeScannerViewController()
        scannerVC.qrCodeDetected = { [weak self] code in
            self?.presentCouponModal(with: code)
        }
        present(scannerVC, animated: true)
    }
    
    func useCoupon(code: String) {
        // Reduzir o número de cupons
        // Atualizar a UI
        print("Cupom \(code) usado com sucesso!")
    }
    
    private func setupBackButton() {
        view.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            backButton.widthAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    @objc
    private func didTapButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func configureDetails() {
        updateViewState(.loading)
        
        guard let place = place else {
            updateViewState(.error("Erro ao carregar os detalhes do local."))
            return
        }
        
        updateViewState(.loaded(place))
    }
    
    private func updateViewState(_ state: ViewState) {
        switch state {
        case .loading:
            showLoadingState()
            
        case .loaded(let place):
            hideLoadingState()
            updateUIWithPlace(place)
            
        case .error(let message):
            hideLoadingState()
            showErrorState(with: message)
        }
    }
    
    private func showLoadingState() {
        stateView.isHidden = false
        stateView.subviews.forEach { $0.removeFromSuperview() } // Limpa qualquer conteúdo anterior
        
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.color = Colors.greenBase
        loadingIndicator.startAnimating()
        stateView.addSubview(loadingIndicator)
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: stateView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: stateView.centerYAnchor)
        ])
    }
    
    private func hideLoadingState() {
        stateView.isHidden = true
    }
    
    private func updateUIWithPlace(_ place: Place) {
        titleLabel.text = place.name
        descriptionLabel.text = place.description
        
        let categoryIcons: [String: String] = [
            "Alimentação": "fork.knife",
            "Compras": "cart",
            "Hospedagem": "bed.double",
            "Padaria": "cup.and.saucer"
        ]
        let iconName = categoryIcons[categoryName ?? "Alimentação"] ?? "questionmark.circle"
        categoryImageView.image = UIImage(systemName: iconName)
        
        infoStackView.addArrangedSubview(createInfoRow(iconName: "ticket", text: "\(place.coupons) cupons disponíveis"))
        infoStackView.addArrangedSubview(createInfoRow(iconName: "mapIcon", text: place.address))
        infoStackView.addArrangedSubview(createInfoRow(iconName: "phone", text: place.phone))
        
        couponCodeLabel.text = place.id
        loadCoverImage(from: place.cover)
    }
    
    private func loadCoverImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("URL inválida para imagem.")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                print("Erro ao carregar imagem: \(error.localizedDescription)")
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                print("Dados inválidos para a imagem.")
                return
            }
            DispatchQueue.main.async {
                self?.coverImageView.image = image
            }
        }.resume()
    }
    
    private func showErrorState(with message: String) {
        stateView.isHidden = false
        stateView.subviews.forEach { $0.removeFromSuperview() }
        
        let errorLabel = UILabel()
        errorLabel.text = message
        errorLabel.font = Typography.textMD
        errorLabel.textColor = Colors.redBase
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        stateView.addSubview(errorLabel)
        
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            errorLabel.centerXAnchor.constraint(equalTo: stateView.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: stateView.centerYAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: stateView.leadingAnchor, constant: 24),
            errorLabel.trailingAnchor.constraint(equalTo: stateView.trailingAnchor, constant: -24)
        ])
    }
    
    private func createInfoRow(iconName: String, text: String) -> UIStackView {
        let iconImageView = UIImageView(image: UIImage(named: iconName))
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.tintColor = Colors.gray500
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        let label = UILabel()
        label.text = text
        label.font = Typography.textSM
        label.textColor = Colors.gray500
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [iconImageView, label])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }
}
