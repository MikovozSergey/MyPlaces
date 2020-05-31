//
//  RatingControl.swift
//  MyPlaces
//
//  Created by Дарья Станкевич on 5/31/20.
//  Copyright © 2020 Sergey Mikovoz. All rights reserved.
//

import UIKit

@IBDesignable class RatingControl: UIStackView { // IBDesignable для того чтобы изменения были видны и в Interface Builder
    
    // MARK: Properties of Button
    
    private var ratingButtons = [UIButton]()
    
    var rating = 0

    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    // MARK: Button action
    
    @objc func ratingButtonTapped(button: UIButton) {
        print("Button pressed")
    }
    
    // MARK: private method
    
    private func setupButtons() {
        
        for _ in 0..<5 {
        
            // создаем кнопку
            let button = UIButton()
            button.backgroundColor = .red
            
            // создаем констреинты
            button.translatesAutoresizingMaskIntoConstraints = false // отключаем автоматические констреинты
            button.heightAnchor.constraint(equalToConstant: 44.0).isActive = true // даем значения констреинтам высоты и ширины
            button.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
            
            // создаем нажатую кнопку
            button.addTarget(self, action: #selector(ratingButtonTapped(button:)), for: .touchUpInside)
            
            // добавляем кнопку к нашему stack view
            addArrangedSubview(button)
            
            // добавляем новую кнопку в массив кнопок рэйтинга
            ratingButtons.append(button)
        }
    }
}
