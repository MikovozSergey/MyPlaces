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
    
    var rating = 0 {
        didSet {
            updateButtonSelectionState()
        }
    }
    
    private var ratingButtons = [UIButton]()
    
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButtons() //  такая реализация добавляет кнопки к уже существующему количеству из Interface Builder
        }
    } // IBInspectable для свойств
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }

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
        
        guard let index = ratingButtons.firstIndex(of: button) else { return }
        
        // Считаем рейтинг в соответствии с выбранной звездой
        let selectedRating = index + 1
        
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
    }
    
    // MARK: private method
    
    private func setupButtons() {

        for button in ratingButtons { // здесь мы удаляем наши существующие кнопки, если выставляем значение в Interface builder
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }

        ratingButtons.removeAll() // очиска всех кнопок которые были до этого
        
        // Загрузка картинки для кнопки
        let bundle = Bundle(for: type(of: self)) // явно определяет местонахождение картинки чтобы поставить его в storyboard
        let emptyStar = UIImage(named: "emptyStar", in: bundle, compatibleWith: self.traitCollection)
        let filledStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection)
        let highlightedStar = UIImage(named: "highlightedStar", in: bundle, compatibleWith: self.traitCollection)
        
        for _ in 0 ..< starCount {

            // создаем кнопку
            let button = UIButton()
           
            // устанавливаем картинку для кнопки
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected]) // подсвечивается синим пока прикасаемся и не отпускаем кнопку
            
            // создаем констреинты
            button.translatesAutoresizingMaskIntoConstraints = false // отключаем автоматические констреинты
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true // даем значения констреинтам высоты и ширины
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            // создаем нажатую кнопку
            button.addTarget(self, action: #selector(ratingButtonTapped(button:)), for: .touchUpInside)
            
            // добавляем кнопку к нашему stack view
            addArrangedSubview(button)
            
            // добавляем новую кнопку в массив кнопок рэйтинга
            ratingButtons.append(button)
        }
        
        updateButtonSelectionState()
    }
    
    private func updateButtonSelectionState() { // устанавливаем картинку в соответствии с состоянием для других звезд
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
    }
}
