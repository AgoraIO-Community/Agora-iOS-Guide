//
//  VideoCallControlButtonsView.swift
//  Awesome Video Call
//

import UIKit

protocol VideoCallControlButtonsViewDelegate: AnyObject {
    func didTapButton(type: VideoCallControlButtonsView.ButtonType, isSelected: Bool)
}

final class VideoCallControlButtonsView: UIView {
    
    weak var delegate: VideoCallControlButtonsViewDelegate?
    
    enum ButtonType {
        case mute
        case leave
        case cameraOff
    }
    
    private let buttonStack = UIStackView()
    private let muteButton = UIButton()
    private let cameraOffButton = UIButton()
    private let leaveButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupButtons()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension VideoCallControlButtonsView {
    
    func setupButtons() {
        buttonStack.axis = .horizontal
        buttonStack.spacing = 32
        buttonStack.alignment = .center
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(buttonStack)
        
        [muteButton, leaveButton, cameraOffButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            buttonStack.addArrangedSubview($0)
            $0.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        }
        
        [muteButton, cameraOffButton].forEach {
            $0.isSelected = false
            $0.tintColor = .white
        }
        
        leaveButton.tintColor = .systemRed
        
        let primaryConstraints = [
            leaveButton.widthAnchor.constraint(equalToConstant: 80),
            leaveButton.heightAnchor.constraint(equalToConstant: 80)
        ]
        
        let secondaryConstraints = [muteButton, cameraOffButton].reduce([NSLayoutConstraint]()) { result, button in
            result + [
                button.widthAnchor.constraint(equalToConstant: 64),
                button.heightAnchor.constraint(equalToConstant: 64)
            ]
        }
        
        configureMuteButton()
        leaveButton.setBackgroundImage(UIImage(systemName: "phone.down.circle.fill")?.applyingSymbolConfiguration(.preferringMulticolor()), for: .normal)
        configureCameraOffButton()
        
        let stackConstraints = [
            buttonStack.topAnchor.constraint(equalTo: topAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailingAnchor.constraint(equalTo: buttonStack.trailingAnchor),
            bottomAnchor.constraint(equalTo: buttonStack.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(primaryConstraints + secondaryConstraints + stackConstraints)
    }
    
    func configureMuteButton() {
        func muteImageConfig(_ isSelected: Bool) -> UIImage.SymbolConfiguration {
            let colorConfig = UIImage.SymbolConfiguration(paletteColors: isSelected ? [.systemRed] : [.white])
            let sizeConfig = UIImage.SymbolConfiguration(pointSize: 20)
            return colorConfig.applying(sizeConfig)
        }
        muteButton.setImage(UIImage(systemName: "mic.slash.fill"), for: .normal)
        muteButton.setImage(UIImage(systemName: "mic.slash.fill"), for: .selected)
        muteButton.setPreferredSymbolConfiguration(muteImageConfig(true), forImageIn: .selected)
        muteButton.setPreferredSymbolConfiguration(muteImageConfig(false), forImageIn: .normal)
        muteButton.setBackgroundImage(
            UIImage(systemName: "circle.fill")?.applyingSymbolConfiguration(.init(hierarchicalColor: .gray)),
            for: .normal
        )
        muteButton.setBackgroundImage(
            UIImage(systemName: "circle.fill")?.applyingSymbolConfiguration(.init(hierarchicalColor: .white)),
            for: .selected
        )
    }
    
    func configureCameraOffButton() {
        func cameraImageConfig(_ isSelected: Bool) -> UIImage.SymbolConfiguration {
            let colorConfig = UIImage.SymbolConfiguration(paletteColors: isSelected ? [.white] : [.black])
            let sizeConfig = UIImage.SymbolConfiguration(pointSize: 20)
            return colorConfig.applying(sizeConfig)
        }
        cameraOffButton.setImage(UIImage(systemName: "video.fill"), for: .normal)
        cameraOffButton.setImage(UIImage(systemName: "video.fill"), for: .selected)
        cameraOffButton.setPreferredSymbolConfiguration(cameraImageConfig(true), forImageIn: .selected)
        cameraOffButton.setPreferredSymbolConfiguration(cameraImageConfig(false), forImageIn: .normal)
        cameraOffButton.setBackgroundImage(
            UIImage(systemName: "circle.fill")?.applyingSymbolConfiguration(.init(hierarchicalColor: .white)),
            for: .normal
        )
        cameraOffButton.setBackgroundImage(
            UIImage(systemName: "circle.fill")?.applyingSymbolConfiguration(.init(hierarchicalColor: .gray)),
            for: .selected
        )
    }
    
    func cameraOffImage(_ isSelected: Bool) -> UIImage? {
        let colorConfig = UIImage.SymbolConfiguration(paletteColors: isSelected ? [.black, .white] : [.white, .systemGray])
        return UIImage(systemName: "video.circle.fill")?
            .applyingSymbolConfiguration(colorConfig)
    }
    
    @objc
    func buttonTapped(_ button: UIButton) {
        button.isSelected.toggle()
        switch button {
        case muteButton:
            delegate?.didTapButton(type: .mute, isSelected: button.isSelected)
        case cameraOffButton:
            delegate?.didTapButton(type: .cameraOff, isSelected: button.isSelected)
        case leaveButton:
            delegate?.didTapButton(type: .leave, isSelected: true)
        default:
            assertionFailure()
        }
    }
}
