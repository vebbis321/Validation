//
//  UIViewController+Extensions.swift
//  CustomTextField
//
//  Created by Vebjørn Daniloff on 7/25/23.
//

import SwiftUI

extension UIViewController {
    
    
    private struct Preview: UIViewControllerRepresentable {
        
        let viewController: UIViewController
        
        func makeUIViewController(context: Context) -> some UIViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    }
    
    func showPreview() -> some View  {
        Preview(viewController: self)
    }
}
