//
//  JoinChannelViewController.swift
//  Awesome Video Call
//

import UIKit

final class JoinChannelViewController: UIViewController {
    
    private let textField = UITextField()
    private let joinButton = UIButton()
    private let loadingStack = UIStackView()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let loadingLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "RTC"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        setupForm()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
}

private extension JoinChannelViewController {
    
    func setupForm() {
        
        textField.placeholder = "Enter Channel Name..."
        joinButton.configuration = .filled()
        joinButton.setTitle("Join", for: .normal)
        joinButton.addTarget(self, action: #selector(joinButtonTapped(_:)), for: .touchUpInside)
        
        loadingStack.translatesAutoresizingMaskIntoConstraints = false
        loadingStack.spacing = 4
        loadingLabel.text = "Loading..."
        loadingLabel.textColor = .secondaryLabel
        loadingStack.addArrangedSubview(activityIndicator)
        loadingStack.addArrangedSubview(loadingLabel)
        loadingStack.isHidden = true
        view.addSubview(loadingStack)
        
        let stack = UIStackView(arrangedSubviews: [
            textField, joinButton
        ])
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 20
        
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            joinButton.heightAnchor.constraint(equalToConstant: 50),
            
            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 36),
            view.layoutMarginsGuide.trailingAnchor.constraint(equalTo: stack.safeAreaLayoutGuide.trailingAnchor),
            
            loadingStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingStack.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 20)
        ])
    }
    
    @objc
    func joinButtonTapped(_ button: UIButton) {
        guard let channelName = textField.text,
              !channelName.isEmpty
        else {
            return
        }
        
        showLoadingIndicator()
        
        let tokenService = AgoraTokenService()
        Task {
            do {
                
                let token = try await tokenService.getToken(for: channelName)
                
                let videoCallViewController = VideoCallViewController(
                    token: token,
                    channel: channelName
                )
                
                DispatchQueue.main.async { [weak self] in
                    self?.hideLoadingIndicator()
                    self?.navigationController?.pushViewController(
                        videoCallViewController,
                        animated: true
                    )
                }
                
            } catch {
                assertionFailure("Token service error: \(error.localizedDescription)")
            }
        }
    }
    
    func showLoadingIndicator() {
        loadingStack.isHidden = false
        activityIndicator.startAnimating()
        joinButton.isEnabled = false
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        loadingStack.isHidden = true
        joinButton.isEnabled = true
    }
}
