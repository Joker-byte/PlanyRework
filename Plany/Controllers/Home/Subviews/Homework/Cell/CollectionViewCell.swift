//
//  CollectionViewCell.swift
//  Plany
//
//  Created by Gianluca Dubioso on 10/12/20.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
      @IBOutlet weak var postTitleLabel: UILabel!
      @IBOutlet weak var postText: UILabel!
      @IBOutlet weak var postTime: UILabel!
      @IBOutlet weak var postTimeHours: UILabel!

  override func awakeFromNib() {
      super.awakeFromNib()
  }
}
